import 'dart:typed_data';
import 'dart:convert';
import 'dart:html' as html;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constant/app_theme.dart';
import '../../core/localization/app_localizations.dart';
import '../../data/models/menu_analysis_model.dart';
import '../../data/models/recipe_model.dart';
import '../viewmodels/menu_analysis_viewmodel.dart';
import '../viewmodels/nutrition_viewmodel.dart';

// ─────────────────────────────────────────────────────────────────────────────
//  Menu Scanner Screen
// ─────────────────────────────────────────────────────────────────────────────

class MenuScannerScreen extends ConsumerStatefulWidget {
  const MenuScannerScreen({super.key});

  @override
  ConsumerState<MenuScannerScreen> createState() => _MenuScannerScreenState();
}

class _MenuScannerScreenState extends ConsumerState<MenuScannerScreen>
    with TickerProviderStateMixin {
  Uint8List? _imageBytes;
  String? _imageMime;

  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _fadeAnimation = CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeInOut,
    );
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1400),
      vsync: this,
    )..repeat(reverse: true);
    _pulseAnimation = Tween<double>(begin: 0.95, end: 1.05).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  // ─── Image Picking ──────────────────────────────────────────────────────────
  Future<void> _pickImage() async {
    final uploadInput = html.FileUploadInputElement()
      ..accept = 'image/*'
      ..click();
    await uploadInput.onChange.first;
    final file = uploadInput.files?.first;
    if (file == null) return;

    final reader = html.FileReader();
    reader.readAsArrayBuffer(file);
    await reader.onLoad.first;

    setState(() {
      _imageBytes = reader.result as Uint8List;
      _imageMime = file.type.isNotEmpty ? file.type : 'image/jpeg';
    });
    ref.read(menuScanViewModelProvider.notifier).reset();
  }

  // ─── Analyze ───────────────────────────────────────────────────────────────
  Future<void> _analyzeMenu() async {
    if (_imageBytes == null) return;
    final base64Str = base64Encode(_imageBytes!);
    await ref.read(menuScanViewModelProvider.notifier).analyzeMenu(
          base64Image: base64Str,
          mimeType: _imageMime ?? 'image/jpeg',
        );
    _fadeController.reset();
    _fadeController.forward();
  }

  // ─── Add single dish to diary ──────────────────────────────────────────────
  void _addToDiary(BuildContext ctx, MenuDishModel dish) {
    final recipe = RecipeModel(
      title: dish.dishName,
      description: dish.description ?? 'Added from Menu Scanner',
      ingredients: dish.estimatedIngredients,
      calories: dish.calories,
      protein: dish.protein.toInt(),
      fats: dish.fats.toInt(),
      carbs: dish.carbs.toInt(),
      imageUrl: '',
      steps: const [],
    );
    ref.read(nutritionViewModelProvider.notifier).addEatenMeal(recipe);

    ScaffoldMessenger.of(ctx).showSnackBar(
      SnackBar(
        content: Text('✓ ${dish.dishName} added to diary!'),
        backgroundColor: AppTheme.primaryColor,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  // ─── Build ─────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    final state = ref.watch(menuScanViewModelProvider);
    final lang = ref.watch(languageProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: _buildAppBar(lang),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildPhotoZone(state, isDark, lang),
            const SizedBox(height: 16),
            _buildActionButtons(state, lang),
            const SizedBox(height: 24),
            if (state.status == MenuScanStatus.error)
              _buildErrorCard(state.errorMessage ?? 'An error occurred.'),
            if (state.status == MenuScanStatus.success &&
                state.result != null) ...[
              FadeTransition(
                opacity: _fadeAnimation,
                child: _buildResultsSection(state.result!, isDark, lang),
              ),
            ],
          ],
        ),
      ),
    );
  }

  // ─── AppBar ────────────────────────────────────────────────────────────────
  PreferredSizeWidget _buildAppBar(String lang) {
    return AppBar(
      backgroundColor: AppTheme.surfaceColor,
      elevation: 0,
      leading: IconButton(
        icon: Icon(Icons.arrow_back_ios, color: AppTheme.textPrimary),
        onPressed: () => Navigator.of(context).pop(),
      ),
      title: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: const Color(0xFFFF8C42).withOpacity(0.15),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.restaurant_menu_rounded,
              color: Color(0xFFFF8C42),
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                tr('menuScanner', lang),
                style: TextStyle(
                  color: AppTheme.textPrimary,
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                tr('menuScannerSubtitle', lang),
                style: TextStyle(color: AppTheme.textSecondary, fontSize: 11),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ─── Photo Zone ────────────────────────────────────────────────────────────
  Widget _buildPhotoZone(MenuScanState state, bool isDark, String lang) {
    final isLoading = state.status == MenuScanStatus.loading;

    return GestureDetector(
      onTap: isLoading ? null : _pickImage,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        height: 240,
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1E1E2E) : const Color(0xFFFFF8F2),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: _imageBytes != null
                ? const Color(0xFFFF8C42)
                : Colors.grey.withOpacity(0.3),
            width: _imageBytes != null ? 2 : 1,
          ),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFFFF8C42).withOpacity(0.08),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(23),
          child: _buildPhotoContent(state, isDark, lang),
        ),
      ),
    );
  }

  Widget _buildPhotoContent(MenuScanState state, bool isDark, String lang) {
    if (state.status == MenuScanStatus.loading) {
      return _buildLoadingContent(lang);
    }
    if (_imageBytes != null) {
      return _buildImagePreview(lang);
    }
    return _buildEmptyPhotoHint(lang);
  }

  Widget _buildLoadingContent(String lang) {
    return Container(
      color: AppTheme.backgroundColor,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Animated scanning icon
          ScaleTransition(
            scale: _pulseAnimation,
            child: Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFFFF8C42), Color(0xFFFFB347)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFFFF8C42).withOpacity(0.3),
                    blurRadius: 16,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: const Icon(
                Icons.document_scanner_rounded,
                color: Colors.white,
                size: 36,
              ),
            ),
          ),
          const SizedBox(height: 20),
          Text(
            tr('scanningMenu', lang),
            style: TextStyle(
              color: AppTheme.textPrimary,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Text(
              tr('recognizingDishes', lang),
              textAlign: TextAlign.center,
              style: TextStyle(color: AppTheme.textSecondary, fontSize: 12),
            ),
          ),
          const SizedBox(height: 20),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 60),
            child: LinearProgressIndicator(
              backgroundColor: const Color(0xFFFF8C42).withOpacity(0.15),
              color: const Color(0xFFFF8C42),
              borderRadius: BorderRadius.circular(4),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImagePreview(String lang) {
    return Stack(
      fit: StackFit.expand,
      children: [
        Image.memory(_imageBytes!, fit: BoxFit.cover),
        // Gradient overlay at bottom
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
                  Colors.black.withOpacity(0.65),
                  Colors.transparent,
                ],
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.edit_rounded, color: Colors.white70, size: 14),
                const SizedBox(width: 6),
                Text(
                  tr('tapToChangePhoto', lang),
                  style: const TextStyle(color: Colors.white70, fontSize: 12),
                ),
              ],
            ),
          ),
        ),
        // Top-right: menu tag badge
        Positioned(
          top: 12,
          right: 12,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: const Color(0xFFFF8C42),
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.restaurant_menu_rounded,
                    color: Colors.white, size: 12),
                SizedBox(width: 4),
                Text(
                  'MENU',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.5,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyPhotoHint(String lang) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: const Color(0xFFFF8C42).withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: const Icon(
            Icons.restaurant_menu_rounded,
            size: 48,
            color: Color(0xFFFF8C42),
          ),
        ),
        const SizedBox(height: 16),
        Text(
          tr('uploadMenuPhoto', lang),
          style: TextStyle(
            color: AppTheme.textPrimary,
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Text(
            tr('menuScannerHint', lang),
            textAlign: TextAlign.center,
            style: TextStyle(color: AppTheme.textSecondary, fontSize: 13),
          ),
        ),
      ],
    );
  }

  // ─── Action Buttons ────────────────────────────────────────────────────────
  Widget _buildActionButtons(MenuScanState state, String lang) {
    final isLoading = state.status == MenuScanStatus.loading;

    return Row(
      children: [
        Expanded(
          child: OutlinedButton.icon(
            onPressed: isLoading ? null : _pickImage,
            icon: const Icon(Icons.photo_library_outlined),
            label: Text(tr('pickPhoto', lang)),
            style: OutlinedButton.styleFrom(
              foregroundColor: const Color(0xFFFF8C42),
              side: const BorderSide(color: Color(0xFFFF8C42)),
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
            onPressed: (_imageBytes == null || isLoading) ? null : _analyzeMenu,
            icon: isLoading
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(
                        strokeWidth: 2, color: Colors.white),
                  )
                : const Icon(Icons.document_scanner_rounded),
            label: Text(
              isLoading ? tr('scanningMenu', lang) : tr('scanMenu', lang),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFFF8C42),
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

  // ─── Error Card ────────────────────────────────────────────────────────────
  Widget _buildErrorCard(String message) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.red.withOpacity(0.08),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.red.withOpacity(0.3)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.error_outline_rounded, color: Colors.red, size: 22),
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

  // ─── Results Section ───────────────────────────────────────────────────────
  Widget _buildResultsSection(
      MenuAnalysisResult result, bool isDark, String lang) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // ── Header ──────────────────────────────────────────────────────────
        _buildResultsHeader(result, lang),
        const SizedBox(height: 16),

        // ── Dish Cards ───────────────────────────────────────────────────────
        ...result.dishes.asMap().entries.map((entry) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: _DishCard(
              dish: entry.value,
              index: entry.key,
              isDark: isDark,
              lang: lang,
              onAddToDiary: () => _addToDiary(context, entry.value),
            ),
          );
        }),
        const SizedBox(height: 8),
      ],
    );
  }

  Widget _buildResultsHeader(MenuAnalysisResult result, String lang) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFFF8C42), Color(0xFFFFB347)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFFF8C42).withOpacity(0.25),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        children: [
          const Icon(Icons.check_circle_rounded, color: Colors.white, size: 28),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${result.count} ${tr('dishesFound', lang)}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  tr('tapCardToAddDiary', lang),
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.85),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.restaurant_menu_rounded,
                    color: Colors.white, size: 14),
                SizedBox(width: 4),
                Text(
                  'MENU',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.5,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
//  Dish Card Widget
// ─────────────────────────────────────────────────────────────────────────────

class _DishCard extends StatefulWidget {
  final MenuDishModel dish;
  final int index;
  final bool isDark;
  final String lang;
  final VoidCallback onAddToDiary;

  const _DishCard({
    required this.dish,
    required this.index,
    required this.isDark,
    required this.lang,
    required this.onAddToDiary,
  });

  @override
  State<_DishCard> createState() => _DishCardState();
}

class _DishCardState extends State<_DishCard> {
  bool _isExpanded = false;

  Color get _accentColor {
    final colors = [
      const Color(0xFFFF8C42),
      const Color(0xFF6BA368),
      const Color(0xFF4A90D9),
      const Color(0xFFB36AE0),
      const Color(0xFFE05C7A),
      const Color(0xFF2ABFBF),
    ];
    return colors[widget.index % colors.length];
  }

  @override
  Widget build(BuildContext context) {
    final dish = widget.dish;
    final lang = widget.lang;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      decoration: BoxDecoration(
        color: widget.isDark ? const Color(0xFF1E1E2E) : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: _accentColor.withOpacity(0.2),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: _accentColor.withOpacity(0.08),
            blurRadius: 14,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Top Row (name + badges) ───────────────────────────────────────
          _buildHeader(dish, lang),

          // ── Macros Row ────────────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: _buildMacrosRow(dish, lang),
          ),
          const SizedBox(height: 12),

          // ── Expand / Collapse ─────────────────────────────────────────────
          InkWell(
            onTap: () => setState(() => _isExpanded = !_isExpanded),
            borderRadius:
                const BorderRadius.vertical(bottom: Radius.circular(20)),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              child: Row(
                children: [
                  Icon(
                    _isExpanded
                        ? Icons.keyboard_arrow_up_rounded
                        : Icons.keyboard_arrow_down_rounded,
                    color: AppTheme.textSecondary,
                    size: 20,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    _isExpanded
                        ? tr('hideIngredients', lang)
                        : tr('showIngredients', lang),
                    style: TextStyle(
                        color: AppTheme.textSecondary, fontSize: 12),
                  ),
                  const Spacer(),
                  // Add to diary
                  GestureDetector(
                    onTap: widget.onAddToDiary,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 8),
                      decoration: BoxDecoration(
                        color: _accentColor,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: _accentColor.withOpacity(0.3),
                            blurRadius: 8,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.add_rounded,
                              color: Colors.white, size: 16),
                          const SizedBox(width: 4),
                          Text(
                            tr('addToDiary', lang),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // ── Expanded: ingredients + info ──────────────────────────────────
          if (_isExpanded) _buildExpandedContent(dish, lang),
        ],
      ),
    );
  }

  // ── Header ─────────────────────────────────────────────────────────────────
  Widget _buildHeader(MenuDishModel dish, String lang) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Index circle
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: _accentColor,
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    '${widget.index + 1}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      dish.dishName,
                      style: TextStyle(
                        color: AppTheme.textPrimary,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    if (dish.description != null &&
                        dish.description!.isNotEmpty) ...[
                      const SizedBox(height: 3),
                      Text(
                        dish.description!,
                        style: TextStyle(
                          color: AppTheme.textSecondary,
                          fontSize: 12,
                          height: 1.4,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          // Badges row
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: [
              if (dish.weight != null)
                _Badge(
                  icon: Icons.scale_rounded,
                  label: dish.weight!,
                  color: AppTheme.textSecondary,
                ),
              if (dish.price != null)
                _Badge(
                  icon: Icons.payments_rounded,
                  label: '${dish.price!.toStringAsFixed(0)} ₸',
                  color: AppTheme.textSecondary,
                ),
              _ConfidenceBadge(
                confidence: dish.confidence,
                isApproximate: dish.isApproximate,
                lang: lang,
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ── Macros row ─────────────────────────────────────────────────────────────
  Widget _buildMacrosRow(MenuDishModel dish, String lang) {
    return Row(
      children: [
        _MacroTile(
          emoji: '🔥',
          label: tr('calories', lang),
          value: '${dish.calories}',
          unit: 'kcal',
          color: const Color(0xFFFF6B35),
        ),
        _MacroTile(
          emoji: '💪',
          label: tr('protein', lang),
          value: dish.protein.toStringAsFixed(1),
          unit: 'g',
          color: const Color(0xFF4CAF50),
        ),
        _MacroTile(
          emoji: '🥑',
          label: tr('fats', lang),
          value: dish.fats.toStringAsFixed(1),
          unit: 'g',
          color: const Color(0xFFFFC107),
        ),
        _MacroTile(
          emoji: '🌾',
          label: tr('carbs', lang),
          value: dish.carbs.toStringAsFixed(1),
          unit: 'g',
          color: const Color(0xFF2196F3),
        ),
      ],
    );
  }

  // ── Expanded content ───────────────────────────────────────────────────────
  Widget _buildExpandedContent(MenuDishModel dish, String lang) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Divider(color: AppTheme.dividerColor, height: 20),
          Text(
            tr('estimatedIngredients', lang),
            style: TextStyle(
              color: AppTheme.textPrimary,
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 7,
            runSpacing: 7,
            children: dish.estimatedIngredients.map((ing) {
              return Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: _accentColor.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: _accentColor.withOpacity(0.2)),
                ),
                child: Text(
                  ing,
                  style: TextStyle(
                    color: _accentColor,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              );
            }).toList(),
          ),
          if (dish.isApproximate) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.amber.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.amber.withOpacity(0.3)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.warning_amber_rounded,
                      color: Colors.amber, size: 16),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      tr('approximateWarning', lang),
                      style: const TextStyle(
                          color: Colors.amber, fontSize: 11),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
//  Helper Widgets
// ─────────────────────────────────────────────────────────────────────────────

class _MacroTile extends StatelessWidget {
  final String emoji;
  final String label;
  final String value;
  final String unit;
  final Color color;

  const _MacroTile({
    required this.emoji,
    required this.label,
    required this.value,
    required this.unit,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 4),
        margin: const EdgeInsets.symmetric(horizontal: 3),
        decoration: BoxDecoration(
          color: color.withOpacity(0.07),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withOpacity(0.15)),
        ),
        child: Column(
          children: [
            Text(emoji, style: const TextStyle(fontSize: 16)),
            const SizedBox(height: 4),
            Text(
              value,
              style: TextStyle(
                color: color,
                fontSize: 13,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              unit,
              style: TextStyle(color: color.withOpacity(0.7), fontSize: 9),
            ),
            const SizedBox(height: 1),
            Text(
              label,
              textAlign: TextAlign.center,
              style: TextStyle(color: AppTheme.textSecondary, fontSize: 9),
            ),
          ],
        ),
      ),
    );
  }
}

class _Badge extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;

  const _Badge({required this.icon, required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 11, color: color),
          const SizedBox(width: 4),
          Text(label, style: TextStyle(color: color, fontSize: 11)),
        ],
      ),
    );
  }
}

class _ConfidenceBadge extends StatelessWidget {
  final double confidence;
  final bool isApproximate;
  final String lang;

  const _ConfidenceBadge({
    required this.confidence,
    required this.isApproximate,
    required this.lang,
  });

  @override
  Widget build(BuildContext context) {
    final pct = (confidence * 100).toInt();
    final Color color;
    final IconData icon;

    if (confidence >= 0.75) {
      color = const Color(0xFF4CAF50);
      icon = Icons.verified_rounded;
    } else if (confidence >= 0.5) {
      color = Colors.amber;
      icon = Icons.warning_amber_rounded;
    } else {
      color = Colors.red;
      icon = Icons.help_outline_rounded;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 11, color: color),
          const SizedBox(width: 4),
          Text(
            isApproximate
                ? '~$pct% ${tr('confidence', lang)}'
                : '$pct% ${tr('confidence', lang)}',
            style: TextStyle(color: color, fontSize: 11),
          ),
        ],
      ),
    );
  }
}
