import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/nutrition_model.dart';
import '../../data/models/eaten_meal_model.dart';
import '../../data/models/recipe_model.dart';
import 'user_viewmodel.dart';

class NutritionViewModel extends StateNotifier<NutritionModel> {
  final Ref _ref;

  NutritionViewModel(this._ref)
    : super(NutritionModel(calories: 0, protein: 0, fats: 0, carbs: 0)) {
    // Listen to user changes to auto-recalculate targets
    _ref.listen<Object?>(userViewModelProvider, (previous, next) {
      _recalculateTargets();
    });
  }

  void _recalculateTargets() {
    final user = _ref.read(userViewModelProvider);

    // Harris-Benedict Equation (Simplified)
    double bmr;
    if (user.gender == 'Male') {
      bmr =
          88.36 + (13.4 * user.weight) + (4.8 * user.height) - (5.7 * user.age);
    } else {
      bmr =
          447.6 + (9.2 * user.weight) + (3.1 * user.height) - (4.3 * user.age);
    }

    // Activity Multiplier
    double multiplier = 1.2; // Sedentary
    switch (user.activityLevel) {
      case 'Lightly Active':
        multiplier = 1.375;
        break;
      case 'Moderately Active':
        multiplier = 1.55;
        break;
      case 'Very Active':
        multiplier = 1.725;
        break;
      case 'Super Active':
        multiplier = 1.9;
        break;
    }

    double tdee = bmr * multiplier;

    // Goal Adjustment
    if (user.goal == 'Cut') {
      tdee -= 500;
    } else if (user.goal == 'Bulk') {
      tdee += 500;
    }

    // Macros: 30% Protein, 30% Fat, 40% Carbs
    int targetCalories = tdee.round();
    int targetProtein = ((targetCalories * 0.30) / 4).round();
    int targetFats = ((targetCalories * 0.30) / 9).round();
    int targetCarbs = ((targetCalories * 0.40) / 4).round();

    // Recalculate keeping existing eaten meals
    state = state.copyWith(
      targetCalories: targetCalories,
      targetProtein: targetProtein,
      targetFats: targetFats,
      targetCarbs: targetCarbs,
    );
  }

  // Called from legacy code
  void calculateNeeds() {
    _recalculateTargets();
  }

  // Add a meal that was eaten
  void addEatenMeal(RecipeModel recipe) {
    final newMeal = EatenMealModel(recipe: recipe, eatenAt: DateTime.now());
    final updatedMeals = [...state.eatenMeals, newMeal];

    // Recalculate consumed totals
    final totalCalories = updatedMeals.fold(0, (sum, m) => sum + m.recipe.calories);
    final totalProtein = updatedMeals.fold(0, (sum, m) => sum + m.recipe.protein);
    final totalFats = updatedMeals.fold(0, (sum, m) => sum + m.recipe.fats);
    final totalCarbs = updatedMeals.fold(0, (sum, m) => sum + m.recipe.carbs);

    state = state.copyWith(
      calories: totalCalories,
      protein: totalProtein,
      fats: totalFats,
      carbs: totalCarbs,
      eatenMeals: updatedMeals,
    );
  }

  // Remove a specific eaten meal
  void removeEatenMeal(EatenMealModel meal) {
    final updatedMeals = state.eatenMeals.where((m) => m != meal).toList();

    final totalCalories = updatedMeals.fold(0, (sum, m) => sum + m.recipe.calories);
    final totalProtein = updatedMeals.fold(0, (sum, m) => sum + m.recipe.protein);
    final totalFats = updatedMeals.fold(0, (sum, m) => sum + m.recipe.fats);
    final totalCarbs = updatedMeals.fold(0, (sum, m) => sum + m.recipe.carbs);

    state = state.copyWith(
      calories: totalCalories,
      protein: totalProtein,
      fats: totalFats,
      carbs: totalCarbs,
      eatenMeals: updatedMeals,
    );
  }

  // Reset today's intake
  void clearToday() {
    state = state.copyWith(
      calories: 0,
      protein: 0,
      fats: 0,
      carbs: 0,
      eatenMeals: [],
    );
  }
}

final nutritionViewModelProvider =
    StateNotifierProvider<NutritionViewModel, NutritionModel>((ref) {
      final vm = NutritionViewModel(ref);
      // Initial calculation of targets
      vm.calculateNeeds();
      return vm;
    });
