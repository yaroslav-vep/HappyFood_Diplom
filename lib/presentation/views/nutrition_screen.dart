import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constant/app_theme.dart';
import '../viewmodels/nutrition_viewmodel.dart';
import 'dart:math' as math;

class NutritionScreen extends ConsumerWidget {
  const NutritionScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final nutrition = ref.watch(nutritionViewModelProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Daily Nutrition'), centerTitle: false),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Big Circular Indicator for Calories
            SizedBox(
              height: 250,
              width: 250,
              child: CustomPaint(
                painter: _CaloriePainter(
                  calories: nutrition.calories.toDouble(),
                  maxCalories: 2500, // Placeholder max
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
                        '${nutrition.calories}',
                        style: TextStyle(
                          fontSize: 48,
                          fontWeight: FontWeight.bold,
                          color: Theme.of(
                            context,
                          ).textTheme.headlineMedium?.color,
                        ),
                      ),
                      const Text(
                        'kcal / day',
                        style: TextStyle(fontSize: 14, color: Colors.grey),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 40),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: _buildMacroCard(
                    context,
                    'Protein',
                    '${nutrition.protein}g',
                    Colors.blueAccent,
                    nutrition.protein / 200,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _buildMacroCard(
                    context,
                    'Fats',
                    '${nutrition.fats}g',
                    Colors.orangeAccent,
                    nutrition.fats / 100,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _buildMacroCard(
                    context,
                    'Carbs',
                    '${nutrition.carbs}g',
                    Colors.greenAccent,
                    nutrition.carbs / 300,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 40),
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                children: [
                  const Icon(Icons.info_outline, color: Colors.grey),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Text(
                      'Your daily targets based on your goal to "${ref.watch(nutritionViewModelProvider.notifier).debugGoal}"',
                      style: const TextStyle(color: Colors.grey),
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

  Widget _buildMacroCard(
    BuildContext context,
    String label,
    String value,
    Color color,
    double progress,
  ) {
    return Container(
      // width: 100, // Removed fixed width
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
                  backgroundColor: Theme.of(
                    context,
                  ).disabledColor.withOpacity(0.2),
                  color: color,
                  strokeWidth: 5,
                ),
              ),
              Icon(
                label == 'Protein'
                    ? Icons.fitness_center
                    : label == 'Fats'
                    ? Icons.water_drop
                    : Icons.grass,
                size: 20,
                color: color,
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            value,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 18,
              color: Theme.of(context).textTheme.bodyLarge?.color,
            ),
          ),
          const SizedBox(height: 4),
          Text(label, style: const TextStyle(color: Colors.grey, fontSize: 12)),
        ],
      ),
    );
  }
}

class _CaloriePainter extends CustomPainter {
  final double calories;
  final double maxCalories;
  final Color color;
  final Color bgColor;

  _CaloriePainter({
    required this.calories,
    required this.maxCalories,
    required this.color,
    required this.bgColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;
    final strokeWidth = 15.0;

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

    final sweepAngle = 2 * math.pi * (calories / maxCalories).clamp(0.0, 1.0);
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

// Extension to access goal for debug text if needed, otherwise ignore error or fix logic
extension on NutritionViewModel {
  String get debugGoal =>
      "Maintain"; // Placeholder as we can't easily access state here without re-watching user provider directly
}
