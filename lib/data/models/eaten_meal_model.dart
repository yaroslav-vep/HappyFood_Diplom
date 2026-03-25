import 'recipe_model.dart';

class EatenMealModel {
  final RecipeModel recipe;
  final DateTime eatenAt;

  EatenMealModel({required this.recipe, required this.eatenAt});
}
