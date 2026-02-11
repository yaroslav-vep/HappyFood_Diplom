class UserModel {
  String gender;
  int age;
  double height; // in cm
  double weight; // in kg
  String activityLevel;
  String goal;
  List<String> allergies;
  List<String> excludedProducts;

  UserModel({
    this.gender = 'Male',
    this.age = 25,
    this.height = 175.0,
    this.weight = 70.0,
    this.activityLevel = 'Moderately Active',
    this.goal = 'Maintenance',
    this.allergies = const [],
    this.excludedProducts = const [],
  });

  UserModel copyWith({
    String? gender,
    int? age,
    double? height,
    double? weight,
    String? activityLevel,
    String? goal,
    List<String>? allergies,
    List<String>? excludedProducts,
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
    );
  }
}
