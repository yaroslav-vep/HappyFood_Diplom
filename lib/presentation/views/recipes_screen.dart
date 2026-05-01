import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../viewmodels/recipes_viewmodel.dart';
import '../viewmodels/user_viewmodel.dart';
import '../../data/models/recipe_model.dart';
import 'recipe_detail_screen.dart';
import '../../core/constant/app_theme.dart';
import 'profile_screen.dart';
import '../../core/localization/app_localizations.dart';

// Provider to track whether the API is still loading
final isLoadingRecipesProvider = StateProvider<bool>((ref) => true);

class RecipesScreen extends ConsumerStatefulWidget {
  const RecipesScreen({super.key});

  @override
  ConsumerState<RecipesScreen> createState() => _RecipesScreenState();
}

class _RecipesScreenState extends ConsumerState<RecipesScreen> {
  final TextEditingController _searchController = TextEditingController();

  // Allergen keyword expansion map: allergen name → related ingredient keywords
  static const Map<String, List<String>> _allergenKeywords = {
    'dairy': ['milk', 'cheese', 'butter', 'cream', 'yogurt', 'lactose', 'whey', 'casein', 'молоко', 'сыр', 'масло', 'сливки', 'йогурт'],
    'gluten': ['wheat', 'flour', 'bread', 'pasta', 'barley', 'rye', 'semolina', 'пшеница', 'мука', 'хлеб', 'паста', 'ячмень', 'рожь'],
    'nuts': ['nut', 'almond', 'cashew', 'walnut', 'pecan', 'pistachio', 'hazelnut', 'орех', 'миндаль', 'кешью', 'фундук'],
    'eggs': ['egg', 'яйцо', 'яйца'],
    'shellfish': ['shrimp', 'crab', 'lobster', 'prawn', 'scallop', 'krevetka', 'краб', 'омар', 'креветка'],
    'soy': ['soy', 'tofu', 'edamame', 'miso', 'соя', 'тофу', 'эдамаме', 'мисо'],
    'fish': ['fish', 'salmon', 'tuna', 'cod', 'tilapia', 'рыба', 'лосось', 'тунец', 'треска'],
    'wheat': ['wheat', 'flour', 'пшеница', 'мука'],
  };

  /// Returns true ONLY if the recipe contains a REQUIRED ingredient matching the user's allergen.
  /// If the allergenic ingredient is optional (can be removed), returns false.
  bool _checkAllergies(RecipeModel recipe, List<String> userAllergies) {
    if (userAllergies.isEmpty) return false;

    for (int i = 0; i < recipe.ingredients.length; i++) {
      // Only flag REQUIRED ingredients — optional ones can be skipped safely
      if (recipe.isOptional(i)) continue;

      final ing = recipe.ingredients[i].toLowerCase();

      for (final allergy in userAllergies) {
        final lowerAllergy = allergy.toLowerCase();
        // Direct match
        if (ing.contains(lowerAllergy)) return true;
        // Keyword expansion
        final keywords = _allergenKeywords[lowerAllergy];
        if (keywords != null && keywords.any((kw) => ing.contains(kw))) {
          return true;
        }
      }
    }
    return false;
  }

  bool _isRefreshing = false;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    // Mark loading complete once recipes are available
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkLoaded();
    });
    
    _scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 200) {
      final viewModel = ref.read(recipesViewModelProvider.notifier);
      if (viewModel.hasMore) {
        viewModel.loadMore();
      }
    }
  }

  void _checkLoaded() {
    final service = ref.read(recipeServiceProvider);
    if (service.isLoaded) {
      if (mounted) ref.read(isLoadingRecipesProvider.notifier).state = false;
    } else {
      Future.delayed(const Duration(milliseconds: 500), () {
        if (mounted) _checkLoaded();
      });
    }
  }

  Future<void> _onRefresh() async {
    setState(() => _isRefreshing = true);
    ref.read(isLoadingRecipesProvider.notifier).state = true;
    await ref.read(recipesViewModelProvider.notifier).refresh();
    if (mounted) {
      ref.read(isLoadingRecipesProvider.notifier).state = false;
      setState(() => _isRefreshing = false);
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final recipes = ref.watch(recipesViewModelProvider);
    final viewModel = ref.read(recipesViewModelProvider.notifier);
    final user = ref.watch(userViewModelProvider);
    final lang = ref.watch(languageProvider);
    final isLoading = ref.watch(isLoadingRecipesProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(tr('recipes', lang)),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(60),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
            child: TextField(
              controller: _searchController,
              style: TextStyle(
                color: Theme.of(context).brightness == Brightness.dark
                    ? Colors.white
                    : Colors.black87,
              ),
              decoration: InputDecoration(
                hintText: tr('searchDishes', lang),
                prefixIcon: const Icon(Icons.search),
                filled: true,
                fillColor: Theme.of(context).cardColor,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
              onChanged: (value) {
                viewModel.search(value);
              },
            ),
          ),
        ),
        centerTitle: false,
        actions: [
          if (_isRefreshing)
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 12),
              child: SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            )
          else
            IconButton(
              icon: const Icon(Icons.refresh),
              tooltip: 'Refresh from DB',
              onPressed: _onRefresh,
            ),
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
      body: isLoading && recipes.isEmpty
          // Show shimmer skeleton while loading
          ? _buildLoadingSkeleton(context)
          : recipes.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.restaurant_menu,
                        size: 64,
                        color: Colors.grey[400],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        tr('noRecipesFound', lang),
                        style: const TextStyle(color: Colors.grey),
                      ),
                      const SizedBox(height: 20),
                      ElevatedButton.icon(
                        onPressed: _onRefresh,
                        icon: const Icon(Icons.refresh),
                        label: const Text('Load Recipes'),
                      ),
                    ],
                  ),
                )
              : Column(
                  children: [
                    // Banner shown while background loading is in progress
                    if (isLoading)
                      Container(
                        color: AppTheme.primaryColor.withValues(alpha: 0.08),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 8),
                        child: Row(
                          children: [
                            const SizedBox(
                              width: 14,
                              height: 14,
                              child: CircularProgressIndicator(
                                  strokeWidth: 1.5),
                            ),
                            const SizedBox(width: 10),
                            Text(
                              'Loading recipes from database…',
                              style: TextStyle(
                                  fontSize: 12,
                                  color: AppTheme.primaryColor),
                            ),
                          ],
                        ),
                      ),
                    Expanded(
                      child: RefreshIndicator(
                        onRefresh: _onRefresh,
                        color: AppTheme.primaryColor,
                        child: ListView.builder(
                          controller: _scrollController,
                          padding: const EdgeInsets.all(16),
                          itemCount: recipes.length + (viewModel.hasMore ? 1 : 0),
                          itemBuilder: (context, index) {
                            if (index == recipes.length) {
                              return const Padding(
                                padding: EdgeInsets.symmetric(vertical: 24),
                                child: Center(
                                  child: CircularProgressIndicator(),
                                ),
                              );
                            }

                            final recipe = recipes[index];
                            final isAllergic =
                                _checkAllergies(recipe, user.allergies);
                            return _buildRecipeCard(
                                context, recipe, isAllergic, lang);
                          },
                        ),
                      ),
                    ),
                  ],
                ),
    );
  }

  // ── Loading skeleton shimmer ─────────────────────────────────────────────
  Widget _buildLoadingSkeleton(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: 5,
      itemBuilder: (_, __) => _SkeletonCard(),
    );
  }

  Widget _buildRecipeCard(
    BuildContext context,
    RecipeModel recipe,
    bool isAllergic,
    String lang,
  ) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) =>
                RecipeDetailScreen(recipe: recipe, isAllergic: isAllergic),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 20),
        decoration: BoxDecoration(
          color: isAllergic
              ? const Color(0xFFFFF5F3)
              : Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(16),
          border: isAllergic
              ? Border.all(
                  color: AppTheme.errorColor,
                  width: 1.5,
                )
              : null,
          boxShadow: [
            BoxShadow(
              color: AppTheme.primaryColor.withOpacity(0.04),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image
            Container(
              height: 200,
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.grey[800],
                image: DecorationImage(
                  image: NetworkImage(recipe.imageUrl),
                  fit: BoxFit.cover,
                  onError: (exception, stackTrace) {},
                ),
              ),
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.transparent,
                      Colors.black.withValues(alpha: 0.7),
                    ],
                  ),
                ),
                alignment: Alignment.bottomLeft,
                padding: const EdgeInsets.all(20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        recipe.localizedTitle(lang),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 22,
                          fontWeight: FontWeight.w600,
                          shadows: [Shadow(color: Colors.black, blurRadius: 4)],
                        ),
                      ),
                    ),
                    if (isAllergic)
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: AppTheme.errorColor,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.warning,
                          color: Colors.white,
                          size: 20,
                        ),
                      ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.flash_on,
                        size: 16,
                        color: Theme.of(context).primaryColor,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${recipe.calories} kcal',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          color: Theme.of(context).primaryColor,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Text(
                        '${tr('protein', lang).substring(0, 1)}: ${recipe.protein}g  ${tr('fats', lang).substring(0, 1)}: ${recipe.fats}g  ${tr('carbs', lang).substring(0, 1)}: ${recipe.carbs}g',
                        style: TextStyle(
                          color: AppTheme.textSecondary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    recipe.localizedDescription(lang),
                    style: TextStyle(
                      color: AppTheme.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    '${tr('ingredients', lang)}: ${recipe.localizedIngredients(lang).take(3).join(", ")}${recipe.localizedIngredients(lang).length > 3 ? "..." : ""}',
                    style: TextStyle(
                      color: AppTheme.textTertiary,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Animated skeleton card shown while recipes are loading from the API.
class _SkeletonCard extends StatefulWidget {
  @override
  State<_SkeletonCard> createState() => _SkeletonCardState();
}

class _SkeletonCardState extends State<_SkeletonCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _anim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);
    _anim = Tween<double>(begin: 0.3, end: 0.7).animate(
      CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  Widget _box({double w = double.infinity, double h = 14, double r = 8}) {
    return AnimatedBuilder(
      animation: _anim,
      builder: (_, __) => Container(
        width: w,
        height: h,
        margin: const EdgeInsets.only(bottom: 8),
        decoration: BoxDecoration(
          color: Colors.grey.withValues(alpha: _anim.value),
          borderRadius: BorderRadius.circular(r),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Image placeholder
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
            child: AnimatedBuilder(
              animation: _anim,
              builder: (_, __) => Container(
                height: 200,
                color: Colors.grey.withValues(alpha: _anim.value),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _box(h: 18, r: 6),
                _box(w: 200),
                const SizedBox(height: 4),
                _box(h: 12),
                _box(h: 12, w: 260),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
