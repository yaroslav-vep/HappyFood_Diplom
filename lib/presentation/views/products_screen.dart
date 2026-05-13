import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../viewmodels/products_viewmodel.dart';
import '../viewmodels/recipes_viewmodel.dart';
import '../../data/models/product_model.dart';
import '../../data/models/recipe_model.dart';
import '../../core/services/recipe_service.dart';
import 'recipe_detail_screen.dart';
import 'profile_screen.dart';
import '../../core/localization/app_localizations.dart';

class ProductsScreen extends ConsumerStatefulWidget {
  const ProductsScreen({super.key});

  @override
  ConsumerState<ProductsScreen> createState() => _ProductsScreenState();
}

class _ProductsScreenState extends ConsumerState<ProductsScreen> {
  final TextEditingController _controller = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Load recipes from API once — when done, rebuild so matching recipes update
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final recipeService = ref.read(recipeServiceProvider);
      if (!recipeService.isLoaded) {
        recipeService.loadRecipes(onComplete: () {
          if (mounted) setState(() {});
        });
      }
    });
  }

  void _addProduct() {
    if (_controller.text.isNotEmpty) {
      ref
          .read(productsViewModelProvider.notifier)
          .addProduct(_controller.text.trim());
      _controller.clear();
    }
  }

  List<RecipeModel> _getMatchingRecipes(
      List<ProductModel> products, RecipeService recipeService) {
    if (products.isEmpty) return [];
    // Substring matching: "chicken" matches "Chicken Breast", etc.
    final names = products.map((p) => p.name.toLowerCase().trim()).toList();

    bool ingMatchesAny(String ingredient) {
      final lowerIng = ingredient.toLowerCase();
      return names.any((n) => lowerIng.contains(n) || n.contains(lowerIng));
    }

    return recipeService.allRecipes.where((recipe) {
      final matchEng = recipe.ingredients.any(ingMatchesAny);
      final matchRu = recipe.ingredientsRu?.any(ingMatchesAny) ?? false;
      return matchEng || matchRu;
    }).toList()
      ..sort((a, b) {
        final aCount = a.ingredients.where(ingMatchesAny).length;
        final bCount = b.ingredients.where(ingMatchesAny).length;
        return bCount.compareTo(aCount);
      });
  }

  int _countMatched(RecipeModel recipe, Set<String> productNames) {
    // Use substring matching: "chicken" matches "Chicken Breast", etc.
    bool ingMatches(String ing) {
      final lowerIng = ing.toLowerCase();
      return productNames.any((n) => lowerIng.contains(n) || n.contains(lowerIng));
    }

    final engCount = recipe.ingredients.where(ingMatches).length;
    final ruCount = recipe.ingredientsRu?.where(ingMatches).length ?? 0;
    return engCount > ruCount ? engCount : ruCount;
  }

  @override
  Widget build(BuildContext context) {
    final products = ref.watch(productsViewModelProvider);
    // Use the shared RecipeService instance (same one loaded by RecipesViewModel)
    final recipeService = ref.watch(recipeServiceProvider);
    final matchingRecipes = _getMatchingRecipes(products, recipeService);
    final productNames = products.map((p) => p.name.toLowerCase().trim()).toSet();
    final lang = ref.watch(languageProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(tr('myKitchen', lang)),
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
                    // Always use a high-contrast color relative to card background
                    style: TextStyle(
                      color: Theme.of(context).brightness == Brightness.dark
                          ? Colors.white
                          : Colors.black87,
                    ),
                    decoration: InputDecoration(
                      hintText: tr('addProduct', lang),
                      hintStyle: TextStyle(
                        color: Theme.of(context).brightness == Brightness.dark
                            ? Colors.white54
                            : Colors.black38,
                      ),
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
                        Text(
                          tr('addProductsHint', lang),
                          style: const TextStyle(color: Colors.grey, fontSize: 15),
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
                                '${tr('myProducts', lang)} (${products.length})',
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
                                tr('matchingRecipes', lang),
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
                                  Text(
                                    tr('noRecipesWithProducts', lang),
                                    style: const TextStyle(color: Colors.grey),
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
                              final total = recipe.localizedIngredients(lang).length;
                              return _buildRecipeSuggestion(
                                context,
                                recipe,
                                matched,
                                total,
                                lang,
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
    String lang,
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
                            recipe.localizedTitle(lang),
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
                            child: Text(
                              tr('haveAll', lang),
                              style: const TextStyle(
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
                      recipe.localizedDescription(lang),
                      style: TextStyle(
                        color: Theme.of(context).textTheme.bodySmall?.color,
                      ),
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
