import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/services/recipe_service.dart';
import '../../data/models/recipe_model.dart';
import 'user_viewmodel.dart';
import 'products_viewmodel.dart';
import 'nutrition_viewmodel.dart'; // To get daily limits

class RecipesViewModel extends StateNotifier<List<RecipeModel>> {
  final RecipeService _recipeService;
  final Ref _ref;

  List<RecipeModel> _fullList = [];
  int _visibleCount = 15;
  static const int _pageSize = 15;

  bool get hasMore => _visibleCount < _fullList.length;

  RecipesViewModel(this._recipeService, this._ref) : super([]) {
    _fullList = _recipeService.allRecipes;
    _updateState();
    // Start loading from TheMealDB API in the background
    _loadFromApi();
  }

  void _updateState() {
    if (_fullList.isEmpty) {
      state = [];
    } else {
      state = _fullList.take(_visibleCount).toList();
    }
  }

  bool _isLoadingMore = false;

  void loadMore() {
    if (hasMore && !_isLoadingMore) {
      _isLoadingMore = true;
      // Simulate network delay for a better UX experience
      Future.delayed(const Duration(milliseconds: 500), () {
        _visibleCount += _pageSize;
        _updateState();
        _isLoadingMore = false;
      });
    }
  }

  /// Loads recipes from the API, then refreshes state.
  Future<void> _loadFromApi() async {
    await _recipeService.loadRecipes(onComplete: () {
      // After API load completes, refresh recommendations
      generateRecommendations();
    });
  }

  /// Force a reload from the API (pull-to-refresh).
  Future<void> refresh() async {
    await _recipeService.loadRecipes(
      force: true,
      onComplete: () {
        generateRecommendations();
      },
    );
  }

  // Search method
  void search(String query) {
    _visibleCount = _pageSize; // Reset pagination on new search
    if (query.isEmpty) {
      generateRecommendations(); // Reset to recommendations if query is empty
    } else {
      _fullList = _recipeService.searchRecipes(query);
      _updateState();
    }
  }

  void generateRecommendations() {
    _visibleCount = _pageSize; // Reset pagination
    final user = _ref.read(userViewModelProvider);
    final products = _ref.read(productsViewModelProvider);

    // Placeholder max calories logic
    int maxCaloriesPerMeal = 800;

    _fullList = _recipeService.getRecommendations(
      user: user,
      availableProducts: products,
      maxCalories: maxCaloriesPerMeal,
    );
    _updateState();
  }
}

final recipeServiceProvider = Provider((ref) => RecipeService());

final recipesViewModelProvider =
    StateNotifierProvider<RecipesViewModel, List<RecipeModel>>((ref) {
      final service = ref.read(recipeServiceProvider);
      return RecipesViewModel(service, ref);
    });
