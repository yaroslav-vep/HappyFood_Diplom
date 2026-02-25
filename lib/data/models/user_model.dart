class UserModel {
  String gender;
  int age;
  double height; // in cm
  double weight; // in kg
  String activityLevel;
  String goal;
  List<String> allergies;
  List<String> excludedProducts;
  double? targetWeight; // Target weight for lose/gain goals
  bool isOnboardingCompleted; // Track onboarding completion
  double? bmi; // Calculated BMI
  double? dailyCalorieNeeds; // Estimated daily calories

  UserModel({
    this.gender = 'Male',
    this.age = 25,
    this.height = 175.0,
    this.weight = 70.0,
    this.activityLevel = 'Moderately Active',
    this.goal = 'Maintain Weight',
    this.allergies = const [],
    this.excludedProducts = const [],
    this.targetWeight,
    this.isOnboardingCompleted = false,
    this.bmi,
    this.dailyCalorieNeeds,
  }) {
    // Auto-calculate on creation if data available
    if (weight > 0 && height > 0) {
      bmi = calculateBMI();
    }
    if (weight > 0 && height > 0 && age > 0) {
      dailyCalorieNeeds = calculateDailyCalories();
    }
  }

  /// Calculate BMI: weight (kg) / height (m)²
  double calculateBMI() {
    if (weight <= 0 || height <= 0) return 0.0;
    final heightInMeters = height / 100;
    return weight / (heightInMeters * heightInMeters);
  }

  /// Get BMI category
  String getBMICategory() {
    final bmiValue = bmi ?? calculateBMI();
    if (bmiValue < 18.5) return 'Underweight';
    if (bmiValue < 25) return 'Healthy';
    if (bmiValue < 30) return 'Overweight';
    return 'Obese';
  }

  /// Calculate daily calorie needs using Mifflin-St Jeor equation
  double calculateDailyCalories() {
    if (weight <= 0 || height <= 0 || age <= 0) return 0.0;

    // Calculate BMR (Basal Metabolic Rate)
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
        activityMultiplier = 1.55; // Default to moderately active
    }

    double dailyCalories = bmr * activityMultiplier;

    // Adjust for goals
    if (goal.toLowerCase().contains('lose')) {
      dailyCalories -= 400; // Safe deficit (300-500 range)
    } else if (goal.toLowerCase().contains('gain')) {
      dailyCalories += 400; // Safe surplus (300-500 range)
    }
    // Maintain weight: no change

    return dailyCalories;
  }

  UserModel copyWith({
    String? gender,
    int? age,
    double? height,
    double? weight,
    String? activityLevel,
    String? goal,
    List<String>? allergies,
    List<String>? excludedProducts,
    double? targetWeight,
    bool? isOnboardingCompleted,
    double? bmi,
    double? dailyCalorieNeeds,
  }) {
    return UserModel(
      gender: gender ?? this.gender,
      age: age ?? this.age,
      height: height ?? this.height,
      weight: weight ?? this.weight,
      activityLevel: activityLevel ?? this.activityLevel,
      goal: goal ?? this.goal,
      allergies: allergies ?? this.allergies,
      excludedProducts: excludedProducts ?? this.excludedProducts,
      targetWeight: targetWeight ?? this.targetWeight,
      isOnboardingCompleted:
          isOnboardingCompleted ?? this.isOnboardingCompleted,
      bmi: bmi ?? this.bmi,
      dailyCalorieNeeds: dailyCalorieNeeds ?? this.dailyCalorieNeeds,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'gender': gender,
      'age': age,
      'height': height,
      'weight': weight,
      'activityLevel': activityLevel,
      'goal': goal,
      'allergies': allergies,
      'excludedProducts': excludedProducts,
      'targetWeight': targetWeight,
      'isOnboardingCompleted': isOnboardingCompleted,
      'bmi': bmi,
      'dailyCalorieNeeds': dailyCalorieNeeds,
    };
  }

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      gender: json['gender'] ?? 'Male',
      age: json['age'] ?? 25,
      height: (json['height'] ?? 175.0).toDouble(),
      weight: (json['weight'] ?? 70.0).toDouble(),
      activityLevel: json['activityLevel'] ?? 'Moderately Active',
      goal: json['goal'] ?? 'Maintain Weight',
      allergies: List<String>.from(json['allergies'] ?? []),
      excludedProducts: List<String>.from(json['excludedProducts'] ?? []),
      targetWeight: (json['targetWeight'] ?? 0.0).toDouble() == 0.0
          ? null
          : (json['targetWeight'] ?? 0.0).toDouble(),
      isOnboardingCompleted: json['isOnboardingCompleted'] ?? false,
      bmi: (json['bmi'] ?? 0.0).toDouble() == 0.0
          ? null
          : (json['bmi'] ?? 0.0).toDouble(),
      dailyCalorieNeeds: (json['dailyCalorieNeeds'] ?? 0.0).toDouble() == 0.0
          ? null
          : (json['dailyCalorieNeeds'] ?? 0.0).toDouble(),
    );
  }
}
