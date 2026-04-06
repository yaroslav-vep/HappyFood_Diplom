import 'package:flutter_riverpod/flutter_riverpod.dart';

// ── Global Language Provider ─────────────────────────────────────────────────
final languageProvider = StateProvider<String>((ref) => 'ENG');

// ── Helper to get localized string ───────────────────────────────────────────
String tr(String key, String lang) {
  return _allStrings[lang]?[key] ?? _allStrings['ENG']?[key] ?? key;
}

// ── All translatable strings ─────────────────────────────────────────────────
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
  'RU': {
    // Login
    'login': 'Вход',
    'welcome': 'Добро пожаловать!',
    'email': 'Электронная почта',
    'password': 'Пароль',
    'loginBtn': 'Войти',
    'createAccount': 'Создать аккаунт',

    // Register
    'register': 'Регистрация',
    'join': 'Присоединяйтесь к HappyFood',
    'confirmPassword': 'Подтвердите пароль',
    'registerBtn': 'Зарегистрироваться',
    'passwordsMismatch': 'Пароли не совпадают',

    // Bottom Navigation
    'nutrition': 'Питание',
    'kitchen': 'Кухня',
    'recipes': 'Рецепты',

    // Nutrition Screen
    'ofKcal': 'из {target} ккал',
    'exceededBy': 'Превышено на {val} ккал',
    'kcalLeft': 'Осталось {val} ккал',
    'protein': 'Белки',
    'fats': 'Жиры',
    'carbs': 'Углеводы',
    'todaysMeals': 'Сегодняшние блюда',
    'items': 'шт.',
    'noMealsYet': 'Вы ещё ничего не ели сегодня',
    'openRecipeHint': 'Откройте рецепт и нажмите «Я это съел»',
    'resetDiary': 'Сбросить дневник',
    'resetDiaryTitle': 'Сбросить дневник?',
    'resetDiaryContent': 'Все записи о еде за сегодня будут удалены.',
    'cancel': 'Отмена',
    'reset': 'Сбросить',

    // Recipes Screen
    'searchDishes': 'Поиск блюд...',
    'noRecipesFound': 'Рецепты не найдены.',
    'generateRecommendations': 'Создать рекомендации',
    'ingredients': 'Ингредиенты',

    // Products Screen
    'myKitchen': 'Моя кухня',
    'addProduct': 'Добавить продукт (напр., Яйца)',
    'addProductsHint': 'Добавьте продукты,\nчтобы увидеть подходящие рецепты',
    'myProducts': 'Мои продукты',
    'matchingRecipes': 'Подходящие рецепты',
    'noRecipesWithProducts': 'Нет рецептов с этими продуктами.\nДобавьте ещё!',
    'haveAll': '✓ Все есть',

    // Recipe Detail Screen
    'nutritionalValue': 'Пищевая ценность (на порцию)',
    'calories': 'Калории',
    'have': 'есть',
    'cookingSteps': 'Шаги приготовления',
    'iAteThis': '✓ Я это съел',
    'addedToDiary': '«{name}» добавлено в дневник питания!',
    'orderIngredients': 'Заказать ингредиенты',
    'fromRestaurant': 'Из ресторана',
    'ingredientOrdering': 'Заказ ингредиентов — Скоро!',
    'restaurantOrdering': 'Заказ из ресторана — Скоро!',
    'containsAllergens': 'Содержит аллергены из вашего профиля!',

    // Profile Screen
    'profile': 'Профиль',
    'updatePhoto': 'Обновить фото',
    'personalDetails': 'Личные данные',
    'gender': 'Пол',
    'male': 'Мужской',
    'female': 'Женский',
    'other': 'Другой',
    'age': 'Возраст',
    'heightCm': 'Рост(см)',
    'weightKg': 'Вес(кг)',
    'goalActivity': 'Цель и активность',
    'activityLevel': 'Уровень активности',
    'goal': 'Цель',
    'restrictions': 'Ограничения (Аллергии)',
    'addIngredient': 'Добавить ингредиент',
    'noAllergies': 'Аллергии не указаны.',
    'language': 'Язык',
    'appLanguage': 'Язык приложения',
    'selectAge': 'Выберите возраст',
    'selectHeight': 'Выберите рост',
    'selectWeight': 'Выберите вес',
    'confirm': 'Подтвердить',

    // Settings Screen
    'settings': 'Настройки',
    'darkMode': 'Тёмная тема',
    'enabled': 'Включена',
    'disabled': 'Выключена',
    'aboutApp': 'О HappyFood',
    'version': 'Версия 1.0.0',

    // AI Food Analysis
    'aiFoodAnalysis': 'AI Анализ еды',
    'poweredByGemini': 'На основе Gemini Vision',
    'uploadFoodPhoto': 'Загрузите фото еды',
    'aiWillIdentify': 'ИИ определит пищевую ценность и рецепт',
    'analyzingDish': 'Анализ блюда...',
    'geminiScanning': 'Gemini сканирует ингредиенты',
    'tapToChangePhoto': 'Нажмите для смены фото',
    'pickPhoto': 'Выбрать фото',
    'analyze': 'Анализ',
    'analyzing': 'Анализ...',
    'approximateComposition': 'Примерный состав',
    'howToPrepare': 'Как приготовить',
    'addToDiary': 'Добавить в дневник',
    'addedFromAI': 'Добавлено из AI анализа',

    // AI Chat
    'aiChat': 'AI Чат',
    'askAboutFood': 'Спросить о еде...',
  },
};
