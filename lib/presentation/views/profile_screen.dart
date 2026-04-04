import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants/app_constants.dart';
import '../../core/constant/app_theme.dart';
import '../viewmodels/user_viewmodel.dart';
import 'settings_screen.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  final TextEditingController _allergyController = TextEditingController();
  final TextEditingController _ageController = TextEditingController();
  final TextEditingController _heightController = TextEditingController();
  final TextEditingController _weightController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final user = ref.read(userViewModelProvider);
      _ageController.text = user.age.toString();
      _heightController.text = user.height.toString();
      _weightController.text = user.weight.toString();
    });
  }

  @override
  void dispose() {
    _allergyController.dispose();
    _ageController.dispose();
    _heightController.dispose();
    _weightController.dispose();
    super.dispose();
  }

  void _addAllergy() {
    if (_allergyController.text.isNotEmpty) {
      final user = ref.read(userViewModelProvider);
      final currentAllergies = List<String>.from(user.allergies);
      if (!currentAllergies.contains(_allergyController.text.trim())) {
        currentAllergies.add(_allergyController.text.trim());
        ref
            .read(userViewModelProvider.notifier)
            .updateAllergies(currentAllergies);
      }
      _allergyController.clear();
    }
  }

  void _removeAllergy(String allergy) {
    final user = ref.read(userViewModelProvider);
    final currentAllergies = List<String>.from(user.allergies);
    currentAllergies.remove(allergy);
    ref.read(userViewModelProvider.notifier).updateAllergies(currentAllergies);
  }

  void _showPicker({
    required String title,
    required int minValue,
    required int maxValue,
    required double initialValue,
    required Function(double) onSelected,
    bool isDouble = false,
  }) {
    int selectedIndex = (initialValue - minValue).toInt();
    if (isDouble) {
      // For double values, we'll just handle integers for simplicity in the wheel 
      // or implement a more complex two-wheel picker. 
      // User asked for "mini drum", integers are usually preferred for these ranges.
    }

    showModalBottomSheet(
      context: context,
      backgroundColor: Theme.of(context).cardColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return SizedBox(
          height: 300,
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: Text('Cancel', style: TextStyle(color: AppTheme.textSecondary)),
                    ),
                    Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                    TextButton(
                      onPressed: () {
                        onSelected(selectedIndex.toDouble() + minValue);
                        Navigator.pop(context);
                      },
                      child: const Text('Confirm', style: TextStyle(fontWeight: FontWeight.bold)),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: CupertinoPicker(
                  itemExtent: 40,
                  scrollController: FixedExtentScrollController(initialItem: selectedIndex),
                  onSelectedItemChanged: (index) {
                    selectedIndex = index;
                  },
                  children: List.generate(maxValue - minValue + 1, (index) {
                    return Center(
                      child: Text(
                        '${index + minValue}',
                        style: TextStyle(color: Theme.of(context).textTheme.bodyLarge?.color),
                      ),
                    );
                  }),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(userViewModelProvider);
    final userViewModel = ref.read(userViewModelProvider.notifier);
    final theme = Theme.of(context);

    // Sync controllers if model changes from elsewhere
    _ageController.text = user.age.toString();
    _heightController.text = user.height.toString();
    _weightController.text = user.weight.toString();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        centerTitle: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const SettingsScreen()),
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 50,
                    backgroundColor: AppTheme.primaryColorLight,
                    backgroundImage: const NetworkImage(
                      'https://i.pravatar.cc/300',
                    ),
                    child: Icon(
                      Icons.person,
                      size: 50,
                      color: AppTheme.primaryColor,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Update Photo',
                    style: theme.textTheme.labelLarge?.copyWith(
                      color: Theme.of(context).primaryColor,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),
            _buildSectionTitle(context, 'Personal Details'),
            _buildDropdown(
              context,
              label: 'Gender',
              value: user.gender,
              items: ['Male', 'Female', 'Other'],
              onChanged: (val) => userViewModel.updateGender(val!),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildTextField(
                    context,
                    label: 'Age',
                    controller: _ageController,
                    onChanged: (val) {
                      if (val.isNotEmpty) userViewModel.updateAge(int.parse(val));
                    },
                    onPickerTap: () => _showPicker(
                      title: 'Select Age',
                      minValue: 1,
                      maxValue: 120,
                      initialValue: user.age.toDouble(),
                      onSelected: (val) => userViewModel.updateAge(val.toInt()),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildTextField(
                    context,
                    label: 'H (cm)',
                    controller: _heightController,
                    onChanged: (val) {
                      if (val.isNotEmpty) userViewModel.updateHeight(double.parse(val));
                    },
                    onPickerTap: () => _showPicker(
                      title: 'Select Height',
                      minValue: 50,
                      maxValue: 250,
                      initialValue: user.height,
                      onSelected: (val) => userViewModel.updateHeight(val),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildTextField(
                    context,
                    label: 'W (kg)',
                    controller: _weightController,
                    onChanged: (val) {
                      if (val.isNotEmpty) userViewModel.updateWeight(double.parse(val));
                    },
                    onPickerTap: () => _showPicker(
                      title: 'Select Weight',
                      minValue: 20,
                      maxValue: 300,
                      initialValue: user.weight,
                      onSelected: (val) => userViewModel.updateWeight(val),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 32),
            _buildSectionTitle(context, 'Goal & Activity'),
            _buildDropdown(
              context,
              label: 'Activity Level',
              value: user.activityLevel,
              items: AppConstants.activityLevels,
              onChanged: (val) => userViewModel.updateActivityLevel(val!),
            ),
            const SizedBox(height: 16),
            _buildDropdown(
              context,
              label: 'Goal',
              value: user.goal,
              items: AppConstants.goals,
              onChanged: (val) => userViewModel.updateGoal(val!),
            ),
            const SizedBox(height: 32),
            _buildSectionTitle(context, 'Restrictions (Allergies)'),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _allergyController,
                          decoration: const InputDecoration(
                            hintText: 'Add ingredient',
                            hintStyle: TextStyle(color: Colors.grey),
                            border: InputBorder.none,
                          ),
                          style: TextStyle(
                            color: Theme.of(context).textTheme.bodyLarge?.color,
                          ),
                          onSubmitted: (_) => _addAllergy(),
                        ),
                      ),
                      IconButton(
                        icon: Icon(
                          Icons.add_circle,
                          color: Theme.of(context).primaryColor,
                        ),
                        onPressed: _addAllergy,
                      ),
                    ],
                  ),
                  Divider(color: AppTheme.dividerColor),
                  user.allergies.isEmpty
                      ? Text(
                          'No allergies specified.',
                          style: TextStyle(color: AppTheme.textSecondary),
                        )
                      : Wrap(
                          spacing: 8,
                          runSpacing: 4,
                          children: user.allergies
                              .map(
                                (allergy) => Chip(
                                  label: Text(allergy),
                                  backgroundColor: const Color(0xFFFFF5F3),
                                  side: BorderSide(
                                    color: AppTheme.errorColor,
                                    width: 1,
                                  ),
                                  labelStyle: TextStyle(
                                    color: AppTheme.errorColor,
                                    fontWeight: FontWeight.w500,
                                  ),
                                  deleteIcon: Icon(
                                    Icons.close,
                                    size: 14,
                                    color: AppTheme.errorColor,
                                  ),
                                  onDeleted: () => _removeAllergy(allergy),
                                ),
                              )
                              .toList(),
                        ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

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
    final safeValue = items.contains(value) ? value : (items.isNotEmpty ? items.first : null);

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
      items: items.map((item) {
        return DropdownMenuItem(value: item, child: Text(item));
      }).toList(),
      onChanged: onChanged,
    );
  }

  Widget _buildTextField(
    BuildContext context, {
    required String label,
    required TextEditingController controller,
    required Function(String) onChanged,
    required VoidCallback onPickerTap,
  }) {
    return TextFormField(
      controller: controller,
      style: TextStyle(color: Theme.of(context).textTheme.bodyLarge?.color),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: Colors.grey[400], fontSize: 13),
        filled: true,
        fillColor: Theme.of(context).cardColor,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        suffixIcon: IconButton(
          icon: Icon(Icons.unfold_more, color: Theme.of(context).primaryColor, size: 20),
          onPressed: onPickerTap,
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
      ),
      keyboardType: TextInputType.number,
      onChanged: onChanged,
    );
  }
}
