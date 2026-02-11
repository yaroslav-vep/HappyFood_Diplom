class RecipeModel {
  final String title;
  final String description;
  final List<String> ingredients;
  final int calories;
  final int protein;
  final int fats;
  final int carbs;
  final List<String> tags;
  final String imageUrl;
  final List<String> steps;

  RecipeModel({
    required this.title,
    required this.description,
    required this.ingredients,
    required this.calories,
    required this.protein,
    required this.fats,
    required this.carbs,
    this.tags = const [],
    required this.imageUrl,
    required this.steps,
  });
}
