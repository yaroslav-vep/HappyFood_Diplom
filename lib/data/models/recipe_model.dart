class RecipeModel {
  final String title;
  final String? titleRu;
  final String description;
  final String? descriptionRu;
  final List<String> ingredients;
  final List<String>? ingredientsRu;
  final int calories;
  final int protein;
  final int fats;
  final int carbs;
  final List<String> tags;
  final String imageUrl;
  final List<String> steps;
  final List<String>? stepsRu;

  RecipeModel({
    required this.title,
    this.titleRu,
    required this.description,
    this.descriptionRu,
    required this.ingredients,
    this.ingredientsRu,
    required this.calories,
    required this.protein,
    required this.fats,
    required this.carbs,
    this.tags = const [],
    required this.imageUrl,
    required this.steps,
    this.stepsRu,
  });

  String localizedTitle(String lang) => (lang == 'RU' && titleRu != null) ? titleRu! : title;
  String localizedDescription(String lang) => (lang == 'RU' && descriptionRu != null) ? descriptionRu! : description;
  List<String> localizedIngredients(String lang) => (lang == 'RU' && ingredientsRu != null) ? ingredientsRu! : ingredients;
  List<String> localizedSteps(String lang) => (lang == 'RU' && stepsRu != null) ? stepsRu! : steps;
}
