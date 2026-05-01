import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/eaten_meal_model.dart';
import '../viewmodels/nutrition_viewmodel.dart';
import '../../core/localization/app_localizations.dart';

class MealHistoryScreen extends ConsumerWidget {
  const MealHistoryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final nutrition = ref.watch(nutritionViewModelProvider);
    final notifier = ref.read(nutritionViewModelProvider.notifier);
    final lang = ref.watch(languageProvider);
    final history = nutrition.mealHistory;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Meal History'),
        centerTitle: false,
        actions: [
          if (history.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.delete_sweep_outlined),
              tooltip: 'Clear History',
              onPressed: () => _confirmClear(context, notifier, lang),
            ),
          const SizedBox(width: 8),
        ],
      ),
      body: history.isEmpty
          ? _buildEmpty(context)
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: history.length,
              itemBuilder: (context, dayIndex) {
                final dayMeals = history[dayIndex];
                return _DayHistoryCard(
                  dayMeals: dayMeals,
                  dayIndex: dayIndex,
                  lang: lang,
                );
              },
            ),
    );
  }

  Widget _buildEmpty(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.history, size: 72, color: Colors.grey[400]),
          const SizedBox(height: 16),
          const Text(
            'No meal history yet.',
            style: TextStyle(fontSize: 16, color: Colors.grey),
          ),
          const SizedBox(height: 8),
          const Text(
            'Reset your diary to save today\'s meals to history.',
            style: TextStyle(fontSize: 13, color: Colors.grey),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  void _confirmClear(
      BuildContext context, NutritionViewModel notifier, String lang) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Clear History?'),
        content:
            const Text('All past meal records will be permanently deleted.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              notifier.clearHistory();
              Navigator.pop(ctx);
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red[700]),
            child: const Text('Clear', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}

// ── One day's history card ────────────────────────────────────────────────────

class _DayHistoryCard extends StatelessWidget {
  final List<EatenMealModel> dayMeals;
  final int dayIndex;
  final String lang;

  const _DayHistoryCard({
    required this.dayMeals,
    required this.dayIndex,
    required this.lang,
  });

  @override
  Widget build(BuildContext context) {
    if (dayMeals.isEmpty) return const SizedBox.shrink();

    final date = dayMeals.first.eatenAt;
    final dateLabel = _formatDate(date, dayIndex);
    final totalCal = dayMeals.fold(0, (s, m) => s + m.recipe.calories);
    final totalProt = dayMeals.fold(0, (s, m) => s + m.recipe.protein);
    final totalFat = dayMeals.fold(0, (s, m) => s + m.recipe.fats);
    final totalCarb = dayMeals.fold(0, (s, m) => s + m.recipe.carbs);

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ExpansionTile(
        tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        childrenPadding: EdgeInsets.zero,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        collapsedShape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Theme.of(context).primaryColor.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.calendar_today,
                  color: Theme.of(context).primaryColor, size: 18),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    dateLabel,
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 15),
                  ),
                  Text(
                    '${dayMeals.length} meal${dayMeals.length == 1 ? '' : 's'}',
                    style: const TextStyle(color: Colors.grey, fontSize: 12),
                  ),
                ],
              ),
            ),
            // Total calories badge
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                color: Theme.of(context).primaryColor,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                '$totalCal kcal',
                style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                    fontSize: 13),
              ),
            ),
          ],
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(left: 52, bottom: 4),
          child: Text(
            'P:${totalProt}g  F:${totalFat}g  C:${totalCarb}g',
            style: const TextStyle(color: Colors.grey, fontSize: 11),
          ),
        ),
        children: dayMeals
            .map((meal) => _MealHistoryItem(meal: meal))
            .toList(),
      ),
    );
  }

  String _formatDate(DateTime date, int index) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final mealDay = DateTime(date.year, date.month, date.day);
    final diff = today.difference(mealDay).inDays;

    if (diff == 0) return 'Today';
    if (diff == 1) return 'Yesterday';

    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return '${months[date.month - 1]} ${date.day}, ${date.year}';
  }
}

// ── Single meal item inside history card ─────────────────────────────────────

class _MealHistoryItem extends StatelessWidget {
  final EatenMealModel meal;
  const _MealHistoryItem({required this.meal});

  @override
  Widget build(BuildContext context) {
    final timeStr =
        '${meal.eatenAt.hour.toString().padLeft(2, '0')}:${meal.eatenAt.minute.toString().padLeft(2, '0')}';

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      child: Row(
        children: [
          // Thumbnail
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Image.network(
              meal.recipe.imageUrl,
              width: 48,
              height: 48,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => Container(
                width: 48,
                height: 48,
                color: Colors.grey[800],
                child: const Icon(Icons.restaurant, color: Colors.grey, size: 20),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  meal.recipe.title,
                  style: const TextStyle(
                      fontWeight: FontWeight.w600, fontSize: 13),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  '${meal.recipe.calories} kcal  •  P:${meal.recipe.protein}g  F:${meal.recipe.fats}g  C:${meal.recipe.carbs}g',
                  style: const TextStyle(color: Colors.grey, fontSize: 11),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Text(
            timeStr,
            style: TextStyle(
              fontSize: 11,
              color: Theme.of(context).primaryColor,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
