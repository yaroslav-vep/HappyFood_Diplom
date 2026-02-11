import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/user_model.dart';

class UserViewModel extends StateNotifier<UserModel> {
  UserViewModel() : super(UserModel());

  void updateGender(String gender) {
    state = state.copyWith(gender: gender);
  }

  void updateAge(int age) {
    state = state.copyWith(age: age);
  }

  void updateHeight(double height) {
    state = state.copyWith(height: height);
  }

  void updateWeight(double weight) {
    state = state.copyWith(weight: weight);
  }

  void updateActivityLevel(String level) {
    state = state.copyWith(activityLevel: level);
  }

  void updateGoal(String goal) {
    state = state.copyWith(goal: goal);
  }

  void updateAllergies(List<String> allergies) {
    state = state.copyWith(allergies: allergies);
  }

  void updateExcludedProducts(List<String> products) {
    state = state.copyWith(excludedProducts: products);
  }
}

final userViewModelProvider = StateNotifierProvider<UserViewModel, UserModel>((
  ref,
) {
  return UserViewModel();
});
