import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/user_model.dart';
import 'user_viewmodel.dart';

// Onboarding state
class OnboardingState {
  final int
  currentStep; // 0-3 (0: Basic Info, 1: Goals, 2: Preferences, 3: Summary)
  final int age;
  final String gender;
  final double weight;
  final double height;
  final String goal;
  final String activityLevel;
  final double? targetWeight;
  final List<String> allergies;

  OnboardingState({
    this.currentStep = 0,
    this.age = 25,
    this.gender = 'Male',
    this.weight = 70.0,
    this.height = 175.0,
    this.goal = '',
    this.activityLevel = '',
    this.targetWeight,
    this.allergies = const [],
  });

  OnboardingState copyWith({
    int? currentStep,
    int? age,
    String? gender,
    double? weight,
    double? height,
    String? goal,
    String? activityLevel,
    double? targetWeight,
    List<String>? allergies,
  }) {
    return OnboardingState(
      currentStep: currentStep ?? this.currentStep,
      age: age ?? this.age,
      gender: gender ?? this.gender,
      weight: weight ?? this.weight,
      height: height ?? this.height,
      goal: goal ?? this.goal,
      activityLevel: activityLevel ?? this.activityLevel,
      targetWeight: targetWeight ?? this.targetWeight,
      allergies: allergies ?? this.allergies,
    );
  }

  /// Get progress percentage (0.0 to 1.0)
  double get progressPercentage {
    switch (currentStep) {
      case 0:
        return 0.33;
      case 1:
        return 0.66;
      case 2:
        return 1.0;
      case 3:
        return 1.0; // Summary step also shows 100%
      default:
        return 0.0;
    }
  }

  /// Get step indicator text
  String get stepIndicatorText {
    if (currentStep < 3) {
      return 'Step ${currentStep + 1} of 3';
    }
    return 'Summary';
  }

  /// Calculate BMI
  double get bmi {
    if (weight <= 0 || height <= 0) return 0.0;
    final heightInMeters = height / 100;
    return weight / (heightInMeters * heightInMeters);
  }

  /// Get BMI category
  String get bmiCategory {
    if (bmi < 18.5) return 'Underweight';
    if (bmi < 25) return 'Healthy';
    if (bmi < 30) return 'Overweight';
    return 'Obese';
  }

  /// Calculate daily calorie needs
  double get dailyCalories {
    if (weight <= 0 || height <= 0 || age <= 0) return 0.0;

    // Calculate BMR
    double bmr;
    if (gender.toLowerCase() == 'male') {
      bmr = (10 * weight) + (6.25 * height) - (5 * age) + 5;
    } else {
      bmr = (10 * weight) + (6.25 * height) - (5 * age) - 161;
    }

    // Apply activity multiplier
    double activityMultiplier;
    switch (activityLevel.toLowerCase()) {
      case 'sedentary':
        activityMultiplier = 1.2;
        break;
      case 'moderately active':
        activityMultiplier = 1.55;
        break;
      case 'very active':
        activityMultiplier = 1.725;
        break;
      case 'extremely active':
        activityMultiplier = 1.9;
        break;
      default:
        activityMultiplier = 1.55;
    }

    double calories = bmr * activityMultiplier;

    // Adjust for goals
    if (goal.toLowerCase().contains('lose')) {
      calories -= 400;
    } else if (goal.toLowerCase().contains('gain')) {
      calories += 400;
    }

    return calories;
  }

  /// Get calorie explanation text
  String get calorieExplanation {
    final calories = dailyCalories.round();
    return 'Based on your data and activity level, your recommended daily intake is $calories kcal.';
  }

  /// Check if current step is valid
  bool get isStepValid {
    switch (currentStep) {
      case 0:
        // Basic info validation
        // Age: 12-100
        // Weight: 30-250 kg
        // Height: 120-220 cm
        final isAgeValid = age >= 12 && age <= 100;
        final isWeightValid = weight >= 30 && weight <= 250;
        final isHeightValid = height >= 120 && height <= 220;
        return isAgeValid && isWeightValid && isHeightValid;
      case 1:
        // Goals: goal and activity must be selected
        // Target weight validation if set (must be reasonable)
        bool isTargetWeightValid = true;
        if (targetWeight != null) {
          // Prevent extreme target weights (e.g. < 30kg or > 250kg)
          isTargetWeightValid = targetWeight! >= 30 && targetWeight! <= 250;
        }
        return goal.isNotEmpty &&
            activityLevel.isNotEmpty &&
            isTargetWeightValid;
      case 2:
        // Preferences: optional, always valid
        return true;
      case 3:
        // Summary: always valid
        return true;
      default:
        return false;
    }
  }
}

// ViewModel
class OnboardingViewModel extends StateNotifier<OnboardingState> {
  final Ref ref;

  OnboardingViewModel(this.ref) : super(OnboardingState());

  void updateAge(int age) {
    state = state.copyWith(age: age);
  }

  void updateGender(String gender) {
    state = state.copyWith(gender: gender);
  }

  void updateWeight(double weight) {
    state = state.copyWith(weight: weight);
  }

  void updateHeight(double height) {
    state = state.copyWith(height: height);
  }

  void updateGoal(String goal) {
    state = state.copyWith(goal: goal);
  }

  void updateActivityLevel(String activityLevel) {
    state = state.copyWith(activityLevel: activityLevel);
  }

  void updateTargetWeight(double? targetWeight) {
    state = state.copyWith(targetWeight: targetWeight);
  }

  void updateAllergies(List<String> allergies) {
    state = state.copyWith(allergies: allergies);
  }

  void addAllergy(String allergy) {
    if (allergy.trim().isEmpty) return;
    final updatedAllergies = [...state.allergies, allergy.trim()];
    state = state.copyWith(allergies: updatedAllergies);
  }

  void removeAllergy(String allergy) {
    final updatedAllergies = state.allergies
        .where((a) => a != allergy)
        .toList();
    state = state.copyWith(allergies: updatedAllergies);
  }

  /// Move to next step (with validation)
  bool nextStep() {
    if (!state.isStepValid) return false;
    if (state.currentStep < 3) {
      state = state.copyWith(currentStep: state.currentStep + 1);
      return true;
    }
    return false;
  }

  /// Move to previous step
  void previousStep() {
    if (state.currentStep > 0) {
      state = state.copyWith(currentStep: state.currentStep - 1);
    }
  }

  /// Submit onboarding and save to user profile
  Future<void> submitOnboarding() async {
    // Get user view model
    final userViewModel = ref.read(userViewModelProvider.notifier);

    // Create updated user with onboarding data
    final updatedUser = UserModel(
      age: state.age,
      gender: state.gender,
      weight: state.weight,
      height: state.height,
      goal: state.goal,
      activityLevel: state.activityLevel,
      targetWeight: state.targetWeight,
      allergies: state.allergies,
      isOnboardingCompleted: true,
    );

    // Update user
    userViewModel.updateUser(updatedUser);
  }
}

// Provider
final onboardingViewModelProvider =
    StateNotifierProvider.autoDispose<OnboardingViewModel, OnboardingState>((
      ref,
    ) {
      return OnboardingViewModel(ref);
    });
