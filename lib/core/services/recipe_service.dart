import '../../data/models/recipe_model.dart';
import '../../data/models/user_model.dart';
import '../../data/models/product_model.dart';
import 'mealdb_service.dart';

class RecipeService {
  final MealDbService _mealDbService = MealDbService();
  List<RecipeModel> _allRecipes = [];
  bool _isLoaded = false;
  bool _isLoading = false;

  // ── Fallback hardcoded recipes (used when API is unavailable) ─────────────
  static final List<RecipeModel> _fallbackRecipes = [
    RecipeModel(
      title: 'Oatmeal with Berries',
      description: 'A nutritious breakfast of rolled oats with fresh berries.',
      ingredients: ['Oats', 'Blueberries', 'Milk', 'Honey'],
      calories: 350, protein: 10, fats: 6, carbs: 60,
      tags: ['breakfast', 'high-carb'],
      imageUrl: 'https://images.unsplash.com/photo-1517673400267-0251440c45dc?w=400&q=60&fm=webp',
      steps: ['Boil milk in a saucepan.', 'Add oats and reduce heat.', 'Cook for 5 minutes, stirring occasionally.', 'Add berries and drizzle with honey.'],
    ),
    RecipeModel(
      title: 'Chicken Salad',
      description: 'Grilled chicken breast with mixed greens and vegetables.',
      ingredients: ['Chicken Breast', 'Salad Mix', 'Tomato', 'Cucumber', 'Olive Oil'],
      calories: 400, protein: 40, fats: 15, carbs: 8,
      tags: ['lunch', 'high-protein', 'low-carb'],
      imageUrl: 'https://images.unsplash.com/photo-1512621776951-a57141f2eefd?w=400&q=60&fm=webp',
      steps: ['Season chicken breast with salt and pepper.', 'Grill for 6–7 minutes on each side.', 'Chop vegetables and greens.', 'Slice the chicken and toss with the vegetables and oil.'],
    ),
    RecipeModel(
      title: 'Pasta with Tomato Sauce',
      description: 'Classic pasta with homemade tomato sauce.',
      ingredients: ['Pasta', 'Tomatoes', 'Garlic', 'Basil', 'Olive Oil'],
      calories: 580, protein: 15, fats: 10, carbs: 95,
      tags: ['lunch', 'high-carb'],
      imageUrl: 'https://images.unsplash.com/photo-1473093295043-cdd812d0e601?w=400&q=60&fm=webp',
      steps: ['Boil pasta in salted water.', 'Sauté garlic in olive oil.', 'Add tomatoes and simmer for 15 minutes.', 'Toss the pasta with the sauce and basil.'],
    ),
    RecipeModel(
      title: 'Salmon with Rice',
      description: 'Baked salmon with boiled rice and lemon.',
      ingredients: ['Salmon', 'Rice', 'Lemon', 'Dill', 'Olive Oil'],
      calories: 520, protein: 42, fats: 20, carbs: 38,
      tags: ['dinner', 'fish', 'high-protein'],
      imageUrl: 'https://images.unsplash.com/photo-1467003909585-2f8a72700288?w=400&q=60&fm=webp',
      steps: ['Marinate the salmon in lemon juice and oil.', 'Bake at 180°C for 15–18 minutes.', 'Boil the rice.', 'Serve the salmon with rice, garnished with dill.'],
    ),
    RecipeModel(
      title: 'Steak with Vegetables',
      description: 'Pan-seared steak with steamed vegetables.',
      ingredients: ['Steak', 'Broccoli', 'Carrots', 'Butter'],
      calories: 680, protein: 50, fats: 34, carbs: 12,
      tags: ['dinner', 'high-protein', 'bulk'],
      imageUrl: 'https://images.unsplash.com/photo-1544025162-d76694265947?w=400&q=60&fm=webp',
      steps: ['Season the steak with salt and pepper.', 'Sear in a hot pan for 3–4 minutes per side.', 'Steam the broccoli and carrots.', 'Serve the steak with the vegetables.'],
    ),
    RecipeModel(
      title: 'Greek Yogurt with Nuts',
      description: 'Greek yogurt with honey and walnuts.',
      ingredients: ['Greek Yogurt', 'Honey', 'Walnuts'],
      calories: 290, protein: 20, fats: 12, carbs: 24,
      tags: ['snack', 'high-protein'],
      imageUrl: 'https://images.unsplash.com/photo-1488477181946-6428a029177b?w=400&q=60&fm=webp',
      steps: ['Place Greek yogurt in a bowl.', 'Drizzle with honey.', 'Sprinkle with crushed walnuts.'],
    ),
  ];

  // ── Public API ──────────────────────────────────────────────────────────────

  List<RecipeModel> get allRecipes {
    if (!_isLoaded) {
      return _fallbackRecipes;
    }
    return _allRecipes.isNotEmpty ? _allRecipes : _fallbackRecipes;
  }

  /// Loads recipes from TheMealDB. Call this once on app startup.
  /// Set [force] to true to re-fetch even if already loaded (pull-to-refresh).
  Future<void> loadRecipes({Function()? onComplete, bool force = false}) async {
    if (_isLoading) return;
    if (_isLoaded && !force) return;
    _isLoading = true;

    try {
      final recipes = await _mealDbService.fetchRecipes();
      if (recipes.isNotEmpty) {
        _allRecipes = recipes;
        _isLoaded = true;
      } else {
        if (!_isLoaded) {
          _allRecipes = _fallbackRecipes;
          _isLoaded = true;
        }
      }
    } catch (_) {
      if (!_isLoaded) {
        _allRecipes = _fallbackRecipes;
        _isLoaded = true;
      }
    } finally {
      _isLoading = false;
      onComplete?.call();
    }
  }

  bool get isLoaded => _isLoaded;

  List<RecipeModel> searchRecipes(String query) {
    final source = allRecipes;
    if (query.isEmpty) return source;
    final q = query.toLowerCase();
    return source.where((recipe) {
      return recipe.title.toLowerCase().contains(q) ||
          recipe.description.toLowerCase().contains(q) ||
          recipe.ingredients.any((i) => i.toLowerCase().contains(q)) ||
          recipe.tags.any((t) => t.toLowerCase().contains(q));
    }).toList();
  }

  List<RecipeModel> getRecommendations({
    required UserModel user,
    required List<ProductModel> availableProducts,
    required int maxCalories,
  }) {
    var filtered = allRecipes;

    // Filter by goal
    if (user.goal == 'Lose Weight') {
      filtered = filtered.where((r) => r.calories < 500).toList();
    } else if (user.goal == 'Gain Weight') {
      filtered = filtered.where((r) => r.calories >= 400).toList();
    }

    // Filter by available products (if specified)
    if (availableProducts.isNotEmpty) {
      final availableNames =
          availableProducts.map((p) => p.name.toLowerCase().trim()).toList();

      // Find recipes where AT LEAST ONE ingredient matches AT LEAST ONE available product.
      final matches = filtered.where((recipe) {
        return recipe.ingredients.any((ing) {
          final lowerIng = ing.toLowerCase();
          return availableNames.any((name) => lowerIng.contains(name));
        });
      }).toList();

      // Sort by number of matched ingredients (descending) so most relevant are first
      matches.sort((a, b) {
        int aMatches = a.ingredients.where((ing) {
          final lowerIng = ing.toLowerCase();
          return availableNames.any((name) => lowerIng.contains(name));
        }).length;
        int bMatches = b.ingredients.where((ing) {
          final lowerIng = ing.toLowerCase();
          return availableNames.any((name) => lowerIng.contains(name));
        }).length;
        return bMatches.compareTo(aMatches);
      });

      // If there are matches, return them, otherwise return empty list
      // (previously it returned all recipes if strict matching failed)
      filtered = matches;
    }

    return filtered;
  }
}
