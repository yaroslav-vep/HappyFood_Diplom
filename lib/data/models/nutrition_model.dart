import 'eaten_meal_model.dart';

class NutritionModel {
  final int calories;
  final int protein;
  final int fats;
  final int carbs;

  // Daily targets (calculated from user profile)
  final int targetCalories;
  final int targetProtein;
  final int targetFats;
  final int targetCarbs;

  // List of eaten meals today
  final List<EatenMealModel> eatenMeals;

  /// Historical meal log: list of past-day meal lists (newest first).
  /// Each inner list = all meals eaten on that particular day.
  final List<List<EatenMealModel>> mealHistory;

  NutritionModel({
    required this.calories,
    required this.protein,
    required this.fats,
    required this.carbs,
    this.targetCalories = 2000,
    this.targetProtein = 150,
    this.targetFats = 67,
    this.targetCarbs = 200,
    this.eatenMeals = const [],
    this.mealHistory = const [],
  });

  NutritionModel copyWith({
    int? calories,
    int? protein,
    int? fats,
    int? carbs,
    int? targetCalories,
    int? targetProtein,
    int? targetFats,
    int? targetCarbs,
    List<EatenMealModel>? eatenMeals,
    List<List<EatenMealModel>>? mealHistory,
  }) {
    return NutritionModel(
      calories: calories ?? this.calories,
      protein: protein ?? this.protein,
      fats: fats ?? this.fats,
      carbs: carbs ?? this.carbs,
      targetCalories: targetCalories ?? this.targetCalories,
      targetProtein: targetProtein ?? this.targetProtein,
      targetFats: targetFats ?? this.targetFats,
      targetCarbs: targetCarbs ?? this.targetCarbs,
      eatenMeals: eatenMeals ?? this.eatenMeals,
      mealHistory: mealHistory ?? this.mealHistory,
    );
  }
}
