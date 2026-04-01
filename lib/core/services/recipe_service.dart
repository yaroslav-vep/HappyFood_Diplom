import '../../data/models/recipe_model.dart';
import '../../data/models/user_model.dart';
import '../../data/models/product_model.dart';

class RecipeService {
  // Lightweight images: Unsplash with w=400&q=60&fm=webp parameters
  final List<RecipeModel> _allRecipes = [
    // ── BREAKFASTS ──────────────────────────────────────────────────────────
    RecipeModel(
      title: 'Oatmeal with Berries',
      description: 'A nutritious breakfast of rolled oats with fresh berries.',
      ingredients: ['Oats', 'Blueberries', 'Milk', 'Honey'],
      calories: 350,
      protein: 10,
      fats: 6,
      carbs: 60,
      tags: ['breakfast', 'high-carb'],
      imageUrl:
          'https://images.unsplash.com/photo-1517673400267-0251440c45dc?w=400&q=60&fm=webp',
      steps: [
        'Boil milk in a saucepan.',
        'Add oats and reduce heat.',
        'Cook for 5 minutes, stirring occasionally.',
        'Add berries and drizzle with honey.',
      ],
    ),
    RecipeModel(
      title: 'Avocado Toast',
      description: 'Whole-grain toast with mashed avocado and a poached egg.',
      ingredients: ['Bread', 'Avocado', 'Egg', 'Lemon', 'Salt'],
      calories: 450,
      protein: 14,
      fats: 22,
      carbs: 38,
      tags: ['breakfast', 'vegetarian'],
      imageUrl:
          'https://images.unsplash.com/photo-1541519227354-08fa5d50c820?w=400&q=60&fm=webp',
      steps: [
        'Toast the bread until golden brown.',
        'Mash the avocado with salt and lemon juice.',
        'Poach the egg for 3–4 minutes.',
        'Spread the avocado on the toast and place the egg on top.',
      ],
    ),
    RecipeModel(
      title: 'Spinach Omelet',
      description: 'A quick protein-packed breakfast with eggs and greens.',
      ingredients: ['Eggs', 'Spinach', 'Butter', 'Salt', 'Black pepper'],
      calories: 280,
      protein: 18,
      fats: 20,
      carbs: 4,
      tags: ['breakfast', 'high-protein', 'low-carb'],
      imageUrl:
          'https://images.unsplash.com/photo-1510693206972-df098062cb71?w=400&q=60&fm=webp',
      steps: [
        'Melt butter in a pan.',
        'Add spinach and sauté for 1–2 minutes.',
        'Crack eggs into the pan and cook to your desired level.',
        'Season with salt and pepper and serve.',
      ],
    ),
    RecipeModel(
      title: 'Smoothie Bowl',
      description: 'A vibrant bowl of blended frozen fruits topped with nuts and seeds.',
      ingredients: ['Banana', 'Mixed Berries', 'Almond Milk', 'Chia Seeds', 'Granola'],
      calories: 340,
      protein: 8,
      fats: 10,
      carbs: 55,
      tags: ['breakfast', 'snack', 'healthy'],
      imageUrl:
          'https://images.unsplash.com/photo-1590301157890-4810ed352733?w=400&q=60&fm=webp',
      steps: [
        'Blend frozen banana and berries with almond milk.',
        'Pour the thick mixture into a bowl.',
        'Top with granola, chia seeds, and fresh fruit.',
        'Serve immediately while cold.',
      ],
    ),

    // ── LUNCHES ─────────────────────────────────────────────────────────────
    RecipeModel(
      title: 'Chicken Salad',
      description: 'Grilled chicken breast with mixed greens and vegetables.',
      ingredients: [
        'Chicken Breast',
        'Salad Mix',
        'Tomato',
        'Cucumber',
        'Olive Oil',
      ],
      calories: 400,
      protein: 40,
      fats: 15,
      carbs: 8,
      tags: ['lunch', 'high-protein', 'low-carb'],
      imageUrl:
          'https://images.unsplash.com/photo-1512621776951-a57141f2eefd?w=400&q=60&fm=webp',
      steps: [
        'Season chicken breast with salt and pepper.',
        'Grill for 6–7 minutes on each side.',
        'Chop vegetables and greens.',
        'Slice the chicken and toss with the vegetables and oil.',
      ],
    ),
    RecipeModel(
      title: 'Pasta with Tomato Sauce',
      description: 'Classic pasta with homemade tomato sauce.',
      ingredients: ['Pasta', 'Tomatoes', 'Garlic', 'Basil', 'Olive Oil'],
      calories: 580,
      protein: 15,
      fats: 10,
      carbs: 95,
      tags: ['lunch', 'high-carb'],
      imageUrl:
          'https://images.unsplash.com/photo-1473093295043-cdd812d0e601?w=400&q=60&fm=webp',
      steps: [
        'Boil pasta in salted water.',
        'Sauté garlic in olive oil.',
        'Add tomatoes and simmer for 15 minutes.',
        'Toss the pasta with the sauce and basil.',
      ],
    ),
    RecipeModel(
      title: 'Borscht',
      description: 'Hearty beet soup with beef and sour cream.',
      ingredients: [
        'Beets',
        'Beef',
        'Cabbage',
        'Potatoes',
        'Carrots',
        'Sour Cream',
      ],
      calories: 420,
      protein: 24,
      fats: 18,
      carbs: 40,
      tags: ['lunch', 'soup', 'traditional'],
      imageUrl:
          'https://images.unsplash.com/photo-1547592166-23ac45744acd?w=400&q=60&fm=webp',
      steps: [
        'Cook the beef broth.',
        'Add chopped potatoes and cabbage.',
        'Sauté beets and carrots, then add to the broth.',
        'Cook until tender. Serve with a dollop of sour cream.',
      ],
    ),
    RecipeModel(
      title: 'Lagman',
      description: 'Hand-pulled noodles with meat and vegetable stew.',
      ingredients: [
        'Noodles',
        'Beef',
        'Bell Pepper',
        'Tomato',
        'Onion',
        'Potatoes',
      ],
      calories: 580,
      protein: 28,
      fats: 22,
      carbs: 68,
      tags: ['lunch', 'noodles', 'traditional'],
      imageUrl:
          'https://images.unsplash.com/photo-1569050467447-ce54b3bbc37d?w=400&q=60&fm=webp',
      steps: [
        'Boil the noodles separately.',
        'Sauté beef with vegetables and tomato paste.',
        'Add water and simmer until the sauce thickens.',
        'Pour the sauce over the noodles and serve.',
      ],
    ),
    RecipeModel(
      title: 'Quinoa Salad with Chickpeas',
      description: 'Refreshing Mediterranean salad with protein-packed quinoa and chickpeas.',
      ingredients: ['Quinoa', 'Chickpeas', 'Cucumber', 'Cherry Tomatoes', 'Feta Cheese'],
      calories: 380,
      protein: 12,
      fats: 14,
      carbs: 52,
      tags: ['lunch', 'vegetarian', 'healthy'],
      imageUrl:
          'https://images.unsplash.com/photo-1512621776951-a57141f2eefd?w=400&q=60&fm=webp',
      steps: [
        'Rinse and cook quinoa according to package instructions.',
        'Rinse canned chickpeas and chop vegetables.',
        'Mix quinoa, chickpeas, and vegetables in a large bowl.',
        'Crumble feta on top and drizzle with lemon dressing.',
      ],
    ),
    RecipeModel(
      title: 'Lentil Soup with Spinach',
      description: 'A comforting, heart-healthy soup filled with fiber and iron.',
      ingredients: ['Red Lentils', 'Spinach', 'Onion', 'Carrots', 'Cumin'],
      calories: 310,
      protein: 18,
      fats: 4,
      carbs: 48,
      tags: ['lunch', 'soup', 'vegetarian'],
      imageUrl:
          'https://images.unsplash.com/photo-1547592166-23ac45744acd?w=400&q=60&fm=webp',
      steps: [
        'Sauté onions and carrots until soft.',
        'Add lentils and water, bring to a boil.',
        'Simmer for 20 minutes until lentils are tender.',
        'Add fresh spinach at the end and stir until wilted.',
      ],
    ),
    RecipeModel(
      title: 'Greek Salad',
      description: 'A crisp and colorful classic salad with a Mediterranean flare.',
      ingredients: ['Cucumber', 'Tomatoes', 'Red Onion', 'Olives', 'Feta Cheese', 'Olive Oil'],
      calories: 260,
      protein: 6,
      fats: 22,
      carbs: 12,
      tags: ['lunch', 'light', 'vegetarian'],
      imageUrl:
          'https://images.unsplash.com/photo-1540189549336-e6e99c3679fe?w=400&q=60&fm=webp',
      steps: [
        'Chop cucumbers, tomatoes, and red onion into large chunks.',
        'Place in a bowl and add kalamata olives.',
        'Top with a thick slice or cubes of feta cheese.',
        'Drizzle generously with olive oil and sprinkle with dried oregano.',
      ],
    ),

    // ── DINNERS ─────────────────────────────────────────────────────────────
    RecipeModel(
      title: 'Plov (Pilaf)',
      description: 'Traditional aromatic rice pilaf with meat and carrots.',
      ingredients: ['Rice', 'Lamb', 'Carrots', 'Onion', 'Oil', 'Garlic'],
      calories: 750,
      protein: 28,
      fats: 38,
      carbs: 75,
      tags: ['dinner', 'hearty', 'traditional'],
      imageUrl:
          'https://images.unsplash.com/photo-1596797038530-2c107229654b?w=400&q=60&fm=webp',
      steps: [
        'Fry the meat in oil until golden brown.',
        'Add onions and carrots, and sauté until soft.',
        'Add rice and water, cover, and cook.',
        'Insert garlic heads and simmer until done.',
      ],
    ),
    RecipeModel(
      title: 'Steak with Vegetables',
      description: 'Pan-seared steak with steamed vegetables.',
      ingredients: ['Steak', 'Broccoli', 'Carrots', 'Butter'],
      calories: 680,
      protein: 50,
      fats: 34,
      carbs: 12,
      tags: ['dinner', 'high-protein', 'bulk'],
      imageUrl:
          'https://images.unsplash.com/photo-1544025162-d76694265947?w=400&q=60&fm=webp',
      steps: [
        'Gently season the steak with salt and pepper.',
        'Sear in a hot pan for 3–4 minutes per side.',
        'Steam the broccoli and carrots.',
        'Serve the steak with the vegetables.',
      ],
    ),
    RecipeModel(
      title: 'Salmon with Rice',
      description: 'Baked salmon with boiled rice and lemon.',
      ingredients: ['Salmon', 'Rice', 'Lemon', 'Dill', 'Olive Oil'],
      calories: 520,
      protein: 42,
      fats: 20,
      carbs: 38,
      tags: ['dinner', 'fish', 'high-protein'],
      imageUrl:
          'https://images.unsplash.com/photo-1467003909585-2f8a72700288?w=400&q=60&fm=webp',
      steps: [
        'Marinate the salmon in lemon juice and oil.',
        'Bake at 180°C for 15–18 minutes.',
        'Boil the rice.',
        'Serve the salmon with rice, garnished with dill.',
      ],
    ),
    RecipeModel(
      title: 'Chicken Soup',
      description: 'Light chicken soup with noodles and vegetables.',
      ingredients: ['Chicken', 'Noodles', 'Carrots', 'Onion', 'Parsley', 'Salt'],
      calories: 280,
      protein: 22,
      fats: 8,
      carbs: 28,
      tags: ['lunch', 'soup', 'light'],
      imageUrl:
          'https://images.unsplash.com/photo-1603105037880-880cd4edfb0d?w=400&q=60&fm=webp',
      steps: [
        'Boil the chicken in water with onion and carrots.',
        'Remove the chicken and shred into pieces.',
        'Add noodles to the broth and cook for 7 minutes.',
        'Return the chicken, add salt and parsley.',
      ],
    ),
    RecipeModel(
      title: 'Grilled Turkey with Asparagus',
      description: 'Lean turkey breast paired with tender-crisp roasted asparagus.',
      ingredients: ['Turkey Breast', 'Asparagus', 'Garlic', 'Lemon', 'Olive Oil'],
      calories: 420,
      protein: 45,
      fats: 12,
      carbs: 15,
      tags: ['dinner', 'high-protein', 'healthy'],
      imageUrl:
          'https://images.unsplash.com/photo-1432139555190-58524dae6a55?w=400&q=60&fm=webp',
      steps: [
        'Marinate turkey with garlic, lemon, and oil.',
        'Grill turkey until cooked through (7-8 mins per side).',
        'Toss asparagus with oil and roast for 10 minutes.',
        'Serve turkey sliced alongside the asparagus.',
      ],
    ),
    RecipeModel(
      title: 'Buckwheat with Mushrooms',
      description: 'A traditional, earthy and filling meal rich in minerals.',
      ingredients: ['Buckwheat', 'Mushrooms', 'Onions', 'Butter', 'Salt'],
      calories: 390,
      protein: 12,
      fats: 8,
      carbs: 68,
      tags: ['dinner', 'traditional', 'vegetarian'],
      imageUrl:
          'https://images.unsplash.com/photo-1543362906-acfc16c67564?w=400&q=60&fm=webp',
      steps: [
        'Rinse buckwheat and boil until water is absorbed.',
        'Sauté mushrooms and onions in butter until golden.',
        'Mix the mushroom mixture into the cooked buckwheat.',
        'Season with salt and a knob of extra butter.',
      ],
    ),
    RecipeModel(
      title: 'Tofu Stir-fry with Broccoli',
      description: 'Quick and healthy plant-based protein with crunchy vegetables.',
      ingredients: ['Tofu', 'Broccoli', 'Soy Sauce', 'Ginger', 'Sesame Oil'],
      calories: 350,
      protein: 20,
      fats: 18,
      carbs: 30,
      tags: ['dinner', 'vegetarian', 'healthy'],
      imageUrl:
          'https://images.unsplash.com/photo-1512621776951-a57141f2eefd?w=400&q=60&fm=webp',
      steps: [
        'Press tofu to remove moisture and cut into cubes.',
        'Fry tofu until crispy on all sides.',
        'Add broccoli and stir-fry for 3-5 minutes.',
        'Add soy sauce and ginger, toss to coat.',
      ],
    ),

    // ── SNACKS ──────────────────────────────────────────────────────────────
    RecipeModel(
      title: 'Cottage Cheese Pancakes',
      description: 'Tender cottage cheese pancakes - light and tasty.',
      ingredients: ['Cottage Cheese', 'Eggs', 'Semolina', 'Sugar', 'Sour Cream'],
      calories: 320,
      protein: 22,
      fats: 10,
      carbs: 32,
      tags: ['snack', 'dessert', 'high-protein'],
      imageUrl:
          'https://images.unsplash.com/photo-1565958011703-44f9829ba187?w=400&q=60&fm=webp',
      steps: [
        'Mix cottage cheese, eggs, semolina, and sugar.',
        'Pour into a greased baking dish.',
        'Bake at 180°C for 35–40 minutes.',
        'Serve with sour cream.',
      ],
    ),
    RecipeModel(
      title: 'Greek Yogurt with Nuts',
      description: 'Greek yogurt with honey and walnuts.',
      ingredients: ['Greek Yogurt', 'Honey', 'Walnuts'],
      calories: 290,
      protein: 20,
      fats: 12,
      carbs: 24,
      tags: ['snack', 'high-protein'],
      imageUrl:
          'https://images.unsplash.com/photo-1488477181946-6428a029177b?w=400&q=60&fm=webp',
      steps: [
        'Place Greek yogurt in a bowl.',
        'Drizzle with honey.',
        'Sprinkle with crushed walnuts.',
      ],
    ),
    RecipeModel(
      title: 'Banana Smoothie',
      description: 'A nutritious smoothie for a snack or recovery.',
      ingredients: ['Banana', 'Milk', 'Peanut Butter', 'Oats', 'Honey'],
      calories: 380,
      protein: 14,
      fats: 12,
      carbs: 56,
      tags: ['snack', 'smoothie', 'breakfast'],
      imageUrl:
          'https://images.unsplash.com/photo-1553530666-ba11a90bb8ae?w=400&q=60&fm=webp',
      steps: [
        'Place all ingredients in a blender.',
        'Blend until smooth.',
        'Pour into a glass and serve chilled.',
      ],
    ),
    RecipeModel(
      title: 'Chia Pudding with Mango',
      description: 'A light, refreshing, and creamy healthy dessert or snack.',
      ingredients: ['Chia Seeds', 'Coconut Milk', 'Mango', 'Honey', 'Vanilla Extract'],
      calories: 240,
      protein: 6,
      fats: 12,
      carbs: 28,
      tags: ['snack', 'dessert', 'light'],
      imageUrl:
          'https://images.unsplash.com/photo-1488477181946-6428a029177b?w=400&q=60&fm=webp',
      steps: [
        'Mix chia seeds with coconut milk, honey, and vanilla.',
        'Refrigerate for at least 4 hours or overnight.',
        'Top with freshly diced mango cubes.',
        'Enjoy as a healthy snack or light treat.',
      ],
    ),
  ];

  List<RecipeModel> get allRecipes => _allRecipes;

  List<RecipeModel> searchRecipes(String query) {
    if (query.isEmpty) return _allRecipes;
    final q = query.toLowerCase();
    return _allRecipes.where((recipe) {
      return recipe.title.toLowerCase().contains(q) ||
          recipe.description.toLowerCase().contains(q) ||
          recipe.tags.any((t) => t.toLowerCase().contains(q));
    }).toList();
  }

  List<RecipeModel> getRecommendations({
    required UserModel user,
    required List<ProductModel> availableProducts,
    required int maxCalories,
  }) {
    var filtered = _allRecipes;

    // Filter by goal
    if (user.goal == 'Lose Weight') {
      filtered = filtered.where((r) => r.calories < 500).toList();
    } else if (user.goal == 'Gain Weight') {
      filtered = filtered.where((r) => r.calories >= 400).toList();
    }

    // Filter by available products (if specified)
    if (availableProducts.isNotEmpty) {
      final availableNames =
          availableProducts.map((p) => p.name.toLowerCase()).toList();

      final strictMatches = filtered.where((recipe) {
        return recipe.ingredients
            .every((ing) => availableNames.contains(ing.toLowerCase()));
      }).toList();

      if (strictMatches.isNotEmpty) {
        filtered = strictMatches;
      }
    }

    return filtered;
  }
}
