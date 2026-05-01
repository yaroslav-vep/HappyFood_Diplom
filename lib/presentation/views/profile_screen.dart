import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import '../../core/constants/app_constants.dart';
import '../../core/constant/app_theme.dart';
import '../viewmodels/user_viewmodel.dart';
import 'settings_screen.dart';
import '../../core/localization/app_localizations.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  final TextEditingController _allergyController = TextEditingController();
  final ImagePicker _imagePicker = ImagePicker();
  Uint8List? _webAvatarBytes; // for web preview

  // Common allergen presets
  static const _commonAllergens = [
    'Dairy', 'Gluten', 'Nuts', 'Eggs', 'Shellfish', 'Soy', 'Fish', 'Wheat',
  ];

  @override
  void dispose() {
    _allergyController.dispose();
    super.dispose();
  }

  // ── Avatar ─────────────────────────────────────────────────────────────────

  Future<void> _pickAvatar() async {
    showModalBottomSheet(
      context: context,
      backgroundColor: Theme.of(context).cardColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 8),
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[400],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 16),
            ListTile(
              leading: Icon(Icons.photo_library, color: Theme.of(ctx).primaryColor),
              title: const Text('From Gallery'),
              onTap: () async {
                Navigator.pop(ctx);
                await _pickImage(ImageSource.gallery);
              },
            ),
            ListTile(
              leading: Icon(Icons.photo_camera, color: Theme.of(ctx).primaryColor),
              title: const Text('Take Photo'),
              onTap: () async {
                Navigator.pop(ctx);
                await _pickImage(ImageSource.camera);
              },
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final XFile? picked = await _imagePicker.pickImage(
        source: source,
        maxWidth: 512,
        maxHeight: 512,
        imageQuality: 85,
      );
      if (picked != null) {
        if (kIsWeb) {
          // On web, read bytes directly — File() won't work
          final bytes = await picked.readAsBytes();
          setState(() => _webAvatarBytes = bytes);
          // Store path as a marker (bytes are in local state)
          ref.read(userViewModelProvider.notifier).updateAvatarPath('web_avatar');
        } else {
          ref.read(userViewModelProvider.notifier).updateAvatarPath(picked.path);
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Error picking photo'),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  // ── Drum Picker ────────────────────────────────────────────────────────────

  void _showDrumPicker({
    required String title,
    required int minValue,
    required int maxValue,
    required double currentValue,
    required String unit,
    required Function(double) onSelected,
  }) {
    final lang = ref.read(languageProvider);
    int selectedIndex = (currentValue.toInt() - minValue).clamp(0, maxValue - minValue);

    showModalBottomSheet(
      context: context,
      backgroundColor: Theme.of(context).cardColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return SizedBox(
          height: 320,
          child: Column(
            children: [
              // Handle bar
              const SizedBox(height: 8),
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[400],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              // Header
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: Text(
                        tr('cancel', lang),
                        style: TextStyle(color: AppTheme.textSecondary),
                      ),
                    ),
                    Text(
                      title,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        onSelected(selectedIndex.toDouble() + minValue);
                        Navigator.pop(context);
                      },
                      child: Text(
                        tr('confirm', lang),
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: AppTheme.primaryColor,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              // Drum picker
              Expanded(
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    // Selection highlight band
                    Container(
                      height: 44,
                      margin: const EdgeInsets.symmetric(horizontal: 24),
                      decoration: BoxDecoration(
                        color: AppTheme.primaryColor.withOpacity(0.10),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: AppTheme.primaryColor.withOpacity(0.25),
                        ),
                      ),
                    ),
                    CupertinoPicker(
                      itemExtent: 44,
                      scrollController: FixedExtentScrollController(
                        initialItem: selectedIndex,
                      ),
                      onSelectedItemChanged: (idx) => selectedIndex = idx,
                      selectionOverlay: const CupertinoPickerDefaultSelectionOverlay(
                        background: Colors.transparent,
                      ),
                      children: List.generate(
                        maxValue - minValue + 1,
                        (idx) => Center(
                          child: Text(
                            '${idx + minValue} $unit',
                            style: TextStyle(
                              color: Theme.of(context).textTheme.bodyLarge?.color,
                              fontSize: 20,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
            ],
          ),
        );
      },
    );
  }

  // ── Avatar Image builder (web-safe) ────────────────────────────────────────

  ImageProvider<Object>? _buildAvatarImage(String? path) {
    if (path == null) return null;
    if (kIsWeb && _webAvatarBytes != null) {
      return MemoryImage(_webAvatarBytes!);
    }
    if (!kIsWeb && path != 'web_avatar') {
      return FileImage(File(path));
    }
    return null;
  }

  // ── Allergen helpers ────────────────────────────────────────────────────────

  void _addAllergy(String allergy) {
    final trimmed = allergy.trim();
    if (trimmed.isEmpty) return;
    final user = ref.read(userViewModelProvider);
    final current = List<String>.from(user.allergies);
    if (!current.any((a) => a.toLowerCase() == trimmed.toLowerCase())) {
      current.add(trimmed);
      ref.read(userViewModelProvider.notifier).updateAllergies(current);
    }
    _allergyController.clear();
  }

  void _removeAllergy(String allergy) {
    final user = ref.read(userViewModelProvider);
    final current = List<String>.from(user.allergies)
      ..removeWhere((a) => a.toLowerCase() == allergy.toLowerCase());
    ref.read(userViewModelProvider.notifier).updateAllergies(current);
  }

  // ── Build ───────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(userViewModelProvider);
    final userViewModel = ref.read(userViewModelProvider.notifier);
    final theme = Theme.of(context);
    final lang = ref.watch(languageProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(tr('profile', lang)),
        centerTitle: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const SettingsScreen()),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Avatar ──────────────────────────────────────────────────────
            Center(
              child: Column(
                children: [
                  GestureDetector(
                    onTap: _pickAvatar,
                    child: Stack(
                      children: [
                        CircleAvatar(
                          radius: 54,
                          backgroundColor: AppTheme.primaryColorLight,
                          backgroundImage: _buildAvatarImage(user.avatarPath),
                          child: _buildAvatarImage(user.avatarPath) == null
                              ? Icon(
                                  Icons.person,
                                  size: 54,
                                  color: AppTheme.primaryColor,
                                )
                              : null,
                        ),
                        Positioned(
                          bottom: 0,
                          right: 0,
                          child: Container(
                            padding: const EdgeInsets.all(7),
                            decoration: BoxDecoration(
                              color: AppTheme.primaryColor,
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: theme.scaffoldBackgroundColor,
                                width: 2,
                              ),
                            ),
                            child: const Icon(
                              Icons.camera_alt,
                              size: 16,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 10),
                  GestureDetector(
                    onTap: _pickAvatar,
                    child: Text(
                      tr('updatePhoto', lang),
                      style: theme.textTheme.labelLarge?.copyWith(
                        color: theme.primaryColor,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 32),

            // ── Personal Details ─────────────────────────────────────────────
            _buildSectionTitle(context, tr('personalDetails', lang)),
            _buildDropdown(
              context,
              label: tr('gender', lang),
              value: user.gender,
              items: ['Male', 'Female', 'Other'],
              onChanged: (val) => userViewModel.updateGender(val!),
            ),
            const SizedBox(height: 16),

            // Age / Height / Weight — tap-to-open drum pickers
            Row(
              children: [
                Expanded(
                  child: _buildDrumPickerTile(
                    context,
                    label: tr('age', lang),
                    value: '${user.age}',
                    unit: 'yr',
                    onTap: () => _showDrumPicker(
                      title: tr('selectAge', lang),
                      minValue: 1,
                      maxValue: 120,
                      currentValue: user.age.toDouble(),
                      unit: 'yr',
                      onSelected: (v) => userViewModel.updateAge(v.toInt()),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildDrumPickerTile(
                    context,
                    label: tr('heightCm', lang),
                    value: '${user.height.toInt()}',
                    unit: 'cm',
                    onTap: () => _showDrumPicker(
                      title: tr('selectHeight', lang),
                      minValue: 50,
                      maxValue: 250,
                      currentValue: user.height,
                      unit: 'cm',
                      onSelected: (v) => userViewModel.updateHeight(v),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildDrumPickerTile(
                    context,
                    label: tr('weightKg', lang),
                    value: '${user.weight.toInt()}',
                    unit: 'kg',
                    onTap: () => _showDrumPicker(
                      title: tr('selectWeight', lang),
                      minValue: 20,
                      maxValue: 300,
                      currentValue: user.weight,
                      unit: 'kg',
                      onSelected: (v) => userViewModel.updateWeight(v),
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 32),

            // ── Goal & Activity ──────────────────────────────────────────────
            _buildSectionTitle(context, tr('goalActivity', lang)),
            _buildDropdown(
              context,
              label: tr('activityLevel', lang),
              value: user.activityLevel,
              items: AppConstants.activityLevels,
              onChanged: (val) => userViewModel.updateActivityLevel(val!),
            ),
            const SizedBox(height: 16),
            _buildDropdown(
              context,
              label: tr('goal', lang),
              value: user.goal,
              items: AppConstants.goals,
              onChanged: (val) => userViewModel.updateGoal(val!),
            ),

            const SizedBox(height: 32),

            // ── Restrictions / Allergens ─────────────────────────────────────
            _buildSectionTitle(context, tr('restrictions', lang)),
            _buildAllergenSection(context, user.allergies, lang),
          ],
        ),
      ),
    );
  }

  // ── Allergen section ────────────────────────────────────────────────────────

  Widget _buildAllergenSection(
    BuildContext context,
    List<String> userAllergies,
    String lang,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Preset common allergen chips
          Text(
            'Quick select:',
            style: TextStyle(
              color: AppTheme.textSecondary,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _commonAllergens.map((allergen) {
              final isSelected = userAllergies
                  .any((a) => a.toLowerCase() == allergen.toLowerCase());
              return GestureDetector(
                onTap: () => isSelected
                    ? _removeAllergy(allergen)
                    : _addAllergy(allergen),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 7,
                  ),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? AppTheme.errorColor.withOpacity(0.12)
                        : Theme.of(context).scaffoldBackgroundColor,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: isSelected
                          ? AppTheme.errorColor
                          : AppTheme.dividerColor,
                      width: 1.2,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (isSelected) ...[
                        Icon(
                          Icons.check,
                          size: 13,
                          color: AppTheme.errorColor,
                        ),
                        const SizedBox(width: 4),
                      ],
                      Text(
                        allergen,
                        style: TextStyle(
                          color: isSelected
                              ? AppTheme.errorColor
                              : Theme.of(context).textTheme.bodyLarge?.color,
                          fontSize: 13,
                          fontWeight: isSelected
                              ? FontWeight.w600
                              : FontWeight.normal,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 16),
          Divider(color: AppTheme.dividerColor),
          const SizedBox(height: 8),

          // Custom allergen input
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _allergyController,
                  style: TextStyle(
                    color: Theme.of(context).textTheme.bodyLarge?.color,
                  ),
                  decoration: InputDecoration(
                    hintText: tr('addIngredient', lang),
                    hintStyle: TextStyle(color: AppTheme.textSecondary),
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.zero,
                  ),
                  onSubmitted: _addAllergy,
                ),
              ),
              IconButton(
                icon: Icon(
                  Icons.add_circle,
                  color: AppTheme.primaryColor,
                ),
                onPressed: () => _addAllergy(_allergyController.text),
                tooltip: 'Add',
              ),
            ],
          ),

          // Selected (non-preset or all active) allergens as deletable chips
          if (userAllergies.isNotEmpty) ...[
            Divider(color: AppTheme.dividerColor),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 4,
              children: userAllergies.map((allergy) {
                return Chip(
                  label: Text(allergy),
                  backgroundColor: const Color(0xFFFFF5F3),
                  side: BorderSide(color: AppTheme.errorColor, width: 1),
                  labelStyle: TextStyle(
                    color: AppTheme.errorColor,
                    fontWeight: FontWeight.w500,
                    fontSize: 13,
                  ),
                  deleteIcon: Icon(
                    Icons.close,
                    size: 14,
                    color: AppTheme.errorColor,
                  ),
                  onDeleted: () => _removeAllergy(allergy),
                );
              }).toList(),
            ),
          ] else ...[
            const SizedBox(height: 4),
            Text(
              tr('noAllergies', lang),
              style: TextStyle(color: AppTheme.textSecondary, fontSize: 13),
            ),
          ],
        ],
      ),
    );
  }

  // ── Drum Picker Tile ────────────────────────────────────────────────────────

  Widget _buildDrumPickerTile(
    BuildContext context, {
    required String label,
    required String value,
    required String unit,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: TextStyle(
                color: Colors.grey[500],
                fontSize: 11,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 6),
            Row(
              children: [
                Expanded(
                  child: Text(
                    value,
                    style: TextStyle(
                      color: Theme.of(context).textTheme.bodyLarge?.color,
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                Icon(
                  Icons.expand_more_rounded,
                  color: AppTheme.primaryColor,
                  size: 20,
                ),
              ],
            ),
            Text(
              unit,
              style: TextStyle(
                color: AppTheme.textSecondary,
                fontSize: 11,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Helpers ─────────────────────────────────────────────────────────────────

  Widget _buildSectionTitle(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleLarge?.copyWith(
              color: Theme.of(context).primaryColor,
              fontWeight: FontWeight.bold,
            ),
      ),
    );
  }

  Widget _buildDropdown(
    BuildContext context, {
    required String label,
    required String value,
    required List<String> items,
    required Function(String?) onChanged,
  }) {
    final safeValue =
        items.contains(value) ? value : (items.isNotEmpty ? items.first : null);
    return DropdownButtonFormField<String>(
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: Colors.grey[400]),
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide.none,
          borderRadius: BorderRadius.circular(12),
        ),
        filled: true,
        fillColor: Theme.of(context).cardColor,
      ),
      dropdownColor: Theme.of(context).cardColor,
      value: safeValue,
      items: items
          .map((item) => DropdownMenuItem(value: item, child: Text(item)))
          .toList(),
      onChanged: onChanged,
    );
  }

}
