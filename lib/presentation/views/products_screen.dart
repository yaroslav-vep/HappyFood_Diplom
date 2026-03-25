import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../viewmodels/products_viewmodel.dart';
import '../../data/models/product_model.dart';
import '../../data/models/recipe_model.dart';
import '../../core/services/recipe_service.dart';
import 'recipe_detail_screen.dart';
import 'profile_screen.dart';

class ProductsScreen extends ConsumerStatefulWidget {
  const ProductsScreen({super.key});

  @override
  ConsumerState<ProductsScreen> createState() => _ProductsScreenState();
}

class _ProductsScreenState extends ConsumerState<ProductsScreen> {
  final TextEditingController _controller = TextEditingController();
  final RecipeService _recipeService = RecipeService();

  void _addProduct() {
    if (_controller.text.isNotEmpty) {
      ref
          .read(productsViewModelProvider.notifier)
          .addProduct(_controller.text.trim());
      _controller.clear();
    }
  }

  List<RecipeModel> _getMatchingRecipes(List<ProductModel> products) {
    if (products.isEmpty) return [];
    final names = products.map((p) => p.name.toLowerCase()).toSet();
    return _recipeService.allRecipes.where((recipe) {
      // Show recipe if at least one ingredient matches
      return recipe.ingredients.any(
        (ing) => names.contains(ing.toLowerCase()),
      );
    }).toList()
      ..sort((a, b) {
        // Sort by number of matching ingredients (more = better)
        final aMatches = a.ingredients
            .where((ing) => names.contains(ing.toLowerCase()))
            .length;
        final bMatches = b.ingredients
            .where((ing) => names.contains(ing.toLowerCase()))
            .length;
        return bMatches.compareTo(aMatches);
      });
  }

  int _countMatched(RecipeModel recipe, Set<String> productNames) {
    return recipe.ingredients
        .where((ing) => productNames.contains(ing.toLowerCase()))
        .length;
  }

  @override
  Widget build(BuildContext context) {
    final products = ref.watch(productsViewModelProvider);
    final matchingRecipes = _getMatchingRecipes(products);
    final productNames = products.map((p) => p.name.toLowerCase()).toSet();

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Kitchen'),
        centerTitle: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.account_circle_outlined),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const ProfileScreen()),
              );
            },
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Column(
        children: [
          // Input area
          Container(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
            color: Theme.of(context).scaffoldBackgroundColor,
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      hintText: 'Добавить продукт (например, Яйца)',
                      hintStyle: const TextStyle(color: Colors.grey),
                      filled: true,
                      fillColor: Theme.of(context).cardColor,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                      prefixIcon: Icon(
                        Icons.add,
                        color: Theme.of(context).primaryColor,
                      ),
                    ),
                    onSubmitted: (_) => _addProduct(),
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  decoration: BoxDecoration(
                    color: Theme.of(context).primaryColor,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: IconButton(
                    onPressed: _addProduct,
                    icon: const Icon(Icons.arrow_forward, color: Colors.white),
                  ),
                ),
              ],
            ),
          ),

          Expanded(
            child: products.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.kitchen,
                          size: 64,
                          color: Colors.grey[800],
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          'Добавьте продукты,\nчтобы увидеть подходящие блюда',
                          style: TextStyle(color: Colors.grey, fontSize: 15),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  )
                : CustomScrollView(
                    slivers: [
                      // Products chips
                      SliverToBoxAdapter(
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Мои продукты (${products.length})',
                                style: Theme.of(context).textTheme.titleMedium,
                              ),
                              const SizedBox(height: 8),
                              Wrap(
                                spacing: 8,
                                runSpacing: 8,
                                children: products.map((product) {
                                  return Chip(
                                    label: Text(product.name),
                                    deleteIcon: const Icon(
                                      Icons.close,
                                      size: 16,
                                    ),
                                    onDeleted: () {
                                      ref
                                          .read(
                                            productsViewModelProvider.notifier,
                                          )
                                          .removeProduct(product.name);
                                    },
                                    backgroundColor:
                                        Theme.of(context).primaryColor.withOpacity(0.15),
                                    labelStyle: TextStyle(
                                      color: Theme.of(context).primaryColor,
                                      fontWeight: FontWeight.w600,
                                    ),
                                    deleteIconColor:
                                        Theme.of(context).primaryColor,
                                    side: BorderSide(
                                      color: Theme.of(context)
                                          .primaryColor
                                          .withOpacity(0.4),
                                    ),
                                  );
                                }).toList(),
                              ),
                              const SizedBox(height: 20),
                            ],
                          ),
                        ),
                      ),

                      // Recipe suggestions header
                      SliverToBoxAdapter(
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                          child: Row(
                            children: [
                              Text(
                                'Подходящие блюда',
                                style: Theme.of(context).textTheme.titleMedium,
                              ),
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 3,
                                ),
                                decoration: BoxDecoration(
                                  color: Theme.of(context).primaryColor,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  '${matchingRecipes.length}',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      // Recipes list
                      if (matchingRecipes.isEmpty)
                        SliverToBoxAdapter(
                          child: Padding(
                            padding: const EdgeInsets.all(24),
                            child: Center(
                              child: Column(
                                children: [
                                  Icon(
                                    Icons.search_off,
                                    size: 48,
                                    color: Colors.grey[600],
                                  ),
                                  const SizedBox(height: 12),
                                  const Text(
                                    'Нет блюд с этими продуктами.\nДобавьте ещё!',
                                    style: TextStyle(color: Colors.grey),
                                    textAlign: TextAlign.center,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        )
                      else
                        SliverList(
                          delegate: SliverChildBuilderDelegate(
                            (context, index) {
                              final recipe = matchingRecipes[index];
                              final matched =
                                  _countMatched(recipe, productNames);
                              final total = recipe.ingredients.length;
                              return _buildRecipeSuggestion(
                                context,
                                recipe,
                                matched,
                                total,
                              );
                            },
                            childCount: matchingRecipes.length,
                          ),
                        ),

                      const SliverToBoxAdapter(child: SizedBox(height: 20)),
                    ],
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecipeSuggestion(
    BuildContext context,
    RecipeModel recipe,
    int matched,
    int total,
  ) {
    final matchRatio = matched / total;
    final hasAll = matched == total;

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => RecipeDetailScreen(recipe: recipe),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.fromLTRB(16, 0, 16, 12),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(16),
          border: hasAll
              ? Border.all(
                  color: Theme.of(context).primaryColor,
                  width: 1.5,
                )
              : null,
        ),
        child: Row(
          children: [
            // Image
            ClipRRect(
              borderRadius: const BorderRadius.horizontal(
                left: Radius.circular(16),
              ),
              child: Image.network(
                recipe.imageUrl,
                width: 90,
                height: 90,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(
                  width: 90,
                  height: 90,
                  color: Colors.grey[800],
                  child: const Icon(Icons.restaurant, color: Colors.grey),
                ),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            recipe.title,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 15,
                            ),
                          ),
                        ),
                        if (hasAll)
                          Container(
                            margin: const EdgeInsets.only(right: 12),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 3,
                            ),
                            decoration: BoxDecoration(
                              color: Theme.of(context).primaryColor,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Text(
                              '✓ Всё есть',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${recipe.calories} ккал  •  Б:${recipe.protein}г  Ж:${recipe.fats}г  У:${recipe.carbs}г',
                      style: const TextStyle(color: Colors.grey, fontSize: 12),
                    ),
                    const SizedBox(height: 8),
                    // Ingredient match bar
                    Row(
                      children: [
                        Expanded(
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(4),
                            child: LinearProgressIndicator(
                              value: matchRatio,
                              backgroundColor:
                                  Colors.grey.withOpacity(0.2),
                              color: hasAll
                                  ? Theme.of(context).primaryColor
                                  : Colors.orange,
                              minHeight: 5,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          '$matched/$total',
                          style: TextStyle(
                            fontSize: 12,
                            color: hasAll
                                ? Theme.of(context).primaryColor
                                : Colors.orange,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(width: 12),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
