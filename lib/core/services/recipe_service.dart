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
    RecipeModel(
      title: 'Shakshuka',
      description: 'Poached eggs in a spicy tomato and pepper sauce, a Middle Eastern favorite.',
      ingredients: ['Eggs', 'Tomatoes', 'Bell Pepper', 'Onion', 'Garlic', 'Cumin'],
      calories: 320,
      protein: 16,
      fats: 18,
      carbs: 12,
      tags: ['breakfast', 'vegetarian', 'spicy'],
      imageUrl:
          'https://images.unsplash.com/photo-1590412200988-a436bbd960bd?w=400&q=60&fm=webp',
      steps: [
        'Sauté onions, peppers, and garlic until soft.',
        'Add tomatoes and spices, simmer for 10 minutes.',
        'Make small wells and crack eggs into the sauce.',
        'Cover and cook until egg whites are set but yolks are runny.',
      ],
    ),
    RecipeModel(
      title: 'Blueberry Pancakes',
      description: 'Fluffy homemade pancakes bursting with fresh blueberries.',
      ingredients: ['Flour', 'Milk', 'Eggs', 'Blueberries', 'Baking Powder', 'Maple Syrup'],
      calories: 480,
      protein: 12,
      fats: 14,
      carbs: 72,
      tags: ['breakfast', 'sweet'],
      imageUrl:
          'https://images.unsplash.com/photo-1567620905732-2d1ec7bb7445?w=400&q=60&fm=webp',
      steps: [
        'Whisk flour, milk, eggs, and baking powder until smooth.',
        'Gently fold in the fresh blueberries.',
        'Pour batter onto a hot greased griddle.',
        'Flip when bubbles form and cook until golden brown.',
      ],
    ),
    RecipeModel(
      title: 'French Toast with Berries',
      description: 'Thick slices of bread soaked in egg custard and toasted to perfection.',
      ingredients: ['Bread', 'Eggs', 'Milk', 'Cinnamon', 'Strawberries', 'Maple Syrup'],
      calories: 420,
      protein: 10,
      fats: 12,
      carbs: 65,
      tags: ['breakfast', 'sweet'],
      imageUrl:
          'https://images.unsplash.com/photo-1484723091739-30a097e8f929?w=400&q=60&fm=webp',
      steps: [
        'Whisk eggs, milk, and cinnamon in a shallow bowl.',
        'Dip bread slices until well-soaked on both sides.',
        'Fry in a buttered pan until golden and crisp.',
        'Serve with fresh strawberries and syrup.',
      ],
    ),
    RecipeModel(
      title: 'Tofu Scramble with Spinach',
      description: 'A savory and protein-rich vegan alternative to scrambled eggs.',
      ingredients: ['Tofu', 'Spinach', 'Turmeric', 'Nutritional Yeast', 'Onion'],
      calories: 220,
      protein: 18,
      fats: 12,
      carbs: 6,
      tags: ['breakfast', 'vegan', 'high-protein'],
      imageUrl:
          'https://images.unsplash.com/photo-1543339308-43e59d6b73a6?w=400&q=60&fm=webp',
      steps: [
        'Crumble tofu into a bowl and mix with turmeric and yeast.',
        'Sauté onions until translucent.',
        'Add tofu and cook for 5 minutes.',
        'Stir in spinach until wilted and serve hot.',
      ],
    ),
    RecipeModel(
      title: 'Breakfast Burrito',
      description: 'A hearty wrap filled with eggs, black beans, and fresh salsa.',
      ingredients: ['Tortilla', 'Eggs', 'Black Beans', 'Avocado', 'Salsa', 'Cheese'],
      calories: 550,
      protein: 24,
      fats: 26,
      carbs: 52,
      tags: ['breakfast', 'hearty'],
      imageUrl:
          'https://images.unsplash.com/photo-1626700051175-6818013e1d4f?w=400&q=60&fm=webp',
      steps: [
        'Scramble eggs in a pan until just set.',
        'Warm the tortilla and fill with eggs and beans.',
        'Add avocado slices, cheese, and salsa.',
        'Fold the burrito and lightly grill on both sides.',
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
    RecipeModel(
      title: 'Tom Yum Soup',
      description: 'Spicy and sour Thai soup with succulent shrimp and aromatic herbs.',
      ingredients: ['Shrimp', 'Mushrooms', 'Lemongrass', 'Galangal', 'Chili', 'Lime juice'],
      calories: 180,
      protein: 18,
      fats: 6,
      carbs: 15,
      tags: ['lunch', 'soup', 'light', 'Thai'],
      imageUrl:
          'https://images.unsplash.com/photo-1548943487-a2e4e43b4853?w=400&q=60&fm=webp',
      steps: [
        'Boil water with lemongrass, galangal, and kaffir lime leaves.',
        'Add mushrooms and chili paste, simmer for 5 minutes.',
        'Add shrimp and cook until pink.',
        'Turn off heat and stir in lime juice and fish sauce.',
      ],
    ),
    RecipeModel(
      title: 'Vietnamese Pho Beef',
      description: 'A deeply flavorful and clear beef broth served with rice noodles and fresh herbs.',
      ingredients: ['Rice Noodles', 'Beef Broth', 'Beef Slices', 'Basil', 'Lime', 'Bean Sprouts'],
      calories: 420,
      protein: 25,
      fats: 8,
      carbs: 60,
      tags: ['lunch', 'soup', 'healthy', 'Vietnamese'],
      imageUrl:
          'https://images.unsplash.com/photo-1582878826629-29b7ad1cdc43?w=400&q=60&fm=webp',
      steps: [
        'Simmer beef bones with ginger and onions for the broth.',
        'Soak rice noodles in warm water until soft.',
        'Place noodles and raw beef slices in a bowl.',
        'Pour boiling broth over the beef to cook it instantly.',
        'Garnish with basil, sprouts, and a squeeze of lime.',
      ],
    ),
    RecipeModel(
      title: 'Caesar Salad',
      description: 'Crisp romaine lettuce with grilled chicken, croutons, and creamy dressing.',
      ingredients: ['Romaine Lettuce', 'Chicken Breast', 'Croutons', 'Parmesan', 'Caesar Dressing'],
      calories: 450,
      protein: 32,
      fats: 28,
      carbs: 18,
      tags: ['lunch', 'high-protein'],
      imageUrl:
          'https://images.unsplash.com/photo-1550304943-4f24f54ddde9?w=400&q=60&fm=webp',
      steps: [
        'Grill chicken breast until cooked through and slice.',
        'Toss romaine lettuce with Caesar dressing and parmesan.',
        'Add sliced chicken and croutons on top.',
        'Serve with an extra sprinkle of parmesan if desired.',
      ],
    ),
    RecipeModel(
      title: 'Tomato Basil Soup',
      description: 'A smooth and comforting soup made with vine-ripened tomatoes and fresh basil.',
      ingredients: ['Tomatoes', 'Basil', 'Onion', 'Garlic', 'Vegetable Broth', 'Cream'],
      calories: 220,
      protein: 4,
      fats: 12,
      carbs: 24,
      tags: ['lunch', 'vegetarian', 'soup'],
      imageUrl:
          'https://images.unsplash.com/photo-1547592115-f98af774965b?w=400&q=60&fm=webp',
      steps: [
        'Sauté onion and garlic in a pot until soft.',
        'Add tomatoes and broth, simmer for 20 minutes.',
        'Blend until smooth and stir in fresh basil and cream.',
        'Serve hot with a side of crusty bread.',
      ],
    ),
    RecipeModel(
      title: 'Turkey Club Sandwich',
      description: 'A classic triple-decker sandwich with turkey, bacon, lettuce, and tomato.',
      ingredients: ['Bread', 'Turkey Breast', 'Bacon', 'Lettuce', 'Tomato', 'Mayo'],
      calories: 580,
      protein: 28,
      fats: 32,
      carbs: 45,
      tags: ['lunch', 'hearty'],
      imageUrl:
          'https://images.unsplash.com/photo-1524339102455-6f4021ca3c17?w=400&q=60&fm=webp',
      steps: [
        'Toast three slices of bread.',
        'Spread mayo and layer turkey, bacon, lettuce, and tomato.',
        'Add the second slice of bread and repeat the layers.',
        'Top with the final slice of bread, secure with toothpicks, and cut into quarters.',
      ],
    ),
    RecipeModel(
      title: 'Buddha Bowl',
      description: 'A nourishing bowl of roasted sweet potatoes, chickpeas, kale, and tahini dressing.',
      ingredients: ['Sweet Potato', 'Chickpeas', 'Kale', 'Quinoa', 'Tahini', 'Lemon'],
      calories: 480,
      protein: 16,
      fats: 18,
      carbs: 65,
      tags: ['lunch', 'vegan', 'healthy'],
      imageUrl:
          'https://images.unsplash.com/photo-1512621776951-a57141f2eefd?w=400&q=60&fm=webp',
      steps: [
        'Roast sweet potato cubes and chickpeas with olive oil and spices.',
        'Massage kale with a bit of lemon juice and oil.',
        'Assemble the bowl with a base of quinoa, topped with veggies.',
        'Drizzle generously with tahini dressing.',
      ],
    ),
    RecipeModel(
      title: 'Tuna Poké Bowl',
      description: 'Fresh raw tuna marinated in soy and ginger, served over rice with colorful toppings.',
      ingredients: ['Raw Tuna', 'Sushi Rice', 'Edamame', 'Radish', 'Seaweed', 'Soy Sauce'],
      calories: 420,
      protein: 34,
      fats: 12,
      carbs: 45,
      tags: ['lunch', 'healthy', 'Japanese'],
      imageUrl:
          'https://images.unsplash.com/photo-1546069901-ba9599a7e63c?w=400&q=60&fm=webp',
      steps: [
        'Cube the tuna and marinate in soy sauce, sesame oil, and ginger.',
        'Prepare sushi rice and place in a bowl.',
        'Arrange marinated tuna, edamame, and vegetables over the rice.',
        'Garnish with seaweed strips and sesame seeds.',
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
    RecipeModel(
      title: 'Salmon Nigiri Set',
      description: 'Fresh slices of premium salmon over perfectly seasoned sushi rice.',
      ingredients: ['Fresh Salmon', 'Sushi Rice', 'Rice Vinegar', 'Wasabi', 'Soy Sauce'],
      calories: 270,
      protein: 20,
      fats: 5,
      carbs: 35,
      tags: ['dinner', 'healthy', 'Japanese'],
      imageUrl:
          'https://images.unsplash.com/photo-1553621042-f6e147245754?w=400&q=60&fm=webp',
      steps: [
        'Season cooked rice with rice vinegar, sugar, and salt.',
        'Form small oblong mounds of rice with wet hands.',
        'Place a thin slice of fresh salmon over each rice mound.',
        'Serve with a side of wasabi and soy sauce.',
      ],
    ),
    RecipeModel(
      title: 'Miso Ramen',
      description: 'Rich miso-based broth with chewy noodles, tender pork, and a soft-boiled egg.',
      ingredients: ['Egg Noodles', 'Miso Paste', 'Sliced Pork', 'Soft-boiled Egg', 'Green Onion'],
      calories: 480,
      protein: 25,
      fats: 12,
      carbs: 65,
      tags: ['dinner', 'hearty', 'Japanese'],
      imageUrl:
          'https://images.unsplash.com/photo-1569718212165-3a8278d5f624?w=400&q=60&fm=webp',
      steps: [
        'Prepare the ramen broth by dissolving miso paste in hot dashi.',
        'Cook ramen noodles separately until al dente.',
        'Pan-fry the pork slices until golden.',
        'Assemble the bowl: noodles, broth, pork, and half a soft-boiled egg.',
      ],
    ),
    RecipeModel(
      title: 'Pad Thai',
      description: 'The iconic Thai stir-fried noodle dish with a perfect balance of sweet, sour, and salty.',
      ingredients: ['Rice Noodles', 'Shrimp', 'Peanuts', 'Bean Sprouts', 'Tofu', 'Egg'],
      calories: 550,
      protein: 22,
      fats: 18,
      carbs: 75,
      tags: ['dinner', 'high-carb', 'Thai'],
      imageUrl:
          'https://images.unsplash.com/photo-1559311648-d46f4d8593d8?w=400&q=60&fm=webp',
      steps: [
        'Soak rice noodles in water for 30 minutes.',
        'Stir-fry shrimp and tofu in a hot wok.',
        'Push to the side, scramble an egg, then add noodles and sauce.',
        'Toss with bean sprouts and crushed peanuts before serving.',
      ],
    ),
    RecipeModel(
      title: 'Beef Bibimbap',
      description: 'A colorful Korean rice bowl topped with seasoned vegetables, meat, and a spicy sauce.',
      ingredients: ['Rice', 'Beef', 'Egg', 'Carrots', 'Spinach', 'Gochujang Sauce'],
      calories: 580,
      protein: 28,
      fats: 15,
      carbs: 80,
      tags: ['dinner', 'healthy', 'Korean'],
      imageUrl:
          'https://images.unsplash.com/photo-1590301157890-4810ed352733?w=400&q=60&fm=webp',
      steps: [
        'Sauté beef and individual vegetables separately with sesame oil.',
        'Place a bed of warm rice in a bowl.',
        'Arrange the vegetables and meat in sections over the rice.',
        'Top with a fried egg and a dollop of spicy gochujang sauce.',
      ],
    ),
    RecipeModel(
      title: 'Chicken Teriyaki Bowl',
      description: 'Juicy chicken glazed in a sweet teriyaki sauce over steamed rice and broccoli.',
      ingredients: ['Chicken Breast', 'Soy Sauce', 'Ginger', 'Broccoli', 'Rice', 'Honey'],
      calories: 420,
      protein: 38,
      fats: 10,
      carbs: 45,
      tags: ['dinner', 'high-protein', 'Japanese'],
      imageUrl:
          'https://images.unsplash.com/photo-1585032226651-759b368d7246?w=400&q=60&fm=webp',
      steps: [
        'Cook chicken in a pan until golden brown.',
        'Add soy sauce, ginger, and honey, and simmer until sauce thickens.',
        'Steam broccoli and rice separately.',
        'Serve chicken over rice, drizzled with the remaining sauce.',
      ],
    ),
    RecipeModel(
      title: 'Kung Pao Chicken',
      description: 'A classic Sichuan dish with chicken, peanuts, and a spicy, savory sauce.',
      ingredients: ['Chicken Cubes', 'Peanuts', 'Bell Pepper', 'Dried Chili', 'Soy Sauce'],
      calories: 420,
      protein: 35,
      fats: 22,
      carbs: 20,
      tags: ['dinner', 'high-protein', 'Chinese'],
      imageUrl:
          'https://images.unsplash.com/photo-1525755662778-989d0524087e?w=400&q=60&fm=webp',
      steps: [
        'Stir-fry dried chilies and peppercorns in oil until fragrant.',
        'Add chicken and sear until cooked.',
        'Add white parts of green onions and peanuts.',
        'Stir in the sauce and cook until it thickens and coats everything.',
      ],
    ),
    RecipeModel(
      title: 'Beef Stir-fry',
      description: 'Tender strips of beef stir-fried with crunchy snap peas and a savory soy-ginger sauce.',
      ingredients: ['Beef Flank Steak', 'Snap Peas', 'Bell Pepper', 'Soy Sauce', 'Ginger', 'Garlic'],
      calories: 420,
      protein: 38,
      fats: 18,
      carbs: 22,
      tags: ['dinner', 'high-protein', 'healthy'],
      imageUrl:
          'https://images.unsplash.com/photo-1512058560566-d8d4c7a48d20?w=400&q=60&fm=webp',
      steps: [
        'Thinly slice beef against the grain and marinate in soy sauce and ginger.',
        'Heat oil in a wok and sear beef until browned, then remove.',
        'Stir-fry snap peas and peppers for 3 minutes.',
        'Add beef back to the wok with garlic and remaining sauce, toss to combine.',
      ],
    ),
    RecipeModel(
      title: 'Spaghetti Carbonara',
      description: 'A classic Italian pasta dish made with eggs, cheese, pancetta, and black pepper.',
      ingredients: ['Spaghetti', 'Eggs', 'Pecorino Romano', 'Pancetta', 'Black Pepper'],
      calories: 620,
      protein: 24,
      fats: 32,
      carbs: 58,
      tags: ['dinner', 'traditional'],
      imageUrl:
          'https://images.unsplash.com/photo-1612874742237-6526221588e3?w=400&q=60&fm=webp',
      steps: [
        'Boil spaghetti in salted water until al dente.',
        'Fry pancetta until crispy in a large pan.',
        'Whisk eggs and cheese in a bowl.',
        'Toss pasta with pancetta, remove from heat, and quickly stir in the egg mixture to create a creamy sauce.',
      ],
    ),
    RecipeModel(
      title: 'Roast Chicken with Vegetables',
      description: 'Succulent chicken thighs roasted with carrots, potatoes, and aromatic herbs.',
      ingredients: ['Chicken Thighs', 'Potatoes', 'Carrots', 'Rosemary', 'Garlic', 'Olive Oil'],
      calories: 550,
      protein: 42,
      fats: 28,
      carbs: 32,
      tags: ['dinner', 'hearty', 'healthy'],
      imageUrl:
          'https://images.unsplash.com/photo-1598515214211-89d3c73ae83b?w=400&q=60&fm=webp',
      steps: [
        'Toss chopped potatoes and carrots with olive oil, salt, and rosemary.',
        'Season chicken thighs and place on a baking sheet with the vegetables.',
        'Roast at 200°C for 35-40 minutes until chicken is golden and veggies are tender.',
        'Let the chicken rest for 5 minutes before serving.',
      ],
    ),
    RecipeModel(
      title: 'Vegetable Lasagna',
      description: 'Layers of pasta with roasted vegetables, marinara sauce, and melted mozzarella.',
      ingredients: ['Lasagna Sheets', 'Zucchini', 'Eggplant', 'Spinach', 'Marinara Sauce', 'Mozzarella'],
      calories: 480,
      protein: 18,
      fats: 22,
      carbs: 52,
      tags: ['dinner', 'vegetarian'],
      imageUrl:
          'https://images.unsplash.com/photo-1551183053-bf91a1d81141?w=400&q=60&fm=webp',
      steps: [
        'Sauté spinach and roast sliced zucchini and eggplant.',
        'Layer lasagna sheets with sauce, roasted vegetables, and cheese in a baking dish.',
        'Repeat layers and top with a generous amount of mozzarella.',
        'Bake at 180°C for 30 minutes until bubbly and golden.',
      ],
    ),
    RecipeModel(
      title: 'Grilled Sea Bass',
      description: 'Fresh sea bass fillet grilled with lemon and served with roasted asparagus.',
      ingredients: ['Sea Bass Fillet', 'Asparagus', 'Lemon', 'Olive Oil', 'Garlic'],
      calories: 320,
      protein: 38,
      fats: 14,
      carbs: 8,
      tags: ['dinner', 'fish', 'light', 'healthy'],
      imageUrl:
          'https://images.unsplash.com/photo-1467003909585-2f8a72700288?w=400&q=60&fm=webp',
      steps: [
        'Season sea bass with lemon juice, garlic, and olive oil.',
        'Grill the fillet for 4-5 minutes on each side until it flakes easily.',
        'Toss asparagus with oil and grill alongside the fish for 5-6 minutes.',
        'Serve hot with extra lemon wedges.',
      ],
    ),
    RecipeModel(
      title: 'Shorpo',
      description: 'A traditional Central Asian rich lamb soup with potatoes and carrots.',
      ingredients: ['Lamb on the bone', 'Potatoes', 'Carrots', 'Onion', 'Bell Pepper', 'Fresh Herbs'],
      calories: 450,
      protein: 26,
      fats: 25,
      carbs: 30,
      tags: ['soup', 'traditional', 'dinner', 'Asian'],
      imageUrl: 'https://images.unsplash.com/photo-1547592166-23ac45744acd?w=400&q=60&fm=webp',
      steps: [
        'Boil the lamb on slow heat for 1.5 - 2 hours, skimming the foam.',
        'Add roughly chopped carrots and onions.',
        'Add large chunks of potatoes and bell peppers.',
        'Simmer until vegetables are tender, garnish with fresh herbs.',
      ],
    ),
    RecipeModel(
      title: 'Manti',
      description: 'Steamed dumplings filled with spiced meat and onions, a staple in Central Asian cuisine.',
      ingredients: ['Flour', 'Water', 'Minced Beef or Lamb', 'Onion', 'Black Pepper', 'Cumin'],
      calories: 550,
      protein: 24,
      fats: 18,
      carbs: 72,
      tags: ['dinner', 'traditional', 'Asian', 'dumplings'],
      imageUrl: 'https://images.unsplash.com/photo-1525755662778-989d0524087e?w=400&q=60&fm=webp',
      steps: [
        'Prepare a simple dough and let it rest.',
        'Mix minced meat with finely chopped onions, salt, pepper, and cumin.',
        'Roll out the dough, cut into squares, and fill with the meat mixture.',
        'Steam in a special steamer (mantovarka) for 40-45 minutes.',
      ],
    ),
    RecipeModel(
      title: 'Beshbarmak',
      description: 'A festive dish consisting of boiled meat served over flat noodles with a savory onion broth.',
      ingredients: ['Beef or Lamb', 'Flour', 'Eggs', 'Onion', 'Black Pepper', 'Broth'],
      calories: 680,
      protein: 45,
      fats: 28,
      carbs: 62,
      tags: ['dinner', 'festive', 'traditional', 'Asian'],
      imageUrl: 'https://images.unsplash.com/photo-1555126634-323283e090fa?w=400&q=60&fm=webp',
      steps: [
        'Boil the meat until very tender (2-3 hours).',
        'Prepare the dough, roll it out thinly, and cut into large squares.',
        'Cook the dough squares in the meat broth.',
        'Serve the noodles topped with sliced meat and a hot onion sauce (chyk).',
      ],
    ),
    RecipeModel(
      title: 'Kuurdak',
      description: 'A hearty roasted meat dish, usually made with mutton or beef, onions, and potatoes.',
      ingredients: ['Beef or Mutton', 'Potatoes', 'Onion', 'Garlic', 'Oil', 'Spices'],
      calories: 620,
      protein: 38,
      fats: 35,
      carbs: 38,
      tags: ['dinner', 'meat', 'hearty', 'Asian'],
      imageUrl: 'https://images.unsplash.com/photo-1604908176997-125f25cc6f3d?w=400&q=60&fm=webp',
      steps: [
        'Cut the meat into medium pieces and fry in a kazan (cauldron) until browned.',
        'Add sliced onions and garlic, fry until soft.',
        'Add chunks of potatoes and a little water or broth.',
        'Cover and simmer until the potatoes are cooked and the meat is tender.',
      ],
    ),
    RecipeModel(
      title: 'Samsa',
      description: 'Oven-baked pastry filled with savory meat, onions, and spices.',
      ingredients: ['Puff Pastry', 'Minced Beef', 'Onion', 'Cumin', 'Egg (for wash)'],
      calories: 380,
      protein: 14,
      fats: 22,
      carbs: 32,
      tags: ['lunch', 'snack', 'baked', 'Asian'],
      imageUrl: 'https://images.unsplash.com/photo-1601050690597-df0568f70950?w=400&q=60&fm=webp',
      steps: [
        'Mix minced meat with finely chopped onions and cumin.',
        'Roll out pieces of puff pastry and place a spoonful of filling in the center.',
        'Fold into triangles and seal the edges.',
        'Brush with egg wash and bake until golden brown.',
      ],
    ),
    RecipeModel(
      title: 'Chuchvara (Pelmeni)',
      description: 'Small meat dumplings boiled in a rich broth, similar to ravioli.',
      ingredients: ['Flour', 'Eggs', 'Minced Meat', 'Onion', 'Broth', 'Sour Cream'],
      calories: 420,
      protein: 22,
      fats: 15,
      carbs: 48,
      tags: ['soup', 'dumplings', 'traditional', 'Asian'],
      imageUrl: 'https://images.unsplash.com/photo-1582878826629-29b7ad1cdc43?w=400&q=60&fm=webp',
      steps: [
        'Make the dough and mix the filling (meat and onions).',
        'Form small dumplings.',
        'Boil in a flavorful meat broth until they float to the top.',
        'Serve hot with broth, topped with herbs and sour cream.',
      ],
    ),
    RecipeModel(
      title: 'Shashlik',
      description: 'Marinated meat grilled on skewers over open coals.',
      ingredients: ['Lamb or Beef', 'Onion', 'Vinegar or Mineral Water', 'Spices', 'Coriander'],
      calories: 350,
      protein: 30,
      fats: 22,
      carbs: 8,
      tags: ['dinner', 'BBQ', 'meat', 'Asian'],
      imageUrl: 'https://images.unsplash.com/photo-1555939594-58d7cb561ad1?w=400&q=60&fm=webp',
      steps: [
        'Cut meat into cubes and marinate with onions, spices, and a little acid (vinegar).',
        'Let it rest for at least 4 hours.',
        'Thread the meat onto skewers.',
        'Grill over hot coals, turning frequently until cooked through.',
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
    RecipeModel(
      title: 'Sashimi Set',
      description: 'Pure, fresh slices of raw seafood for the ultimate protein-packed light meal.',
      ingredients: ['Salmon', 'Tuna', 'White Fish', 'Soy Sauce', 'Wasabi', 'Ginger'],
      calories: 220,
      protein: 42,
      fats: 5,
      carbs: 2,
      tags: ['snack', 'light', 'high-protein', 'Japanese'],
      imageUrl:
          'https://images.unsplash.com/photo-1534482421-3d055c43d938?w=400&q=60&fm=webp',
      steps: [
        'Slice the freshest seafood into bite-sized pieces.',
        'Arrange beautifully on a platter with shredded radish.',
        'Serve with small portions of wasabi and pickled ginger.',
        'Dip lightly in soy sauce and enjoy.',
      ],
    ),
    RecipeModel(
      title: 'Hummus with Veggie Sticks',
      description: 'Creamy chickpeas dip served with fresh, crunchy carrot and cucumber sticks.',
      ingredients: ['Hummus', 'Carrots', 'Cucumber', 'Olive Oil', 'Paprika'],
      calories: 180,
      protein: 6,
      fats: 10,
      carbs: 18,
      tags: ['snack', 'vegan', 'healthy'],
      imageUrl:
          'https://images.unsplash.com/photo-1574071318508-1cdbad80ad38?w=400&q=60&fm=webp',
      steps: [
        'Slice carrots and cucumbers into long, thin sticks.',
        'Place hummus in a small bowl and drizzle with olive oil and a pinch of paprika.',
        'Arrange the veggie sticks on a plate around the hummus.',
        'Dip and enjoy as a light, nutritious snack.',
      ],
    ),
    RecipeModel(
      title: 'Apple Slices with Peanut Butter',
      description: 'A satisfying and sweet snack that combines crisp apples with creamy peanut butter.',
      ingredients: ['Apple', 'Peanut Butter', 'Cinnamon'],
      calories: 240,
      protein: 7,
      fats: 16,
      carbs: 22,
      tags: ['snack', 'sweet', 'healthy'],
      imageUrl:
          'https://images.unsplash.com/photo-1610307595766-02e079717651?w=400&q=60&fm=webp',
      steps: [
        'Core and slice a fresh apple into wedges.',
        'Serve with a side of natural peanut butter.',
        'Optional: Sprinkle a little cinnamon over the apple slices for extra flavor.',
      ],
    ),
    RecipeModel(
      title: 'Dark Chocolate Strawberries',
      description: 'Fresh strawberries dipped in rich, melted dark chocolate for a healthy-ish treat.',
      ingredients: ['Strawberries', 'Dark Chocolate (70% or more)'],
      calories: 150,
      protein: 2,
      fats: 8,
      carbs: 18,
      tags: ['snack', 'dessert', 'light'],
      imageUrl:
          'https://images.unsplash.com/photo-1549007994-cb92caebd54b?w=400&q=60&fm=webp',
      steps: [
        'Melt dark chocolate in a bowl using a microwave or double boiler.',
        'Dip clean, dry strawberries into the melted chocolate till halfway coated.',
        'Place on parchment paper and refrigerate until the chocolate sets.',
        'Enjoy as a light and sophisticated dessert or snack.',
      ],
    ),
    RecipeModel(
      title: 'Almonds and Dried Apricots',
      description: 'A quick and portable energy-boosting mix of crunchy almonds and chewy apricots.',
      ingredients: ['Almonds', 'Dried Apricots'],
      calories: 280,
      protein: 8,
      fats: 18,
      carbs: 26,
      tags: ['snack', 'healthy', 'energy'],
      imageUrl:
          'https://images.unsplash.com/photo-1536592205567-340798e3b7b3?w=400&q=60&fm=webp',
      steps: [
        'Measure out a handful of raw almonds and a few dried apricots.',
        'Combine in a small bowl or portable container.',
        'This snack is rich in healthy fats, fiber, and vitamins.',
      ],
    ),
    RecipeModel(
      title: 'Caprese Skewers',
      description: 'Bite-sized versions of the classic Italian salad with cherry tomatoes, mozzarella, and basil.',
      ingredients: ['Cherry Tomatoes', 'Bocconcini (Mini Mozzarella)', 'Fresh Basil', 'Balsamic Glaze'],
      calories: 160,
      protein: 10,
      fats: 12,
      carbs: 4,
      tags: ['snack', 'vegetarian', 'light'],
      imageUrl:
          'https://images.unsplash.com/photo-1596701062351-8c2c14d1fdd0?w=400&q=60&fm=webp',
      steps: [
        'Thread a cherry tomato, a basil leaf, and a small mozzarella ball onto a toothpick.',
        'Repeat until all ingredients are used.',
        'Drizzle lightly with balsamic glaze before serving.',
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
