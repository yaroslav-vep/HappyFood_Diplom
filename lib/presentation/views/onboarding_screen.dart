import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constant/app_theme.dart';
import '../viewmodels/onboarding_viewmodel.dart';
import 'main_screen.dart';

class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  final TextEditingController _allergyController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    _slideAnimation =
        Tween<Offset>(begin: const Offset(0.3, 0), end: Offset.zero).animate(
          CurvedAnimation(
            parent: _animationController,
            curve: Curves.easeOutCubic,
          ),
        );
    _animationController.forward();
  }

  void _showDrumPicker({
    required BuildContext context,
    required String title,
    required int minValue,
    required int maxValue,
    required double currentValue,
    required String unit,
    required Function(double) onSelected,
  }) {
    int selectedIndex =
        (currentValue.toInt() - minValue).clamp(0, maxValue - minValue);
    showModalBottomSheet(
      context: context,
      backgroundColor: AppTheme.surfaceColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return SizedBox(
          height: 320,
          child: Column(
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
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.pop(ctx),
                      child: Text(
                        'Cancel',
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
                        Navigator.pop(ctx);
                      },
                      child: Text(
                        'Confirm',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: AppTheme.primaryColor,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Stack(
                  alignment: Alignment.center,
                  children: [
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
                      selectionOverlay:
                          const CupertinoPickerDefaultSelectionOverlay(
                        background: Colors.transparent,
                      ),
                      children: List.generate(
                        maxValue - minValue + 1,
                        (idx) => Center(
                          child: Text(
                            '${idx + minValue} $unit',
                            style: TextStyle(
                              color: AppTheme.textPrimary,
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

  @override
  void dispose() {
    _animationController.dispose();
    _allergyController.dispose();
    super.dispose();
  }

  void _playTransition() {
    _animationController.reset();
    _animationController.forward();
  }

  @override
  Widget build(BuildContext context) {
    final onboardingState = ref.watch(onboardingViewModelProvider);
    final viewModel = ref.read(onboardingViewModelProvider.notifier);

    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            // Progress indicator
            _buildProgressIndicator(onboardingState),

            // Main content
            Expanded(
              child: FadeTransition(
                opacity: _fadeAnimation,
                child: SlideTransition(
                  position: _slideAnimation,
                  child: _buildStepContent(onboardingState, viewModel),
                ),
              ),
            ),

            // Navigation buttons
            _buildNavigationButtons(onboardingState, viewModel),
          ],
        ),
      ),
    );
  }

  Widget _buildProgressIndicator(OnboardingState state) {
    return Container(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          // Progress bar
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: state.progressPercentage,
              minHeight: 6,
              backgroundColor: AppTheme.dividerColor,
              valueColor: AlwaysStoppedAnimation<Color>(AppTheme.primaryColor),
            ),
          ),
          const SizedBox(height: 12),
          // Step indicator text
          Text(
            state.stepIndicatorText,
            style: TextStyle(
              color: AppTheme.textSecondary,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStepContent(
    OnboardingState state,
    OnboardingViewModel viewModel,
  ) {
    switch (state.currentStep) {
      case 0:
        return _buildStep1BasicInfo(state, viewModel);
      case 1:
        return _buildStep2Goals(state, viewModel);
      case 2:
        return _buildStep3Preferences(state, viewModel);
      case 3:
        return _buildStep4Summary(state, viewModel);
      default:
        return const SizedBox();
    }
  }

  // ... (animations logic)

  // ============ STEP 1: Basic Information ============
  Widget _buildStep1BasicInfo(
    OnboardingState state,
    OnboardingViewModel viewModel,
  ) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: 20),
          Text(
            'Let\'s personalize your health journey',
            style: TextStyle(
              color: AppTheme.textPrimary,
              fontSize: 24,
              fontWeight: FontWeight.w600,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),
          Text(
            'We\'ll create a nutrition plan tailored to you',
            style: TextStyle(
              color: AppTheme.textSecondary,
              fontSize: 16,
              fontWeight: FontWeight.w400,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 40),

          // Gender selector
          _buildLabel('Gender'),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildSegmentedButton(
                  'Male',
                  state.gender == 'Male',
                  () => viewModel.updateGender('Male'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildSegmentedButton(
                  'Female',
                  state.gender == 'Female',
                  () => viewModel.updateGender('Female'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildSegmentedButton(
                  'Other',
                  state.gender == 'Other',
                  () => viewModel.updateGender('Other'),
                ),
              ),
            ],
          ),
          const SizedBox(height: 32),

          // Age drum picker
          _buildLabel('Age'),
          const SizedBox(height: 12),
          _buildDrumPickerTile(
            label: 'Age',
            value: '${state.age}',
            unit: 'years',
            onTap: () => _showDrumPicker(
              context: context,
              title: 'Select Age',
              minValue: 1,
              maxValue: 120,
              currentValue: state.age.toDouble(),
              unit: 'years',
              onSelected: (v) => viewModel.updateAge(v.toInt()),
            ),
          ),
          const SizedBox(height: 32),

          // Weight drum picker
          _buildLabel('Weight'),
          const SizedBox(height: 12),
          _buildDrumPickerTile(
            label: 'Weight',
            value: '${state.weight.toInt()}',
            unit: 'kg',
            onTap: () => _showDrumPicker(
              context: context,
              title: 'Select Weight',
              minValue: 20,
              maxValue: 300,
              currentValue: state.weight,
              unit: 'kg',
              onSelected: (v) => viewModel.updateWeight(v),
            ),
          ),
          const SizedBox(height: 32),

          // Height drum picker
          _buildLabel('Height'),
          const SizedBox(height: 12),
          _buildDrumPickerTile(
            label: 'Height',
            value: '${state.height.toInt()}',
            unit: 'cm',
            onTap: () => _showDrumPicker(
              context: context,
              title: 'Select Height',
              minValue: 50,
              maxValue: 250,
              currentValue: state.height,
              unit: 'cm',
              onSelected: (v) => viewModel.updateHeight(v),
            ),
          ),
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  // ============ STEP 2: Goals ============
  Widget _buildStep2Goals(
    OnboardingState state,
    OnboardingViewModel viewModel,
  ) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: 20),
          Text(
            'What\'s your goal?',
            style: TextStyle(
              color: AppTheme.textPrimary,
              fontSize: 24,
              fontWeight: FontWeight.w600,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 40),

          // Goal cards
          _buildGoalCard(
            title: 'Lose Weight',
            icon: Icons.trending_down,
            isSelected: state.goal == 'Lose Weight',
            onTap: () => viewModel.updateGoal('Lose Weight'),
          ),
          const SizedBox(height: 16),
          _buildGoalCard(
            title: 'Maintain Weight',
            icon: Icons.balance,
            isSelected: state.goal == 'Maintain Weight',
            onTap: () => viewModel.updateGoal('Maintain Weight'),
          ),
          const SizedBox(height: 16),
          _buildGoalCard(
            title: 'Gain Weight',
            icon: Icons.trending_up,
            isSelected: state.goal == 'Gain Weight',
            onTap: () => viewModel.updateGoal('Gain Weight'),
          ),
          const SizedBox(height: 40),

          // Activity level
          _buildLabel('Activity Level'),
          const SizedBox(height: 12),
          _buildActivityCard(
            title: 'Sedentary',
            description: 'Little to no exercise',
            isSelected: state.activityLevel == 'Sedentary',
            onTap: () => viewModel.updateActivityLevel('Sedentary'),
          ),
          const SizedBox(height: 12),
          _buildActivityCard(
            title: 'Moderately Active',
            description: 'Exercise 3-5 days/week',
            isSelected: state.activityLevel == 'Moderately Active',
            onTap: () => viewModel.updateActivityLevel('Moderately Active'),
          ),
          const SizedBox(height: 12),
          _buildActivityCard(
            title: 'Very Active',
            description: 'Exercise 6-7 days/week',
            isSelected: state.activityLevel == 'Very Active',
            onTap: () => viewModel.updateActivityLevel('Very Active'),
          ),
          const SizedBox(height: 12),
          _buildActivityCard(
            title: 'Extremely Active',
            description: 'Physical job + exercise',
            isSelected: state.activityLevel == 'Extremely Active',
            onTap: () => viewModel.updateActivityLevel('Extremely Active'),
          ),
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  // ============ STEP 3: Dietary Preferences ============
  Widget _buildStep3Preferences(
    OnboardingState state,
    OnboardingViewModel viewModel,
  ) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: 20),
          Text(
            'Dietary Preferences',
            style: TextStyle(
              color: AppTheme.textPrimary,
              fontSize: 24,
              fontWeight: FontWeight.w600,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),
          Text(
            'Help us personalize your meal recommendations',
            style: TextStyle(
              color: AppTheme.textSecondary,
              fontSize: 16,
              fontWeight: FontWeight.w400,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 40),

          _buildLabel('Allergies & Restrictions (Optional)'),
          const SizedBox(height: 16),

          // Common allergies
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              _buildAllergyChip('Dairy', state, viewModel),
              _buildAllergyChip('Gluten', state, viewModel),
              _buildAllergyChip('Nuts', state, viewModel),
              _buildAllergyChip('Shellfish', state, viewModel),
              _buildAllergyChip('Soy', state, viewModel),
              _buildAllergyChip('Eggs', state, viewModel),
            ],
          ),
          const SizedBox(height: 24),

          // Custom allergy input
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _allergyController,
                  decoration: InputDecoration(
                    hintText: 'Add custom restriction...',
                    filled: true,
                    fillColor: AppTheme.surfaceColor,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              IconButton(
                onPressed: () {
                  if (_allergyController.text.isNotEmpty) {
                    viewModel.addAllergy(_allergyController.text);
                    _allergyController.clear();
                  }
                },
                icon: Icon(
                  Icons.add_circle,
                  color: AppTheme.primaryColor,
                  size: 32,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Selected allergies
          if (state.allergies.isNotEmpty) ...[
            _buildLabel('Your Restrictions'),
            const SizedBox(height: 12),
            Wrap(
              spacing: 12,
              runSpacing: 8,
              children: state.allergies
                  .map(
                    (allergy) => Chip(
                      label: Text(allergy),
                      backgroundColor: const Color(0xFFFFF5F3),
                      side: BorderSide(color: AppTheme.errorColor, width: 1),
                      labelStyle: TextStyle(
                        color: AppTheme.errorColor,
                        fontWeight: FontWeight.w500,
                      ),
                      deleteIcon: Icon(
                        Icons.close,
                        size: 16,
                        color: AppTheme.errorColor,
                      ),
                      onDeleted: () => viewModel.removeAllergy(allergy),
                    ),
                  )
                  .toList(),
            ),
            const SizedBox(height: 24),
          ],

          // Show BMI preview
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppTheme.surfaceColor,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: AppTheme.primaryColor.withOpacity(0.04),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Your BMI',
                      style: TextStyle(
                        color: AppTheme.textSecondary,
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Text(
                      '${state.bmi.toStringAsFixed(1)} (${state.bmiCategory})',
                      style: TextStyle(
                        color: AppTheme.primaryColor,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Daily Calories',
                      style: TextStyle(
                        color: AppTheme.textSecondary,
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Text(
                      '${state.dailyCalories.round()} kcal',
                      style: TextStyle(
                        color: AppTheme.primaryColor,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  // ============ STEP 4: Summary ============
  Widget _buildStep4Summary(
    OnboardingState state,
    OnboardingViewModel viewModel,
  ) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: 40),
          // Celebration icon (elegant, not childish)
          Icon(
            Icons.check_circle_outline,
            size: 80,
            color: AppTheme.primaryColor,
          ),
          const SizedBox(height: 24),
          Text(
            'Your Personalized Plan is Ready!',
            style: TextStyle(
              color: AppTheme.textPrimary,
              fontSize: 26,
              fontWeight: FontWeight.w600,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 48),

          // BMI Card
          _buildSummaryCard(
            icon: Icons.monitor_weight_outlined,
            label: 'Body Mass Index',
            value: '${state.bmi.toStringAsFixed(1)}',
            subtitle: state.bmiCategory,
            color: _getBMIColor(state.bmi),
          ),
          const SizedBox(height: 20),

          // Calorie Card
          _buildSummaryCard(
            icon: Icons.local_fire_department_outlined,
            label: 'Daily Calorie Target',
            value: '${state.dailyCalories.round()} kcal',
            subtitle: state.calorieExplanation,
            color: AppTheme.primaryColor,
          ),
          const SizedBox(height: 20),

          // Goal Card
          _buildSummaryCard(
            icon: Icons.flag_outlined,
            label: 'Your Goal',
            value: state.goal,
            subtitle: 'Activity: ${state.activityLevel}',
            color: AppTheme.accentColor,
          ),
          const SizedBox(height: 40),

          // Motivational message
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppTheme.primaryColorLight,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Text(
              _getMotivationalMessage(state.goal),
              style: TextStyle(
                color: AppTheme.textPrimary,
                fontSize: 15,
                fontWeight: FontWeight.w400,
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  // ============ Helper Widgets ============

  Widget _buildLabel(String text) {
    return Text(
      text,
      style: TextStyle(
        color: AppTheme.textPrimary,
        fontSize: 16,
        fontWeight: FontWeight.w600,
      ),
    );
  }

  Widget _buildSegmentedButton(
    String text,
    bool isSelected,
    VoidCallback onTap,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: isSelected ? AppTheme.primaryColor : AppTheme.surfaceColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? AppTheme.primaryColor : AppTheme.dividerColor,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Text(
          text,
          style: TextStyle(
            color: isSelected ? Colors.white : AppTheme.textPrimary,
            fontSize: 15,
            fontWeight: FontWeight.w500,
          ),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }

  Widget _buildDrumPickerTile({
    required String label,
    required String value,
    required String unit,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        decoration: BoxDecoration(
          color: AppTheme.surfaceColor,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: AppTheme.primaryColor.withOpacity(0.04),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    value,
                    style: TextStyle(
                      color: AppTheme.textPrimary,
                      fontSize: 26,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  Text(
                    unit,
                    style: TextStyle(
                      color: AppTheme.textSecondary,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.expand_more_rounded,
              color: AppTheme.primaryColor,
              size: 26,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGoalCard({
    required String title,
    required IconData icon,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: AppTheme.surfaceColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? AppTheme.primaryColor : AppTheme.dividerColor,
            width: isSelected ? 2 : 1,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: AppTheme.primaryColor.withOpacity(0.1),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ]
              : null,
        ),
        child: Row(
          children: [
            Icon(
              icon,
              size: 32,
              color: isSelected
                  ? AppTheme.primaryColor
                  : AppTheme.textSecondary,
            ),
            const SizedBox(width: 16),
            Text(
              title,
              style: TextStyle(
                color: AppTheme.textPrimary,
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            const Spacer(),
            if (isSelected)
              Icon(Icons.check_circle, color: AppTheme.primaryColor, size: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildActivityCard({
    required String title,
    required String description,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppTheme.surfaceColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? AppTheme.primaryColor : AppTheme.dividerColor,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      color: AppTheme.textPrimary,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    description,
                    style: TextStyle(
                      color: AppTheme.textSecondary,
                      fontSize: 13,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ],
              ),
            ),
            if (isSelected)
              Icon(Icons.check_circle, color: AppTheme.primaryColor, size: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildAllergyChip(
    String allergy,
    OnboardingState state,
    OnboardingViewModel viewModel,
  ) {
    final isSelected = state.allergies.contains(allergy);
    return GestureDetector(
      onTap: () {
        if (isSelected) {
          viewModel.removeAllergy(allergy);
        } else {
          viewModel.addAllergy(allergy);
        }
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFFFF5F3) : AppTheme.surfaceColor,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? AppTheme.errorColor : AppTheme.dividerColor,
            width: 1,
          ),
        ),
        child: Text(
          allergy,
          style: TextStyle(
            color: isSelected ? AppTheme.errorColor : AppTheme.textPrimary,
            fontSize: 14,
            fontWeight: isSelected ? FontWeight.w500 : FontWeight.w400,
          ),
        ),
      ),
    );
  }

  Widget _buildSummaryCard({
    required IconData icon,
    required String label,
    required String value,
    required String subtitle,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.surfaceColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primaryColor.withOpacity(0.04),
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
              Icon(icon, color: color, size: 28),
              const SizedBox(width: 12),
              Text(
                label,
                style: TextStyle(
                  color: AppTheme.textSecondary,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: TextStyle(
              color: AppTheme.textPrimary,
              fontSize: 28,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            subtitle,
            style: TextStyle(
              color: AppTheme.textSecondary,
              fontSize: 14,
              fontWeight: FontWeight.w400,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNavigationButtons(
    OnboardingState state,
    OnboardingViewModel viewModel,
  ) {
    final isLastStep = state.currentStep == 3;
    final canProceed = state.isStepValid;

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppTheme.surfaceColor,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Back button
          if (state.currentStep > 0)
            Expanded(
              child: OutlinedButton(
                onPressed: () {
                  viewModel.previousStep();
                  _playTransition();
                },
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: const Text('Back'),
              ),
            ),
          if (state.currentStep > 0) const SizedBox(width: 16),

          // Continue/Finish button
          Expanded(
            flex: state.currentStep == 0 ? 1 : 1,
            child: ElevatedButton(
              onPressed: canProceed
                  ? () async {
                      if (isLastStep) {
                        // Submit and navigate to main screen
                        await viewModel.submitOnboarding();
                        if (mounted) {
                          Navigator.of(context).pushReplacement(
                            MaterialPageRoute(
                              builder: (context) => const MainScreen(),
                            ),
                          );
                        }
                      } else {
                        viewModel.nextStep();
                        _playTransition();
                      }
                    }
                  : null,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: Text(isLastStep ? 'Start Your Journey' : 'Continue'),
            ),
          ),
        ],
      ),
    );
  }

  Color _getBMIColor(double bmi) {
    if (bmi < 18.5 || bmi >= 30) return AppTheme.errorColor;
    if (bmi >= 25) return const Color(0xFFFFA726); // Soft orange
    return AppTheme.successColor;
  }

  String _getMotivationalMessage(String goal) {
    switch (goal.toLowerCase()) {
      case 'lose weight':
        return 'You\'re taking the first step towards a healthier you. Stay consistent, and the results will follow.';
      case 'gain weight':
        return 'Building a stronger, healthier body takes time. Trust the process and stay committed.';
      case 'maintain weight':
        return 'Maintaining balance is just as important as change. You\'re on the right track.';
      default:
        return 'We\'re here to support you on your journey to better health.';
    }
  }
}
