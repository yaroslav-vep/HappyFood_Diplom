import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;

import '../../core/constant/app_theme.dart';
import '../../data/models/recipe_model.dart';
import '../viewmodels/nutrition_viewmodel.dart';

class MealCardScreen extends ConsumerStatefulWidget {
  final String dishName;

  const MealCardScreen({super.key, required this.dishName});

  @override
  ConsumerState<MealCardScreen> createState() => _MealCardScreenState();
}

class _MealCardScreenState extends ConsumerState<MealCardScreen>
    with SingleTickerProviderStateMixin {
  static const _proxyUrl =
      'http://localhost:3000/chat';

  bool _loading = true;
  String? _error;
  _MealCard? _card;
  bool _logged = false;

  late AnimationController _animController;
  late Animation<double> _fadeAnim;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _fadeAnim = CurvedAnimation(parent: _animController, curve: Curves.easeIn);
    _fetchCard();
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  Future<void> _fetchCard() async {
    setState(() {
      _loading = true;
      _error = null;
      _logged = false;
    });

    final prompt =
        'Create a complete meal card for the dish: "${widget.dishName}". '
        'Reply with ONLY a JSON object (no markdown code blocks) with this exact structure:\n'
        '{\n'
        '  "name": "Dish Name",\n'
        '  "emoji": "🍽️",\n'
        '  "description": "Short appetizing description (2 sentences)",\n'
        '  "calories": 450,\n'
        '  "protein": 30,\n'
        '  "fats": 15,\n'
        '  "carbs": 40,\n'
        '  "prepTime": "10 min",\n'
        '  "cookTime": "20 min",\n'
        '  "servings": 2,\n'
        '  "difficulty": "Easy",\n'
        '  "ingredients": ["200g chicken breast", "1 cup rice", "2 tbsp olive oil"],\n'
        '  "steps": ["Step 1 description", "Step 2 description"],\n'
        '  "tips": "One helpful cooking tip"\n'
        '}';

    try {
      http.Response? response;
      for (int attempt = 1; attempt <= 3; attempt++) {
        response = await http
            .post(
              Uri.parse(_proxyUrl),
              headers: {'Content-Type': 'application/json'},
              body: jsonEncode({'message': prompt}),
            )
            .timeout(const Duration(seconds: 30));

        if (response.statusCode == 200 ||
            ![429, 502, 503, 504].contains(response.statusCode)) {
          break; // Success or non-retryable error
        }

        if (attempt < 3) {
          // Wait 3 seconds before retry
          await Future.delayed(const Duration(seconds: 3));
        }
      }

      if (response == null) {
        setState(() {
          _error = 'Server unavailable. Tap to retry.';
          _loading = false;
        });
        return;
      }

      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body);
        final rawReply = jsonResponse['reply'] as String? ?? '';

        final start = rawReply.indexOf('{');
        final end = rawReply.lastIndexOf('}');
        if (start == -1 || end == -1) throw Exception('No JSON in response');

        final cardJson = jsonDecode(rawReply.substring(start, end + 1));
        setState(() {
          _card = _MealCard.fromJson(cardJson);
          _loading = false;
        });
        _animController.forward();
      } else if (response.statusCode == 429) {
        setState(() {
          _error = 'Too many requests (API limit). Please wait a moment and tap to retry.';
          _loading = false;
        });
      } else if (response.statusCode == 503 || response.statusCode == 504) {
        setState(() {
          _error = 'The AI server is warming up. Tap to retry.';
          _loading = false;
        });
      } else {
        setState(() {
          _error = 'Server error ${response!.statusCode}. Tap to retry.';
          _loading = false;
        });
      }
    } catch (e) {
      setState(() {
        _error = 'Failed to generate meal card. Tap to retry.';
        _loading = false;
      });
    }
  }

  // ── "I Ate This" ───────────────────────────────────────────────────────────
  void _logMeal() {
    final card = _card!;

    // Create a RecipeModel from the generated card (no image → empty string)
    final recipe = RecipeModel(
      title: card.name,
      description: card.description,
      ingredients: card.ingredients,
      calories: card.calories,
      protein: card.protein,
      fats: card.fats,
      carbs: card.carbs,
      tags: const [],
      imageUrl: '', // no photo for AI-generated cards
      steps: card.steps,
    );

    ref.read(nutritionViewModelProvider.notifier).addEatenMeal(recipe);
    setState(() => _logged = true);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle, color: Colors.white),
            const SizedBox(width: 10),
            Expanded(child: Text('${card.name} added to your diary!')),
          ],
        ),
        backgroundColor: Colors.green[700],
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        duration: const Duration(seconds: 2),
        action: SnackBarAction(
          label: 'View',
          textColor: Colors.white,
          onPressed: () {
            // Pop back to the root (MainScreen) so user sees the Nutrition tab
            Navigator.of(context).popUntil((route) => route.isFirst);
          },
        ),
      ),
    );
  }



  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        backgroundColor: AppTheme.surfaceColor,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, color: AppTheme.textPrimary),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          'Meal Card',
          style: TextStyle(
            color: AppTheme.textPrimary,
            fontWeight: FontWeight.w700,
            fontSize: 18,
          ),
        ),
        actions: [
          if (!_loading && _error == null)
            IconButton(
              icon: Icon(Icons.refresh, color: AppTheme.primaryColor),
              onPressed: _fetchCard,
              tooltip: 'Regenerate',
            ),
        ],
      ),
      body: _buildBody(isDark),
    );
  }

  Widget _buildBody(bool isDark) {
    if (_loading) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(color: AppTheme.primaryColor),
            const SizedBox(height: 20),
            Text(
              'Creating meal card for\n"${widget.dishName}"...',
              textAlign: TextAlign.center,
              style: TextStyle(color: AppTheme.textSecondary, fontSize: 15),
            ),
          ],
        ),
      );
    }

    if (_error != null) {
      return Center(
        child: GestureDetector(
          onTap: _fetchCard,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.error_outline, color: Colors.red[400], size: 48),
              const SizedBox(height: 12),
              Text(
                _error!,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 15),
              ),
            ],
          ),
        ),
      );
    }

    final card = _card!;

    return FadeTransition(
      opacity: _fadeAnim,
      child: Column(
        children: [
          // ── Scrollable content ───────────────────────────────────────────
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header Card
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          AppTheme.primaryColor,
                          AppTheme.primaryColor.withValues(alpha: 0.7),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: AppTheme.primaryColor.withValues(alpha: 0.35),
                          blurRadius: 20,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          card.emoji,
                          style: const TextStyle(fontSize: 48),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          card.name,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 26,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          card.description,
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.88),
                            fontSize: 14,
                            height: 1.5,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: [
                            _metaChip(Icons.timer_outlined, card.prepTime, 'Prep'),
                            _metaChip(
                              Icons.local_fire_department_outlined,
                              card.cookTime,
                              'Cook',
                            ),
                            _metaChip(
                              Icons.people_outline,
                              '${card.servings}',
                              'Servings',
                            ),
                            _metaChip(Icons.bar_chart, card.difficulty, null),
                          ],
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Nutrition Row
                  Container(
                    padding: const EdgeInsets.symmetric(
                      vertical: 16,
                      horizontal: 8,
                    ),
                    decoration: BoxDecoration(
                      color: Theme.of(context).cardColor,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _nutrientTile(
                          'Calories',
                          '${card.calories}',
                          'kcal',
                          Colors.orange,
                        ),
                        _divider(),
                        _nutrientTile(
                          'Protein',
                          '${card.protein}g',
                          'protein',
                          Colors.blue,
                        ),
                        _divider(),
                        _nutrientTile(
                          'Fats',
                          '${card.fats}g',
                          'fats',
                          Colors.amber,
                        ),
                        _divider(),
                        _nutrientTile(
                          'Carbs',
                          '${card.carbs}g',
                          'carbs',
                          Colors.green,
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Ingredients
                  _sectionTitle('🛒 Ingredients'),
                  Container(
                    decoration: BoxDecoration(
                      color: Theme.of(context).cardColor,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      children: card.ingredients.asMap().entries.map((e) {
                        final isLast = e.key == card.ingredients.length - 1;
                        return Column(
                          children: [
                            ListTile(
                              leading: Container(
                                width: 28,
                                height: 28,
                                decoration: BoxDecoration(
                                  color: AppTheme.primaryColor.withValues(
                                    alpha: 0.12,
                                  ),
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(
                                  Icons.check,
                                  size: 14,
                                  color: AppTheme.primaryColor,
                                ),
                              ),
                              title: Text(
                                e.value,
                                style: TextStyle(
                                  fontSize: 14,
                                  color:
                                      isDark
                                          ? Colors.white
                                          : AppTheme.textPrimary,
                                ),
                              ),
                              dense: true,
                            ),
                            if (!isLast)
                              Divider(
                                height: 1,
                                indent: 56,
                                color: Colors.grey.withValues(alpha: 0.15),
                              ),
                          ],
                        );
                      }).toList(),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Steps
                  _sectionTitle('👨‍🍳 Cooking Steps'),
                  ...card.steps.asMap().entries.map((e) {
                    return Container(
                      margin: const EdgeInsets.only(bottom: 10),
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: Theme.of(context).cardColor,
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            width: 28,
                            height: 28,
                            decoration: BoxDecoration(
                              color: AppTheme.primaryColor,
                              shape: BoxShape.circle,
                            ),
                            child: Center(
                              child: Text(
                                '${e.key + 1}',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 13,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              e.value,
                              style: TextStyle(
                                fontSize: 14,
                                height: 1.5,
                                color:
                                    isDark ? Colors.white : AppTheme.textPrimary,
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  }),

                  const SizedBox(height: 8),

                  // Tip
                  if (card.tips.isNotEmpty)
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.amber.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: Colors.amber.withValues(alpha: 0.3),
                        ),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('💡', style: TextStyle(fontSize: 20)),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              card.tips,
                              style: TextStyle(
                                fontSize: 14,
                                height: 1.5,
                                color:
                                    isDark ? Colors.white70 : Colors.black87,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),

          // ── Action buttons (sticky at bottom) ────────────────────────────
          Container(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 20),
            decoration: BoxDecoration(
              color: AppTheme.surfaceColor,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.06),
                  blurRadius: 12,
                  offset: const Offset(0, -4),
                ),
              ],
            ),
            child: SafeArea(
              top: false,
              child: Row(
                children: [
                  // "I Ate This" button
                  Expanded(
                    child: FilledButton.icon(
                      onPressed: _logged ? null : _logMeal,
                      style: FilledButton.styleFrom(
                        backgroundColor:
                            _logged ? Colors.grey[600] : Colors.green[700],
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      icon: Icon(
                        _logged ? Icons.check_circle : Icons.restaurant,
                        size: 18,
                      ),
                      label: Text(
                        _logged ? 'Added!' : 'I Ate This',
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),

                  // "Order Ingredients" button
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: const Text(
                              '(Ingredient Ordering - Coming Soon!)',
                            ),
                            behavior: SnackBarBehavior.floating,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        );
                      },
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppTheme.primaryColor,
                        side: BorderSide(color: AppTheme.primaryColor),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      icon: const Icon(Icons.shopping_cart_outlined, size: 18),
                      label: const Text(
                        'Order Ingredients',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _sectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 17,
          fontWeight: FontWeight.w700,
          color: AppTheme.textPrimary,
        ),
      ),
    );
  }

  Widget _metaChip(IconData icon, String value, String? label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13, color: Colors.white),
          const SizedBox(width: 4),
          Text(
            label != null ? '$value ($label)' : value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _nutrientTile(String label, String value, String sub, Color color) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w800,
            color: color,
          ),
        ),
        const SizedBox(height: 2),
        Text(label, style: const TextStyle(fontSize: 11, color: Colors.grey)),
      ],
    );
  }

  Widget _divider() {
    return Container(
      height: 36,
      width: 1,
      color: Colors.grey.withValues(alpha: 0.2),
    );
  }
}

// ── Data model ────────────────────────────────────────────────────────────────

class _MealCard {
  final String name;
  final String emoji;
  final String description;
  final int calories;
  final int protein;
  final int fats;
  final int carbs;
  final String prepTime;
  final String cookTime;
  final int servings;
  final String difficulty;
  final List<String> ingredients;
  final List<String> steps;
  final String tips;

  _MealCard({
    required this.name,
    required this.emoji,
    required this.description,
    required this.calories,
    required this.protein,
    required this.fats,
    required this.carbs,
    required this.prepTime,
    required this.cookTime,
    required this.servings,
    required this.difficulty,
    required this.ingredients,
    required this.steps,
    required this.tips,
  });

  factory _MealCard.fromJson(Map<String, dynamic> j) {
    List<String> toList(dynamic v) {
      if (v == null) return [];
      if (v is List) return v.map((e) => e.toString()).toList();
      return [];
    }

    int toInt(dynamic v, [int fallback = 0]) {
      if (v == null) return fallback;
      if (v is int) return v;
      return int.tryParse(v.toString()) ?? fallback;
    }

    return _MealCard(
      name: j['name'] as String? ?? 'Unknown',
      emoji: j['emoji'] as String? ?? '🍽️',
      description: j['description'] as String? ?? '',
      calories: toInt(j['calories']),
      protein: toInt(j['protein']),
      fats: toInt(j['fats']),
      carbs: toInt(j['carbs']),
      prepTime: j['prepTime'] as String? ?? '—',
      cookTime: j['cookTime'] as String? ?? '—',
      servings: toInt(j['servings'], 2),
      difficulty: j['difficulty'] as String? ?? 'Medium',
      ingredients: toList(j['ingredients']),
      steps: toList(j['steps']),
      tips: j['tips'] as String? ?? '',
    );
  }
}
