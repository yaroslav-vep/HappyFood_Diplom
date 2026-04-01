class FoodAnalysisModel {
  final String dishName;
  final int calories;
  final double protein;
  final double fats;
  final double carbs;
  final List<String> ingredients;
  final List<String> instructions;

  const FoodAnalysisModel({
    required this.dishName,
    required this.calories,
    required this.protein,
    required this.fats,
    required this.carbs,
    required this.ingredients,
    required this.instructions,
  });

  factory FoodAnalysisModel.fromJson(Map<String, dynamic> json) {
    return FoodAnalysisModel(
      dishName: json['dishName'] as String? ?? 'Unknown Dish',
      calories: (json['calories'] as num?)?.toInt() ?? 0,
      protein: (json['protein'] as num?)?.toDouble() ?? 0.0,
      fats: (json['fats'] as num?)?.toDouble() ?? 0.0,
      carbs: (json['carbs'] as num?)?.toDouble() ?? 0.0,
      ingredients: (json['ingredients'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
      instructions: (json['instructions'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
    );
  }
}
