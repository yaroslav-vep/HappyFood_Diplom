import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../viewmodels/nutrition_viewmodel.dart';
import '../../data/models/eaten_meal_model.dart';
import 'dart:math' as math;
import 'profile_screen.dart';
import 'meal_history_screen.dart';
import '../../core/localization/app_localizations.dart';

class NutritionScreen extends ConsumerWidget {
  const NutritionScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final nutrition = ref.watch(nutritionViewModelProvider);
    final notifier = ref.read(nutritionViewModelProvider.notifier);
    final lang = ref.watch(languageProvider);

    final consumed = nutrition.calories;
    final target = nutrition.targetCalories > 0 ? nutrition.targetCalories : 2000;
    final progress = (consumed / target).clamp(0.0, 1.0);

    return Scaffold(
      appBar: AppBar(
        title: Text(tr('nutrition', lang)),
        centerTitle: false,
        actions: [
          // History button
          IconButton(
            icon: const Icon(Icons.history),
            tooltip: 'Meal History',
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (_) => const MealHistoryScreen()),
            ),
          ),
          if (nutrition.eatenMeals.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.refresh),
              tooltip: tr('resetDiary', lang),
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (ctx) => AlertDialog(
                    title: Text(tr('resetDiaryTitle', lang)),
                    content: Text(tr('resetDiaryContent', lang)),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(ctx),
                        child: Text(tr('cancel', lang)),
                      ),
                      ElevatedButton(
                        onPressed: () {
                          notifier.clearToday();
                          Navigator.pop(ctx);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red[700],
                        ),
                        child: Text(
                          tr('reset', lang),
                          style: const TextStyle(color: Colors.white),
                        ),
                      ),
                    ],
                  ),
                );
              },
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
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Calorie circle
            SizedBox(
              height: 250,
              width: 250,
              child: CustomPaint(
                painter: _CaloriePainter(
                  progress: progress,
                  color: Theme.of(context).primaryColor,
                  bgColor: Theme.of(context).cardColor,
                ),
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.local_fire_department,
                        color: Theme.of(context).primaryColor,
                        size: 32,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '$consumed',
                        style: TextStyle(
                          fontSize: 48,
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context)
                              .textTheme
                              .headlineMedium
                              ?.color,
                        ),
                      ),
                      Text(
                        tr('ofKcal', lang)
                            .replaceAll('{target}', '$target'),
                        style: const TextStyle(
                          fontSize: 13,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            const SizedBox(height: 8),

            // Remaining calories hint
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    consumed > target
                        ? Icons.warning_amber_rounded
                        : Icons.check_circle_outline,
                    size: 16,
                    color: consumed > target
                        ? Colors.orange
                        : Theme.of(context).primaryColor,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    consumed > target
                        ? tr('exceededBy', lang)
                            .replaceAll('{val}', '${consumed - target}')
                        : tr('kcalLeft', lang)
                            .replaceAll('{val}', '${target - consumed}'),
                    style: TextStyle(
                      fontSize: 13,
                      color: consumed > target
                          ? Colors.orange
                          : Colors.grey,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 32),

            // Macros row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: _buildMacroCard(
                    context,
                    tr('protein', lang),
                    '${nutrition.protein}g',
                    '/ ${nutrition.targetProtein}g',
                    Colors.blueAccent,
                    nutrition.targetProtein > 0
                        ? nutrition.protein / nutrition.targetProtein
                        : 0,
                    Icons.fitness_center,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _buildMacroCard(
                    context,
                    tr('fats', lang),
                    '${nutrition.fats}g',
                    '/ ${nutrition.targetFats}g',
                    Colors.orangeAccent,
                    nutrition.targetFats > 0
                        ? nutrition.fats / nutrition.targetFats
                        : 0,
                    Icons.water_drop,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _buildMacroCard(
                    context,
                    tr('carbs', lang),
                    '${nutrition.carbs}g',
                    '/ ${nutrition.targetCarbs}g',
                    Colors.greenAccent,
                    nutrition.targetCarbs > 0
                        ? nutrition.carbs / nutrition.targetCarbs
                        : 0,
                    Icons.grass,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 32),

            // Eaten meals log
            if (nutrition.eatenMeals.isEmpty)
              _buildEmptyMealsHint(context, lang)
            else ...[
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    tr('todaysMeals', lang),
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  Text(
                    '${nutrition.eatenMeals.length} ${tr('items', lang)}',
                    style: const TextStyle(color: Colors.grey, fontSize: 13),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              ...nutrition.eatenMeals.map(
                (meal) => _buildMealLogCard(context, meal, ref, lang),
              ),
            ],
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyMealsHint(BuildContext context, String lang) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          const Icon(Icons.restaurant_menu, size: 48, color: Colors.grey),
          const SizedBox(height: 12),
          Text(
            tr('noMealsYet', lang),
            style: const TextStyle(
              color: Colors.grey,
              fontSize: 15,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            tr('openRecipeHint', lang),
            style: const TextStyle(color: Colors.grey, fontSize: 13),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildMealLogCard(
    BuildContext context,
    EatenMealModel meal,
    WidgetRef ref,
    String lang,
  ) {
    final timeStr =
        '${meal.eatenAt.hour.toString().padLeft(2, '0')}:${meal.eatenAt.minute.toString().padLeft(2, '0')}';

    return Dismissible(
      key: Key('${meal.recipe.title}_${meal.eatenAt.millisecondsSinceEpoch}'),
      direction: DismissDirection.endToStart,
      onDismissed: (_) {
        ref.read(nutritionViewModelProvider.notifier).removeEatenMeal(meal);
      },
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        margin: const EdgeInsets.only(bottom: 10),
        decoration: BoxDecoration(
          color: Colors.red[700],
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Icon(Icons.delete, color: Colors.white),
      ),
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            // Thumbnail
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: Image.network(
                meal.recipe.imageUrl,
                width: 58,
                height: 58,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(
                  width: 58,
                  height: 58,
                  color: Colors.grey[800],
                  child: const Icon(Icons.restaurant, color: Colors.grey),
                ),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    meal.recipe.title,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${meal.recipe.calories} kcal  •  ${tr('protein', lang).substring(0, 1)}:${meal.recipe.protein}g  ${tr('fats', lang).substring(0, 1)}:${meal.recipe.fats}g  ${tr('carbs', lang).substring(0, 1)}:${meal.recipe.carbs}g',
                    style: const TextStyle(color: Colors.grey, fontSize: 12),
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  timeStr,
                  style: TextStyle(
                    fontSize: 12,
                    color: Theme.of(context).primaryColor,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                const Icon(Icons.chevron_left, color: Colors.grey, size: 18),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMacroCard(
    BuildContext context,
    String label,
    String value,
    String target,
    Color color,
    double progress,
    IconData icon,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 12),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          Stack(
            alignment: Alignment.center,
            children: [
              SizedBox(
                height: 50,
                width: 50,
                child: CircularProgressIndicator(
                  value: progress.clamp(0.0, 1.0),
                  backgroundColor:
                      Theme.of(context).disabledColor.withOpacity(0.2),
                  color: color,
                  strokeWidth: 5,
                ),
              ),
              Icon(icon, size: 20, color: color),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
              color: Theme.of(context).textTheme.bodyLarge?.color,
            ),
          ),
          Text(
            target,
            style: const TextStyle(color: Colors.grey, fontSize: 11),
          ),
          const SizedBox(height: 4),
          Text(label, style: const TextStyle(color: Colors.grey, fontSize: 12)),
        ],
      ),
    );
  }
}

class _CaloriePainter extends CustomPainter {
  final double progress;
  final Color color;
  final Color bgColor;

  _CaloriePainter({
    required this.progress,
    required this.color,
    required this.bgColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 10;
    const strokeWidth = 15.0;

    final bgPaint = Paint()
      ..color = bgColor
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeWidth = strokeWidth;

    canvas.drawCircle(center, radius, bgPaint);

    final progressPaint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeWidth = strokeWidth;

    final sweepAngle = 2 * math.pi * progress.clamp(0.0, 1.0);
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -math.pi / 2,
      sweepAngle,
      false,
      progressPaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
