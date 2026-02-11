import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/nutrition_model.dart';
import 'user_viewmodel.dart';

class NutritionViewModel extends StateNotifier<NutritionModel> {
  final Ref _ref;

  NutritionViewModel(this._ref)
    : super(NutritionModel(calories: 0, protein: 0, fats: 0, carbs: 0)) {
    // Listen to user changes to auto-recalculate
    _ref.listen<Object?>(userViewModelProvider, (previous, next) {
      calculateNeeds();
    });
  }

  void calculateNeeds() {
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

    // Macros (Simple Split: 30% P, 35% C, 35% F for example, or standard 40/30/30)
    // Let's use 30% Protein, 30% Fat, 40% Carbs
    int calories = tdee.round();
    int protein = ((calories * 0.30) / 4).round();
    int fats = ((calories * 0.30) / 9).round();
    int carbs = ((calories * 0.40) / 4).round();

    state = NutritionModel(
      calories: calories,
      protein: protein,
      fats: fats,
      carbs: carbs,
    );
  }
}

final nutritionViewModelProvider =
    StateNotifierProvider<NutritionViewModel, NutritionModel>((ref) {
      final vm = NutritionViewModel(ref);
      // Initial calculation
      vm.calculateNeeds();
      return vm;
    });
