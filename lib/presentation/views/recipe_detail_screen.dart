import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import '../../data/models/recipe_model.dart';
import '../viewmodels/nutrition_viewmodel.dart';
import '../../core/localization/app_localizations.dart';

class RecipeDetailScreen extends ConsumerStatefulWidget {
  final RecipeModel recipe;
  final bool isAllergic;

  const RecipeDetailScreen({
    super.key,
    required this.recipe,
    this.isAllergic = false,
  });

  @override
  ConsumerState<RecipeDetailScreen> createState() => _RecipeDetailScreenState();
}

class _RecipeDetailScreenState extends ConsumerState<RecipeDetailScreen>
    with SingleTickerProviderStateMixin {
  // Tracks which ingredients are "available" (checked off by user)
  late Set<int> _availableIngredients;

  // AI suggestion state
  String? _aiSuggestion;
  bool _aiLoading = false;
  bool _aiRequested = false;

  late AnimationController _warningAnim;

  // AI proxy URL
  static const _aiUrl =
      'https://ai-proxy-server-production-5ebf.up.railway.app/chat';

  @override
  void initState() {
    super.initState();
    // By default all ingredients are "available"
    _availableIngredients = Set.from(
      List.generate(widget.recipe.ingredients.length, (i) => i),
    );
    _warningAnim = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
  }

  @override
  void dispose() {
    _warningAnim.dispose();
    super.dispose();
  }

  void _toggleIngredient(int index) {
    setState(() {
      if (_availableIngredients.contains(index)) {
        _availableIngredients.remove(index);
      } else {
        _availableIngredients.add(index);
      }
      _aiSuggestion = null;
      _aiRequested = false;
    });
    if (_missingRequiredCount > 0) {
      _warningAnim.forward(from: 0);
    }
  }

  // ── State helpers ─────────────────────────────────────────────────────────

  List<int> get _missingIndices {
    return List.generate(
      widget.recipe.ingredients.length,
      (i) => i,
    ).where((i) => !_availableIngredients.contains(i)).toList();
  }

  int get _missingRequiredCount =>
      _missingIndices.where((i) => widget.recipe.isRequired(i)).length;

  bool get _canCook => _missingRequiredCount == 0;

  /// Returns cooking steps.
  /// For MealDB recipes the instructions are generic ("mix all ingredients")
  /// and don't name each ingredient, so keyword filtering is unreliable.
  /// Instead we always return all steps and show a disclaimer banner
  /// listing which ingredients are missing.
  List<String> _getAdaptedSteps(String lang) {
    return widget.recipe.localizedSteps(lang);
  }


  // ── AI Suggestion ─────────────────────────────────────────────────────────

  Future<void> _getAiSuggestion() async {
    setState(() {
      _aiLoading = true;
      _aiRequested = true;
      _aiSuggestion = null;
    });

    final available = _availableIngredients
        .map((i) => widget.recipe.ingredients[i])
        .join(', ');

    final prompt =
        'I want to cook "${widget.recipe.title}" but I\'m missing some required '
        'ingredients. I only have: $available. '
        'Please suggest 2-3 simple dishes I can make with these ingredients. '
        'Be concise, use bullet points, answer in the same language the user expects '
        '(detect from ingredient names).';

    try {
      http.Response? response;

      // Retry up to 2 times for server-side errors (503/502/504 = server waking up)
      for (int attempt = 1; attempt <= 2; attempt++) {
        response = await http
            .post(
              Uri.parse(_aiUrl),
              headers: {'Content-Type': 'application/json'},
              body: jsonEncode({'message': prompt}),
            )
            .timeout(const Duration(seconds: 30));

        if (response.statusCode == 200 ||
            ![502, 503, 504].contains(response.statusCode)) {
          break; // success or non-retryable error
        }

        if (attempt < 2) {
          await Future.delayed(const Duration(seconds: 3)); // wait before retry
        }
      }

      if (response == null) {
        setState(() {
          _aiSuggestion = 'Server unavailable. Please try again in a moment.';
          _aiLoading = false;
        });
        return;
      }

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          _aiSuggestion =
              data['reply'] as String? ??
              'Sorry, I could not generate suggestions.';
          _aiLoading = false;
        });
      } else if (response.statusCode == 503 ||
          response.statusCode == 502 ||
          response.statusCode == 504) {
        setState(() {
          _aiSuggestion =
              'The AI server is warming up — please wait a few seconds and try again.';
          _aiLoading = false;
        });
      } else {
        setState(() {
          _aiSuggestion = 'Error ${response!.statusCode}. Please try again.';
          _aiLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _aiSuggestion = 'Network error. Check your connection.';
        _aiLoading = false;
      });
    }
  }

  // ── Logging ───────────────────────────────────────────────────────────────

  void _logMeal() {
    final lang = ref.read(languageProvider);
    ref.read(nutritionViewModelProvider.notifier).addEatenMeal(widget.recipe);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle, color: Colors.white),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                tr(
                  'addedToDiary',
                  lang,
                ).replaceAll('{name}', widget.recipe.localizedTitle(lang)),
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
            ),
          ],
        ),
        backgroundColor: Colors.green[700],
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  // ── Build ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final recipe = widget.recipe;
    final isAllergic = widget.isAllergic;
    final lang = ref.watch(languageProvider);
    final adaptedSteps = _getAdaptedSteps(lang);

    return Scaffold(
      appBar: AppBar(
        title: Text(recipe.localizedTitle(lang)),
        backgroundColor: isAllergic
            ? Colors.red[900]
            : Theme.of(context).scaffoldBackgroundColor,
      ),
      backgroundColor: isAllergic
          ? Colors.red[50]!.withValues(alpha: 0.05)
          : Theme.of(context).scaffoldBackgroundColor,
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Hero Image ────────────────────────────────────────────────
            Stack(
              children: [
                Container(
                  height: 300,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.grey[800],
                    image: recipe.imageUrl.isNotEmpty
                        ? DecorationImage(
                            image: NetworkImage(recipe.imageUrl),
                            fit: BoxFit.cover,
                          )
                        : null,
                  ),
                  child: recipe.imageUrl.isEmpty
                      ? const Center(
                          child: Icon(
                            Icons.room_service_outlined,
                            size: 100,
                            color: Colors.grey,
                          ),
                        )
                      : null,
                ),
                Container(
                  height: 300,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.transparent,
                        Theme.of(context).scaffoldBackgroundColor,
                      ],
                    ),
                  ),
                ),
                if (isAllergic)
                  Positioned(
                    bottom: 20,
                    left: 20,
                    right: 20,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        vertical: 10,
                        horizontal: 20,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.red,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.warning, color: Colors.white),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              tr('containsAllergens', lang),
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),

            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title & description
                  Text(
                    recipe.localizedTitle(lang),
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      color: Theme.of(context).primaryColor,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    recipe.localizedDescription(lang),
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                  const SizedBox(height: 30),

                  // ── Nutrition info ───────────────────────────────────────
                  _buildSectionTitle(context, tr('nutritionalValue', lang)),
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildInfoColumn(
                        context,
                        tr('calories', lang),
                        '${recipe.calories}',
                        'kcal',
                        Colors.orange,
                      ),
                      _buildInfoColumn(
                        context,
                        tr('protein', lang),
                        '${recipe.protein}',
                        'g',
                        Colors.blue,
                      ),
                      _buildInfoColumn(
                        context,
                        tr('fats', lang),
                        '${recipe.fats}',
                        'g',
                        Colors.yellow,
                      ),
                      _buildInfoColumn(
                        context,
                        tr('carbs', lang),
                        '${recipe.carbs}',
                        'g',
                        Colors.green,
                      ),
                    ],
                  ),
                  const SizedBox(height: 30),

                  // ── Ingredients with Required/Optional tags ──────────────
                  _buildIngredientsSection(context, recipe, lang),
                  const SizedBox(height: 16),

                  // ── Cannot Cook warning + AI suggestion ─────────────────
                  if (!_canCook) ...[
                    _buildCannotCookBanner(context, lang),
                    const SizedBox(height: 16),
                  ],

                  // ── Cooking Steps (adapted) ──────────────────────────────
                  _buildSectionTitle(context, tr('cookingSteps', lang)),
                  const SizedBox(height: 10),

                  if (!_canCook)
                    Container(
                      margin: const EdgeInsets.only(bottom: 16),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.orange.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: Colors.orange.withValues(alpha: 0.4),
                        ),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.info_outline, color: Colors.orange),
                          const SizedBox(width: 8),
                          Expanded(
                            child: const Text(
                              'Cooking steps unavailable — required ingredients are missing',
                              style: TextStyle(
                                color: Colors.orange,
                                fontSize: 13,
                              ),
                            ),
                          ),
                        ],
                      ),
                    )
                  else
                    ListView.separated(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: adaptedSteps.length,
                      separatorBuilder: (context, index) => const Divider(),
                      itemBuilder: (context, index) {
                        return ListTile(
                          leading: CircleAvatar(
                            backgroundColor: Theme.of(context).primaryColor,
                            foregroundColor: Colors.white,
                            child: Text('${index + 1}'),
                          ),
                          title: Text(
                            adaptedSteps[index],
                            style: Theme.of(context).textTheme.bodyLarge,
                          ),
                        );
                      },
                    ),

                  const SizedBox(height: 32),

                  // ── "I Ate This" button ──────────────────────────────────
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: _canCook ? _logMeal : null,
                      icon: const Icon(Icons.restaurant, color: Colors.white),
                      label: Text(
                        tr('iAteThis', lang),
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Theme.of(context).primaryColor,
                        disabledBackgroundColor: Colors.grey[400],
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Bottom actions
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(tr('ingredientOrdering', lang)),
                                behavior: SnackBarBehavior.floating,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                            );
                          },
                          icon: const Icon(Icons.shopping_basket_outlined),
                          label: Text(
                            tr('orderIngredients', lang),
                            style: const TextStyle(fontWeight: FontWeight.w600),
                          ),
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            side: BorderSide(
                              color: Theme.of(context).primaryColor,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(tr('restaurantOrdering', lang)),
                                behavior: SnackBarBehavior.floating,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                            );
                          },
                          icon: const Icon(Icons.delivery_dining),
                          label: Text(
                            tr('fromRestaurant', lang),
                            style: const TextStyle(fontWeight: FontWeight.w600),
                          ),
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            side: BorderSide(
                              color: Theme.of(context).primaryColor,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Ingredients section ───────────────────────────────────────────────────

  Widget _buildIngredientsSection(
    BuildContext context,
    RecipeModel recipe,
    String lang,
  ) {
    final allIngredients = recipe.localizedIngredients(lang);
    final checkedCount = _availableIngredients.length;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            _buildSectionTitle(context, tr('ingredients', lang)),
            const Spacer(),
            Text(
              '$checkedCount/${allIngredients.length} ${tr('have', lang)}',
              style: TextStyle(
                color: Theme.of(context).primaryColor,
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        // Legend
        Row(
          children: [
            _legendDot(Colors.teal[400]!),
            const SizedBox(width: 4),
            const Text(
              'Required',
              style: TextStyle(fontSize: 12, color: Colors.grey),
            ),
            const SizedBox(width: 16),
            _legendDot(Colors.blue[300]!),
            const SizedBox(width: 4),
            const Text(
              'Optional',
              style: TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(16),
          ),
          child: ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: allIngredients.length,
            separatorBuilder: (context, index) => Divider(
              height: 1,
              color: Theme.of(context).dividerColor.withValues(alpha: 0.3),
            ),
            itemBuilder: (context, index) {
              final isChecked = _availableIngredients.contains(index);
              final isOptional = recipe.isOptional(index);
              final dotColor = isOptional
                  ? Colors.blue[300]!
                  : const Color.fromARGB(255, 205, 214, 22)!;
              final tagText = isOptional ? 'opt.' : 'req.';
              final tagColor = isOptional
                  ? Colors.blue[400]!
                  : const Color.fromARGB(255, 205, 214, 22)!;
              return InkWell(
                onTap: () => _toggleIngredient(index),
                borderRadius: BorderRadius.circular(16),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 250),
                  color: !isChecked
                      ? (isOptional
                            ? Colors.blue.withValues(alpha: 0.04)
                            : Colors.teal.withValues(alpha: 0.05))
                      : Colors.transparent,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  child: Row(
                    children: [
                      // Required/Optional dot
                      Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: dotColor,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 8),
                      // Checkbox
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        width: 24,
                        height: 24,
                        decoration: BoxDecoration(
                          color: isChecked
                              ? Theme.of(context).primaryColor
                              : Colors.transparent,
                          border: Border.all(
                            color: isChecked
                                ? Theme.of(context).primaryColor
                                : Colors.grey,
                            width: 2,
                          ),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: isChecked
                            ? const Icon(
                                Icons.check,
                                size: 16,
                                color: Colors.white,
                              )
                            : null,
                      ),
                      const SizedBox(width: 12),
                      // Ingredient name
                      Expanded(
                        child: Text(
                          allIngredients[index],
                          style: TextStyle(
                            fontSize: 15,
                            color: isChecked
                                ? Theme.of(context).primaryColor
                                : (!isChecked && !isOptional
                                      ? Colors.teal[600]
                                      : Theme.of(
                                          context,
                                        ).textTheme.bodyLarge?.color),
                            fontWeight: !isChecked && !isOptional
                                ? FontWeight.w600
                                : FontWeight.normal,
                          ),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 3,
                        ),
                        decoration: BoxDecoration(
                          color: tagColor.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: tagColor.withValues(alpha: 0.5),
                          ),
                        ),
                        child: Text(
                          tagText,
                          style: TextStyle(
                            fontSize: 10,
                            color: tagColor,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _legendDot(Color color) => Container(
    width: 10,
    height: 10,
    decoration: BoxDecoration(color: color, shape: BoxShape.circle),
  );

  // ── Cannot Cook Banner ────────────────────────────────────────────────────

  Widget _buildCannotCookBanner(BuildContext context, String lang) {
    final missingRequired = _missingIndices
        .where((i) => widget.recipe.isRequired(i))
        .map((i) => widget.recipe.ingredients[i])
        .toList();

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.red[900]!.withValues(alpha: 0.95),
            Colors.red[700]!.withValues(alpha: 0.9),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.red.withValues(alpha: 0.3),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.block, color: Colors.white, size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: const Text(
                  'Cannot be cooked',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'Missing required ingredients:',
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.85),
              fontSize: 13,
            ),
          ),
          const SizedBox(height: 6),
          Wrap(
            spacing: 6,
            runSpacing: 4,
            children: missingRequired
                .map(
                  (ing) => Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      ing,
                      style: const TextStyle(
                        color: Color(0xFFB71C1C),
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                )
                .toList(),
          ),
          const SizedBox(height: 12),
          // AI suggestion button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _aiLoading ? null : _getAiSuggestion,
              icon: _aiLoading
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Icon(Icons.auto_awesome, color: Colors.white),
              label: const Text(
                'What can I cook with what I have?',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white.withValues(alpha: 0.2),
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 0,
              ),
            ),
          ),
          // AI answer
          if (_aiRequested) ...[
            const SizedBox(height: 12),
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 400),
              child: _aiLoading
                  ? const Center(
                      child: Padding(
                        padding: EdgeInsets.all(8.0),
                        child: CircularProgressIndicator(color: Colors.white),
                      ),
                    )
                  : Container(
                      key: ValueKey(_aiSuggestion),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Icon(
                            Icons.lightbulb_outline,
                            color: Colors.white,
                            size: 18,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              _aiSuggestion ?? '',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 13,
                                height: 1.5,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
            ),
          ],
        ],
      ),
    );
  }

  // ── Helper widgets ────────────────────────────────────────────────────────

  Widget _buildSectionTitle(BuildContext context, String title) {
    return Text(title, style: Theme.of(context).textTheme.titleLarge);
  }

  Widget _buildInfoColumn(
    BuildContext context,
    String label,
    String value,
    String unit,
    Color color,
  ) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(unit, style: const TextStyle(fontSize: 12, color: Colors.grey)),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            color: Theme.of(context).brightness == Brightness.dark
                ? Colors.white70
                : Colors.black54,
          ),
        ),
      ],
    );
  }
}
