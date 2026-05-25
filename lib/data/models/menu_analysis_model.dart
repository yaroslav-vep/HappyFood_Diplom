/// Model for a single dish extracted from a scanned café menu.
class MenuDishModel {
  final String dishName;
  final String? description;
  final String? weight; // e.g. "350g" — as printed on the menu
  final double? price; // price if visible on the menu
  final List<String> estimatedIngredients;
  final int calories;
  final double protein;
  final double fats;
  final double carbs;

  /// 0.0–1.0. Low confidence means limited info was available.
  final double confidence;

  /// True when data is based on rough estimates with little context.
  final bool isApproximate;

  const MenuDishModel({
    required this.dishName,
    this.description,
    this.weight,
    this.price,
    required this.estimatedIngredients,
    required this.calories,
    required this.protein,
    required this.fats,
    required this.carbs,
    required this.confidence,
    required this.isApproximate,
  });

  factory MenuDishModel.fromJson(Map<String, dynamic> json) {
    return MenuDishModel(
      dishName: (json['dishName'] as String?)?.trim() ?? 'Unknown Dish',
      description: json['description'] as String?,
      weight: json['weight'] as String?,
      price: (json['price'] as num?)?.toDouble(),
      estimatedIngredients:
          (json['estimatedIngredients'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
      calories: (json['calories'] as num?)?.toInt() ?? 0,
      protein: (json['protein'] as num?)?.toDouble() ?? 0.0,
      fats: (json['fats'] as num?)?.toDouble() ?? 0.0,
      carbs: (json['carbs'] as num?)?.toDouble() ?? 0.0,
      confidence: (json['confidence'] as num?)?.toDouble() ?? 0.5,
      isApproximate: json['isApproximate'] as bool? ?? true,
    );
  }

  Map<String, dynamic> toJson() => {
    'dishName': dishName,
    'description': description,
    'weight': weight,
    'price': price,
    'estimatedIngredients': estimatedIngredients,
    'calories': calories,
    'protein': protein,
    'fats': fats,
    'carbs': carbs,
    'confidence': confidence,
    'isApproximate': isApproximate,
  };
}

/// Container for the full menu scan result.
class MenuAnalysisResult {
  final List<MenuDishModel> dishes;

  /// Raw text extracted from the menu image (for debugging / display).
  final String? rawMenuText;

  const MenuAnalysisResult({required this.dishes, this.rawMenuText});

  factory MenuAnalysisResult.fromJson(Map<String, dynamic> json) {
    final dishList = (json['dishes'] as List<dynamic>?)
            ?.whereType<Map<String, dynamic>>()
            .map(MenuDishModel.fromJson)
            .toList() ??
        [];
    return MenuAnalysisResult(
      dishes: dishList,
      rawMenuText: json['rawMenuText'] as String?,
    );
  }

  bool get isEmpty => dishes.isEmpty;
  int get count => dishes.length;
}
