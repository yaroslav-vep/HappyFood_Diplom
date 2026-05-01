import 'package:flutter_riverpod/flutter_riverpod.dart';

// ── Global Language Provider — English only ───────────────────────────────────
final languageProvider = StateProvider<String>((ref) => 'ENG');

// ── Helper to get localized string ───────────────────────────────────────────
String tr(String key, String lang) {
  return _allStrings['ENG']?[key] ?? key;
}

// ── All translatable strings (English only) ───────────────────────────────────
const Map<String, Map<String, String>> _allStrings = {
  'ENG': {
    // Login
    'login': 'Login',
    'welcome': 'Welcome Back!',
    'email': 'Email',
    'password': 'Password',
    'loginBtn': 'Login',
    'createAccount': 'Create an account',

    // Register
    'register': 'Register',
    'join': 'Join HappyFood',
    'confirmPassword': 'Confirm Password',
    'registerBtn': 'Register',
    'passwordsMismatch': 'Passwords do not match',

    // Bottom Navigation
    'nutrition': 'Nutrition',
    'kitchen': 'Kitchen',
    'recipes': 'Recipes',

    // Nutrition Screen
    'ofKcal': 'of {target} kcal',
    'exceededBy': 'Exceeded by {val} kcal',
    'kcalLeft': '{val} kcal left',
    'protein': 'Protein',
    'fats': 'Fats',
    'carbs': 'Carbs',
    'todaysMeals': "Today's Meals",
    'items': 'items',
    'noMealsYet': "You haven't eaten anything yet today",
    'openRecipeHint': 'Open a recipe card and press "I Ate This"',
    'resetDiary': 'Reset diary',
    'resetDiaryTitle': 'Reset diary?',
    'resetDiaryContent': 'All meal records for today will be deleted.',
    'cancel': 'Cancel',
    'reset': 'Reset',
    'mealHistory': 'Meal History',
    'noHistory': 'No meal history yet.',
    'clearHistory': 'Clear History',

    // Recipes Screen
    'searchDishes': 'Search dishes...',
    'noRecipesFound': 'No recipes found.',
    'generateRecommendations': 'Generate Recommendations',
    'ingredients': 'Ingredients',

    // Products Screen
    'myKitchen': 'My Kitchen',
    'addProduct': 'Add product (e.g., Eggs)',
    'addProductsHint': 'Add products,\nto see matching recipes',
    'myProducts': 'My Products',
    'matchingRecipes': 'Matching Recipes',
    'noRecipesWithProducts': 'No recipes with these products.\nAdd more!',
    'haveAll': '✓ Have All',

    // Recipe Detail Screen
    'nutritionalValue': 'Nutritional Value (per serving)',
    'calories': 'Calories',
    'have': 'have',
    'cookingSteps': 'Cooking Steps',
    'iAteThis': '✓ I Ate This',
    'addedToDiary': '«{name}» added to nutrition diary!',
    'orderIngredients': 'Order Ingredients',
    'fromRestaurant': 'From Restaurant',
    'ingredientOrdering': 'Ingredient Ordering — Coming Soon!',
    'restaurantOrdering': 'Restaurant Ordering — Coming Soon!',
    'containsAllergens': 'Contains allergens that match your profile!',

    // Profile Screen
    'profile': 'Profile',
    'updatePhoto': 'Update Photo',
    'personalDetails': 'Personal Details',
    'gender': 'Gender',
    'male': 'Male',
    'female': 'Female',
    'other': 'Other',
    'age': 'Age',
    'heightCm': 'H (cm)',
    'weightKg': 'W (kg)',
    'goalActivity': 'Goal & Activity',
    'activityLevel': 'Activity Level',
    'goal': 'Goal',
    'restrictions': 'Restrictions (Allergies)',
    'addIngredient': 'Add ingredient',
    'noAllergies': 'No allergies specified.',
    'language': 'Language',
    'appLanguage': 'App Language',
    'selectAge': 'Select Age',
    'selectHeight': 'Select Height',
    'selectWeight': 'Select Weight',
    'confirm': 'Confirm',

    // Settings Screen
    'settings': 'Settings',
    'darkMode': 'Dark Mode',
    'enabled': 'Enabled',
    'disabled': 'Disabled',
    'aboutApp': 'About HappyFood',
    'version': 'Version 1.0.0',

    // AI Food Analysis
    'aiFoodAnalysis': 'AI Food Analysis',
    'poweredByGemini': 'Powered by Gemini Vision',
    'uploadFoodPhoto': 'Upload food photo',
    'aiWillIdentify': 'AI will identify nutritional values and recipe',
    'analyzingDish': 'Analyzing dish...',
    'geminiScanning': 'Gemini is scanning ingredients',
    'tapToChangePhoto': 'Tap to change photo',
    'pickPhoto': 'Pick Photo',
    'analyze': 'Analyze',
    'analyzing': 'Analyzing...',
    'approximateComposition': 'Approximate composition',
    'howToPrepare': 'How to prepare',
    'addToDiary': 'Add to Diary',
    'addedFromAI': 'Added from AI Analysis',

    // AI Chat
    'aiChat': 'AI Chat',
    'askAboutFood': 'Ask about food...',
  },
};
