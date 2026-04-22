import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../data/models/user_model.dart';

class UserViewModel extends StateNotifier<UserModel> {
  UserViewModel([UserModel? initialUser]) : super(initialUser ?? UserModel()) {
    if (initialUser == null) {
      _loadUser();
    }
  }

  static const String _storageKey = 'user_data';

  Future<void> _loadUser() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userDataString = prefs.getString(_storageKey);
      if (userDataString != null) {
        final Map<String, dynamic> userMap = jsonDecode(userDataString);
        state = UserModel.fromJson(userMap);
      }
    } catch (e) {
      // Handle error or use default
      print('Error loading user data: $e');
    }
  }

  Future<void> _saveUser(UserModel user) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userDataString = jsonEncode(user.toJson());
      await prefs.setString(_storageKey, userDataString);
    } catch (e) {
      print('Error saving user data: $e');
    }
  }

  void updateUser(UserModel user) {
    state = user;
    _saveUser(state);
  }

  void updateGender(String gender) {
    state = state.copyWith(gender: gender);
    _recalculateStats();
  }

  void updateAge(int age) {
    state = state.copyWith(age: age);
    _recalculateStats();
  }

  void updateHeight(double height) {
    state = state.copyWith(height: height);
    _recalculateStats();
  }

  void updateWeight(double weight) {
    state = state.copyWith(weight: weight);
    _recalculateStats();
  }

  void updateActivityLevel(String level) {
    state = state.copyWith(activityLevel: level);
    _recalculateStats();
  }

  void updateGoal(String goal) {
    state = state.copyWith(goal: goal);
    _recalculateStats();
  }

  void _recalculateStats() {
    final bmi = state.calculateBMI();
    final calories = state.calculateDailyCalories();

    state = state.copyWith(bmi: bmi, dailyCalorieNeeds: calories);
    _saveUser(state);
  }

  void updateAllergies(List<String> allergies) {
    state = state.copyWith(allergies: allergies);
    _saveUser(state);
  }

  void updateExcludedProducts(List<String> products) {
    state = state.copyWith(excludedProducts: products);
    _saveUser(state);
  }

  void updateAvatarPath(String? path) {
    if (path == null) {
      state = state.copyWith(clearAvatar: true);
    } else {
      state = state.copyWith(avatarPath: path);
    }
    _saveUser(state);
  }
}

final userViewModelProvider = StateNotifierProvider<UserViewModel, UserModel>((
  ref,
) {
  return UserViewModel();
});
