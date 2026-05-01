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

  /// Indices of ingredients that are OPTIONAL (can be skipped).
  /// Required ingredients = all indices NOT in this list.
  final List<int> optionalIngredientIndices;

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
    this.optionalIngredientIndices = const [],
  });

  String localizedTitle(String lang) => title;
  String localizedDescription(String lang) => description;
  List<String> localizedIngredients(String lang) => ingredients;
  List<String> localizedSteps(String lang) => steps;

  /// Returns true if the given ingredient index is optional.
  bool isOptional(int index) => optionalIngredientIndices.contains(index);

  /// Returns true if the given ingredient index is required.
  bool isRequired(int index) => !optionalIngredientIndices.contains(index);
}
