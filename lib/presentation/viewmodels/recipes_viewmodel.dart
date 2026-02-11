import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/services/recipe_service.dart';
import '../../data/models/recipe_model.dart';
import 'user_viewmodel.dart';
import 'products_viewmodel.dart';
import 'nutrition_viewmodel.dart'; // To get daily limits

class RecipesViewModel extends StateNotifier<List<RecipeModel>> {
  final RecipeService _recipeService;
  final Ref _ref;

  RecipesViewModel(this._recipeService, this._ref) : super([]);

  // Add a search method
  void search(String query) {
    if (query.isEmpty) {
      generateRecommendations(); // Reset to recommendations if query is empty
    } else {
      final results = _recipeService.searchRecipes(query);
      state = results;
    }
  }

  void generateRecommendations() {
    final user = _ref.read(userViewModelProvider);
    final products = _ref.read(productsViewModelProvider);

    // Placeholder max calories logic
    int maxCaloriesPerMeal = 800;

    final recommendations = _recipeService.getRecommendations(
      user: user,
      availableProducts: products,
      maxCalories: maxCaloriesPerMeal,
    );
    state = recommendations;
  }
}

final recipeServiceProvider = Provider((ref) => RecipeService());

final recipesViewModelProvider =
    StateNotifierProvider<RecipesViewModel, List<RecipeModel>>((ref) {
      final service = ref.read(recipeServiceProvider);
      return RecipesViewModel(service, ref);
    });
