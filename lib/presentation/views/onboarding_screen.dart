import 'package:flutter/material.dart';
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
  final TextEditingController _ageController = TextEditingController();
  final TextEditingController _weightController = TextEditingController();
  final TextEditingController _heightController = TextEditingController();

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

    // Initialize controllers with default values from provider
    // We use a post-frame callback to access ref safely if needed,
    // but here we just want defaults. state might not be ready in initState for reading via ref.read??
    // Actually in ConsumerState, ref is available.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final state = ref.read(onboardingViewModelProvider);
      _ageController.text = state.age.toString();
      _weightController.text = state.weight
          .toInt()
          .toString(); // Display as int for cleanliness
      _heightController.text = state.height.toInt().toString();
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    _allergyController.dispose();
    _ageController.dispose();
    _weightController.dispose();
    _heightController.dispose();
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

          // Age Input
          _buildLabel('Age'),
          const SizedBox(height: 12),
          _buildNumberInput(
            controller: _ageController,
            suffix: 'years',
            onChanged: (val) {
              if (val.isNotEmpty) {
                final parsed = int.tryParse(val);
                if (parsed != null) viewModel.updateAge(parsed);
              }
            },
          ),
          const SizedBox(height: 32),

          // Weight Input
          _buildLabel('Weight'),
          const SizedBox(height: 12),
          _buildNumberInput(
            controller: _weightController,
            suffix: 'kg',
            onChanged: (val) {
              if (val.isNotEmpty) {
                final parsed = double.tryParse(val);
                if (parsed != null) viewModel.updateWeight(parsed);
              }
            },
          ),
          const SizedBox(height: 32),

          // Height Input
          _buildLabel('Height'),
          const SizedBox(height: 12),
          _buildNumberInput(
            controller: _heightController,
            suffix: 'cm',
            onChanged: (val) {
              if (val.isNotEmpty) {
                final parsed = double.tryParse(val);
                if (parsed != null) viewModel.updateHeight(parsed);
              }
            },
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

  Widget _buildNumberInput({
    required TextEditingController controller,
    required String suffix,
    required ValueChanged<String> onChanged,
  }) {
    return Container(
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
      child: TextFormField(
        controller: controller,
        keyboardType: TextInputType.number,
        onChanged: onChanged,
        style: TextStyle(
          color: AppTheme.textPrimary,
          fontSize: 18,
          fontWeight: FontWeight.w600,
        ),
        decoration: InputDecoration(
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          filled: true,
          fillColor: AppTheme.surfaceColor,
          suffixText: suffix,
          suffixStyle: TextStyle(
            color: AppTheme.textSecondary,
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 16,
          ),
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
