import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../data/models/recipe_model.dart';

/// Service that fetches real recipe data from TheMealDB API (free, no key required).
/// API docs: https://www.themealdb.com/api.php
class MealDbService {
  static const String _baseUrl = 'https://www.themealdb.com/api/json/v1/1';

  /// Fetches recipes by searching multiple keywords to build a diverse set.
  Future<List<RecipeModel>> fetchRecipes() async {
    final queries = [
      'Chicken', 'Beef', 'Salmon', 'Pasta', 'Salad',
      'Soup', 'Rice', 'Lamb', 'Pork', 'Vegetarian',
      'Breakfast', 'Dessert', 'Seafood', 'Curry',
    ];

    final Set<String> seenIds = {};
    final List<RecipeModel> recipes = [];

    for (final query in queries) {
      try {
        final meals = await _searchMeals(query);
        for (final meal in meals) {
          final id = meal['idMeal'] as String;
          if (!seenIds.contains(id)) {
            seenIds.add(id);
            final recipe = _parseRecipe(meal);
            if (recipe != null) {
              recipes.add(recipe);
            }
          }
        }
      } catch (_) {
        // Skip failed queries silently
      }
    }

    return recipes;
  }

  /// Fetches a batch of random meals (uses multiple single-random calls).
  Future<List<RecipeModel>> fetchRandomRecipes({int count = 10}) async {
    final Set<String> seenIds = {};
    final List<RecipeModel> recipes = [];

    for (int i = 0; i < count * 2 && recipes.length < count; i++) {
      try {
        final url = Uri.parse('$_baseUrl/random.php');
        final response = await http.get(url).timeout(const Duration(seconds: 8));
        if (response.statusCode == 200) {
          final data = jsonDecode(response.body);
          final meals = data['meals'] as List?;
          if (meals != null && meals.isNotEmpty) {
            final meal = meals[0] as Map<String, dynamic>;
            final id = meal['idMeal'] as String;
            if (!seenIds.contains(id)) {
              seenIds.add(id);
              final recipe = _parseRecipe(meal);
              if (recipe != null) {
                recipes.add(recipe);
              }
            }
          }
        }
      } catch (_) {
        // Skip
      }
    }

    return recipes;
  }

  /// Search meals by name
  Future<List<Map<String, dynamic>>> _searchMeals(String query) async {
    final url = Uri.parse('$_baseUrl/search.php?s=$query');
    final response = await http.get(url).timeout(const Duration(seconds: 10));

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final meals = data['meals'] as List?;
      if (meals != null) {
        return meals.cast<Map<String, dynamic>>();
      }
    }
    return [];
  }

  /// Parse a TheMealDB meal JSON into our RecipeModel.
  RecipeModel? _parseRecipe(Map<String, dynamic> meal) {
    try {
      final title = meal['strMeal'] as String? ?? '';
      if (title.isEmpty) return null;

      // Extract ingredients (strIngredient1..20)
      final ingredients = <String>[];
      for (int i = 1; i <= 20; i++) {
        final ingredient = (meal['strIngredient$i'] as String?)?.trim() ?? '';
        if (ingredient.isNotEmpty) {
          ingredients.add(ingredient);
        }
      }
      if (ingredients.isEmpty) return null;

      // Extract instructions and split into steps
      final instructions = meal['strInstructions'] as String? ?? '';
      final steps = _parseSteps(instructions);
      if (steps.isEmpty) {
        // If we can't parse steps, use the full instructions as one step
        if (instructions.isNotEmpty) {
          // Split by sentence for readability
          final sentences = instructions
              .split(RegExp(r'(?<=[.!?])\s+'))
              .where((s) => s.trim().isNotEmpty)
              .take(8)
              .toList();
          if (sentences.isEmpty) return null;
        } else {
          return null;
        }
      }

      // Build image URL (use thumbnail)
      final imageUrl = meal['strMealThumb'] as String? ?? '';
      if (imageUrl.isEmpty) return null;

      // Category and area for tag generation
      final category = (meal['strCategory'] as String?)?.toLowerCase() ?? '';
      final area = (meal['strArea'] as String?)?.toLowerCase() ?? '';
      final tags = <String>[];
      if (category.isNotEmpty) tags.add(category);
      if (area.isNotEmpty) tags.add(area);

      // Parse any existing tags
      final existingTags = meal['strTags'] as String?;
      if (existingTags != null && existingTags.isNotEmpty) {
        tags.addAll(existingTags.split(',').map((t) => t.trim().toLowerCase()));
      }

      // Estimate nutritional values based on category and ingredients
      final nutrition = _estimateNutrition(category, ingredients);

      return RecipeModel(
        title: title,
        description: _generateDescription(title, category, area),
        ingredients: ingredients,
        calories: nutrition['calories']!,
        protein: nutrition['protein']!,
        fats: nutrition['fats']!,
        carbs: nutrition['carbs']!,
        tags: tags,
        imageUrl: '$imageUrl/preview', // /preview gives smaller image
        steps: steps.isNotEmpty
            ? steps
            : instructions
                .split(RegExp(r'(?<=[.!?])\s+'))
                .where((s) => s.trim().isNotEmpty)
                .take(6)
                .toList(),
        optionalIngredientIndices: _detectOptionalIngredients(ingredients),
      );
    } catch (_) {
      return null;
    }
  }

  /// Determine which ingredients are optional based on their names.
  /// Spices, garnishes, sauces = optional. Proteins and main starches = required.
  List<int> _detectOptionalIngredients(List<String> ingredients) {
    // Keywords that make an ingredient "optional"
    const optionalKeywords = [
      'salt', 'pepper', 'garnish', 'parsley', 'coriander', 'cilantro',
      'basil', 'mint', 'dill', 'chive', 'scallion', 'spring onion',
      'sauce', 'ketchup', 'mustard', 'mayo', 'mayonnaise',
      'sugar', 'honey', 'syrup', 'vanilla', 'cinnamon', 'nutmeg', 'cumin',
      'paprika', 'turmeric', 'chilli', 'chili', 'cayenne', 'oregano', 'thyme',
      'bay leaf', 'rosemary', 'bay', 'garam masala', 'allspice',
      'lemon juice', 'lime juice', 'vinegar', 'oil', 'olive oil',
      'butter', 'cream', 'sour cream', 'cheese', 'topping',
      'sesame', 'sesame seed', 'poppy seed',
      'optional', 'to taste', 'for serving', 'to serve', 'to garnish',
      'breadcrumbs', 'croutons', 'crackers',
      'zest', 'juice',
    ];

    final optional = <int>[];
    for (int i = 0; i < ingredients.length; i++) {
      final lower = ingredients[i].toLowerCase();
      if (optionalKeywords.any((kw) => lower.contains(kw))) {
        optional.add(i);
      }
    }
    return optional;
  }


  /// Parse instructions text into individual steps.
  List<String> _parseSteps(String instructions) {
    if (instructions.isEmpty) return [];

    // Try to parse numbered steps (e.g., "Step 1\n...", "1. ...", "STEP 1 -")
    final stepPattern = RegExp(
      r'(?:step\s*\d+\s*[-:]?\s*|^\d+[\.\)]\s*)',
      caseSensitive: false,
      multiLine: true,
    );

    if (stepPattern.hasMatch(instructions)) {
      final parts = instructions.split(stepPattern)
          .where((s) => s.trim().isNotEmpty)
          .map((s) => s.trim().replaceAll(RegExp(r'\r?\n'), ' ').trim())
          .where((s) => s.length > 10)
          .toList();
      if (parts.length >= 2) return parts.take(8).toList();
    }

    // Fallback: split by double newlines or paragraph breaks
    final paragraphs = instructions
        .split(RegExp(r'\r?\n\r?\n'))
        .where((s) => s.trim().isNotEmpty)
        .map((s) => s.trim().replaceAll(RegExp(r'\r?\n'), ' ').trim())
        .where((s) => s.length > 10)
        .toList();

    if (paragraphs.length >= 2) return paragraphs.take(8).toList();

    // Final fallback: split by single newlines
    final lines = instructions
        .split(RegExp(r'\r?\n'))
        .where((s) => s.trim().isNotEmpty && s.trim().length > 10)
        .map((s) => s.trim())
        .toList();

    return lines.take(6).toList();
  }

  /// Generate a short description from title, category, and area.
  String _generateDescription(String title, String category, String area) {
    final parts = <String>[];
    if (area.isNotEmpty) {
      parts.add('${area[0].toUpperCase()}${area.substring(1)}');
    }
    if (category.isNotEmpty) {
      parts.add(category);
    }
    if (parts.isEmpty) return 'A delicious $title recipe.';
    return 'A delicious ${parts.join(' ')} dish — $title.';
  }

  /// Estimate nutritional values based on category and ingredient list.
  /// TheMealDB doesn't provide nutrition data, so we use reasonable estimates.
  Map<String, int> _estimateNutrition(String category, List<String> ingredients) {
    // Base estimates by category
    int cal, prot, fat, carb;

    switch (category) {
      case 'chicken':
        cal = 420; prot = 35; fat = 18; carb = 25;
      case 'beef':
        cal = 520; prot = 38; fat = 28; carb = 22;
      case 'lamb':
        cal = 550; prot = 32; fat = 30; carb = 28;
      case 'pork':
        cal = 480; prot = 30; fat = 24; carb = 30;
      case 'seafood':
        cal = 350; prot = 28; fat = 14; carb = 20;
      case 'pasta':
        cal = 520; prot = 18; fat = 16; carb = 72;
      case 'vegetarian':
      case 'vegan':
        cal = 320; prot = 12; fat = 10; carb = 48;
      case 'dessert':
        cal = 380; prot = 6; fat = 18; carb = 52;
      case 'breakfast':
        cal = 400; prot = 14; fat = 16; carb = 45;
      case 'side':
        cal = 220; prot = 6; fat = 8; carb = 30;
      case 'starter':
        cal = 280; prot = 10; fat = 12; carb = 28;
      case 'goat':
        cal = 500; prot = 30; fat = 26; carb = 28;
      case 'miscellaneous':
      default:
        cal = 420; prot = 18; fat = 16; carb = 38;
    }

    // Adjust based on ingredient count (more ingredients often = richer dish)
    final ingredientCount = ingredients.length;
    if (ingredientCount > 12) {
      cal += 80;
      fat += 4;
    } else if (ingredientCount < 5) {
      cal -= 60;
      carb -= 8;
    }

    // Adjust for specific high-calorie ingredients
    final allIngs = ingredients.join(' ').toLowerCase();
    if (allIngs.contains('cream') || allIngs.contains('butter')) {
      cal += 50; fat += 6;
    }
    if (allIngs.contains('rice') || allIngs.contains('pasta') || allIngs.contains('noodle')) {
      carb += 15;
    }
    if (allIngs.contains('sugar') || allIngs.contains('honey') || allIngs.contains('chocolate')) {
      cal += 40; carb += 10;
    }

    return {
      'calories': cal.clamp(100, 900),
      'protein': prot.clamp(2, 60),
      'fats': fat.clamp(2, 50),
      'carbs': carb.clamp(2, 100),
    };
  }
}
