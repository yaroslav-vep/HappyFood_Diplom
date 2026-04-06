import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:convert';
import 'dart:html' as html;
import '../../core/constant/app_theme.dart';
import '../viewmodels/ai_analysis_viewmodel.dart';
import '../../data/models/food_analysis_model.dart';
import '../../data/models/recipe_model.dart';
import '../viewmodels/nutrition_viewmodel.dart';
import '../../core/localization/app_localizations.dart';

class AIFoodAnalysisScreen extends ConsumerStatefulWidget {
  const AIFoodAnalysisScreen({super.key});

  @override
  ConsumerState<AIFoodAnalysisScreen> createState() =>
      _AIFoodAnalysisScreenState();
}

class _AIFoodAnalysisScreenState extends ConsumerState<AIFoodAnalysisScreen>
    with TickerProviderStateMixin {
  Uint8List? _imageBytes;
  String? _imageMime;
  bool _ingredientsExpanded = true;
  bool _instructionsExpanded = true;

  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _fadeAnimation = CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeInOut,
    );
  }

  @override
  void dispose() {
    _fadeController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    // Web: use HTML file input
    final uploadInput = html.FileUploadInputElement()
      ..accept = 'image/*'
      ..click();

    await uploadInput.onChange.first;

    final file = uploadInput.files?.first;
    if (file == null) return;

    final reader = html.FileReader();
    reader.readAsArrayBuffer(file);
    await reader.onLoad.first;

    final bytes = reader.result as Uint8List;
    final mime = file.type.isNotEmpty ? file.type : 'image/jpeg';

    setState(() {
      _imageBytes = bytes;
      _imageMime = mime;
      _ingredientsExpanded = true;
      _instructionsExpanded = true;
    });

    ref.read(aiAnalysisViewModelProvider.notifier).reset();
  }

  Future<void> _analyzeImage() async {
    if (_imageBytes == null) return;

    final base64Str = base64Encode(_imageBytes!);
    await ref.read(aiAnalysisViewModelProvider.notifier).analyze(
          base64Image: base64Str,
          mimeType: _imageMime ?? 'image/jpeg',
        );

    _fadeController.reset();
    _fadeController.forward();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(aiAnalysisViewModelProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final lang = ref.watch(languageProvider);

    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        backgroundColor: AppTheme.surfaceColor,
        elevation: 0,
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppTheme.primaryColor.withOpacity(0.15),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.camera_enhance_rounded,
                color: AppTheme.primaryColor,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  tr('aiFoodAnalysis', lang),
                  style: TextStyle(
                    color: AppTheme.textPrimary,
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  tr('poweredByGemini', lang),
                  style:
                      TextStyle(color: AppTheme.textSecondary, fontSize: 11),
                ),
              ],
            ),
          ],
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, color: AppTheme.textPrimary),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // ─── Image Zone ───────────────────────────────────────────────
            _buildImageZone(state, isDark, lang),
            const SizedBox(height: 16),

            // ─── Action Buttons ───────────────────────────────────────────
            _buildActionButtons(state, lang),
            const SizedBox(height: 24),

            // ─── Results ─────────────────────────────────────────────────
            if (state.status == AnalysisStatus.error)
              _buildErrorCard(state.errorMessage ?? 'An error occurred'),

            if (state.status == AnalysisStatus.success &&
                state.result != null)
              FadeTransition(
                opacity: _fadeAnimation,
                child: _buildResultSection(state.result!, lang),
              ),
          ],
        ),
      ),
    );
  }

  // ─── Image Preview Zone ──────────────────────────────────────────────────
  Widget _buildImageZone(AnalysisState state, bool isDark, String lang) {
    return GestureDetector(
      onTap: state.status == AnalysisStatus.loading ? null : _pickImage,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        height: 260,
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1E1E2E) : const Color(0xFFF0F4FF),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: _imageBytes != null
                ? AppTheme.primaryColor
                : Colors.grey.withOpacity(0.3),
            width: _imageBytes != null ? 2 : 1,
          ),
          boxShadow: [
            BoxShadow(
              color: AppTheme.primaryColor.withOpacity(0.08),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(23),
          child: _buildImageContent(state, lang),
        ),
      ),
    );
  }

  Widget _buildImageContent(AnalysisState state, String lang) {
    if (state.status == AnalysisStatus.loading) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              width: 52,
              height: 52,
              child: CircularProgressIndicator(
                strokeWidth: 3,
                color: AppTheme.primaryColor,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              tr('analyzingDish', lang),
              style: TextStyle(
                color: AppTheme.textPrimary,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              tr('geminiScanning', lang),
              style: TextStyle(color: AppTheme.textSecondary, fontSize: 13),
            ),
          ],
        ),
      );
    }

    if (_imageBytes != null) {
      return Stack(
        fit: StackFit.expand,
        children: [
          Image.memory(
            _imageBytes!,
            fit: BoxFit.cover,
          ),
          // Overlay hint
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                  colors: [
                    Colors.black.withOpacity(0.7),
                    Colors.transparent,
                  ],
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.edit, color: Colors.white70, size: 16),
                  const SizedBox(width: 6),
                  Text(
                    tr('tapToChangePhoto', lang),
                    style: const TextStyle(color: Colors.white70, fontSize: 12),
                  ),
                ],
              ),
            ),
          ),
        ],
      );
    }

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: AppTheme.primaryColor.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(
            Icons.add_photo_alternate_outlined,
            size: 48,
            color: AppTheme.primaryColor,
          ),
        ),
        const SizedBox(height: 16),
        Text(
          tr('uploadFoodPhoto', lang),
          style: TextStyle(
            color: AppTheme.textPrimary,
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          tr('aiWillIdentify', lang),
          style: TextStyle(color: AppTheme.textSecondary, fontSize: 13),
        ),
      ],
    );
  }

  // ─── Action Buttons ───────────────────────────────────────────────────────
  Widget _buildActionButtons(AnalysisState state, String lang) {
    final isLoading = state.status == AnalysisStatus.loading;

    return Row(
      children: [
        Expanded(
          child: OutlinedButton.icon(
            onPressed: isLoading ? null : _pickImage,
            icon: const Icon(Icons.photo_library_outlined),
            label: Text(tr('pickPhoto', lang)),
            style: OutlinedButton.styleFrom(
              foregroundColor: AppTheme.primaryColor,
              side: BorderSide(color: AppTheme.primaryColor),
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: ElevatedButton.icon(
            onPressed:
                (_imageBytes == null || isLoading) ? null : _analyzeImage,
            icon: isLoading
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child:
                        CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                  )
                : const Icon(Icons.auto_awesome_rounded),
            label: Text(isLoading ? tr('analyzing', lang) : tr('analyze', lang)),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryColor,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
              elevation: 0,
            ),
          ),
        ),
      ],
    );
  }

  // ─── Error Card ───────────────────────────────────────────────────────────
  Widget _buildErrorCard(String message) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.red.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.red.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          const Icon(Icons.error_outline_rounded, color: Colors.red),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              message,
              style: const TextStyle(color: Colors.red, fontSize: 14),
            ),
          ),
        ],
      ),
    );
  }

  // ─── Results Section ──────────────────────────────────────────────────────
  Widget _buildResultSection(FoodAnalysisModel result, String lang) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Dish Name Banner
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                AppTheme.primaryColor,
                AppTheme.primaryColor.withOpacity(0.7),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Column(
            children: [
              const Icon(
                Icons.restaurant_rounded,
                color: Colors.white,
                size: 32,
              ),
              const SizedBox(height: 8),
              Text(
                result.dishName,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                tr('approximateComposition', lang),
                style: TextStyle(color: Colors.white.withOpacity(0.8), fontSize: 13),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // Macros Row
        Row(
          children: [
            _buildKbjuCard('🔥', tr('calories', lang), '${result.calories}', 'kcal',
                const Color(0xFFFF6B35)),
            const SizedBox(width: 10),
            _buildKbjuCard('💪', tr('protein', lang), result.protein.toStringAsFixed(1),
                'g', const Color(0xFF4CAF50)),
            const SizedBox(width: 10),
            _buildKbjuCard('🥑', tr('fats', lang), result.fats.toStringAsFixed(1), 'g',
                const Color(0xFFFFC107)),
            const SizedBox(width: 10),
            _buildKbjuCard('🌾', tr('carbs', lang), result.carbs.toStringAsFixed(1),
                'g', const Color(0xFF2196F3)),
          ],
        ),
        const SizedBox(height: 16),

        // Ingredients Expandable
        _buildExpandableCard(
          icon: Icons.list_alt_rounded,
          title: tr('ingredients', lang),
          count: result.ingredients.length,
          isExpanded: _ingredientsExpanded,
          onToggle: () =>
              setState(() => _ingredientsExpanded = !_ingredientsExpanded),
          child: Column(
            children: result.ingredients.asMap().entries.map((entry) {
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 5),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 22,
                      height: 22,
                      margin: const EdgeInsets.only(top: 1),
                      decoration: BoxDecoration(
                        color: AppTheme.primaryColor.withOpacity(0.15),
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: Text(
                          '${entry.key + 1}',
                          style: TextStyle(
                            color: AppTheme.primaryColor,
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        entry.value,
                        style: TextStyle(
                          color: AppTheme.textPrimary,
                          fontSize: 14,
                          height: 1.4,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ),
        const SizedBox(height: 12),

        // Instructions Expandable
        _buildExpandableCard(
          icon: Icons.menu_book_rounded,
          title: tr('howToPrepare', lang),
          count: result.instructions.length,
          isExpanded: _instructionsExpanded,
          onToggle: () =>
              setState(() => _instructionsExpanded = !_instructionsExpanded),
          child: Column(
            children: result.instructions.asMap().entries.map((entry) {
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 28,
                      height: 28,
                      margin: const EdgeInsets.only(top: 1),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            AppTheme.primaryColor,
                            AppTheme.primaryColor.withOpacity(0.7),
                          ],
                        ),
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: Text(
                          '${entry.key + 1}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        entry.value,
                        style: TextStyle(
                          color: AppTheme.textPrimary,
                          fontSize: 14,
                          height: 1.5,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ),
        const SizedBox(height: 20),

        // Add to diary button
        ElevatedButton.icon(
          onPressed: () {
            // Add the dish to the diary using the nutrition view model
            final recipe = RecipeModel(
              title: result.dishName,
              description: tr('addedFromAI', lang),
              ingredients: result.ingredients,
              calories: result.calories,
              protein: result.protein.toInt(),
              fats: result.fats.toInt(),
              carbs: result.carbs.toInt(),
              imageUrl: '', // We don't have a specific URL yet
              steps: result.instructions,
            );
            ref.read(nutritionViewModelProvider.notifier).addEatenMeal(recipe);

            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  '✓ ${result.dishName} added to diary!',
                ),
                backgroundColor: AppTheme.primaryColor,
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            );
            Navigator.pop(context);
          },
          icon: const Icon(Icons.add_circle_outline_rounded),
          label: Text(
            tr('addToDiary', lang),
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          ),
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF4CAF50),
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            elevation: 0,
          ),
        ),
        const SizedBox(height: 20),
      ],
    );
  }

  // ─── KBJU mini card ───────────────────────────────────────────────────────
  Widget _buildKbjuCard(
      String emoji, String label, String value, String unit, Color color) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1E1E2E) : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withOpacity(0.25)),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.1),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          children: [
            Text(emoji, style: const TextStyle(fontSize: 20)),
            const SizedBox(height: 6),
            Text(
              value,
              style: TextStyle(
                color: color,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              unit,
              style: TextStyle(color: color.withOpacity(0.7), fontSize: 10),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: AppTheme.textSecondary,
                fontSize: 10,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ─── Expandable card ──────────────────────────────────────────────────────
  Widget _buildExpandableCard({
    required IconData icon,
    required String title,
    required int count,
    required bool isExpanded,
    required VoidCallback onToggle,
    required Widget child,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1E2E) : Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          InkWell(
            onTap: onToggle,
            borderRadius: BorderRadius.circular(20),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppTheme.primaryColor.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(icon, color: AppTheme.primaryColor, size: 20),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      title,
                      style: TextStyle(
                        color: AppTheme.textPrimary,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: AppTheme.primaryColor.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '$count',
                      style: TextStyle(
                        color: AppTheme.primaryColor,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Icon(
                    isExpanded
                        ? Icons.keyboard_arrow_up_rounded
                        : Icons.keyboard_arrow_down_rounded,
                    color: AppTheme.textSecondary,
                  ),
                ],
              ),
            ),
          ),
          if (isExpanded)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: child,
            ),
        ],
      ),
    );
  }
}
