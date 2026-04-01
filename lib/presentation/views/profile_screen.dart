import 'package:flutter/material.dart';
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

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(userViewModelProvider);
    final userViewModel = ref.read(userViewModelProvider.notifier);
    final theme = Theme.of(context);

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
        padding: const EdgeInsets.all(
          24.0,
        ), // Increased from 20 for premium feel
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 50,
                    backgroundColor: AppTheme.primaryColorLight, // Light green
                    backgroundImage: const NetworkImage(
                      'https://i.pravatar.cc/300',
                    ),
                    onBackgroundImageError: (_, __) {
                      // Handle error silently or show icon
                    },
                    child: Icon(
                      Icons.person,
                      size: 50,
                      color: AppTheme.primaryColor, // Soft green
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Change Profile',
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
                    value: user.age.toString(),
                    keyboardType: TextInputType.number,
                    onChanged: (val) {
                      if (val.isNotEmpty)
                        userViewModel.updateAge(int.parse(val));
                    },
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildTextField(
                    context,
                    label: 'Height (cm)',
                    value: user.height.toString(),
                    keyboardType: TextInputType.number,
                    onChanged: (val) {
                      if (val.isNotEmpty)
                        userViewModel.updateHeight(double.parse(val));
                    },
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildTextField(
                    context,
                    label: 'Weight (kg)',
                    value: user.weight.toString(),
                    keyboardType: TextInputType.number,
                    onChanged: (val) {
                      if (val.isNotEmpty)
                        userViewModel.updateWeight(double.parse(val));
                    },
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
                            hintText: 'Add ingredient (e.g., Peanuts, Milk)',
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
                  Divider(color: AppTheme.dividerColor), // Barely visible
                  user.allergies.isEmpty
                      ? Text(
                          'No allergies specified.',
                          style: TextStyle(color: AppTheme.textSecondary),
                        )
                      : Wrap(
                          spacing: 12, // Increased spacing
                          runSpacing: 8,
                          children: user.allergies
                              .map(
                                (allergy) => Chip(
                                  label: Text(allergy),
                                  backgroundColor: const Color(
                                    0xFFFFF5F3,
                                  ), // Light peachy-pink
                                  side: BorderSide(
                                    color: AppTheme.errorColor,
                                    width: 1,
                                  ),
                                  labelStyle: TextStyle(
                                    color:
                                        AppTheme.errorColor, // Soft peachy-red
                                    fontWeight: FontWeight.w500,
                                  ),
                                  deleteIcon: Icon(
                                    Icons.close,
                                    size: 16,
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
        style: Theme.of(
          context,
        ).textTheme.titleLarge?.copyWith(color: Theme.of(context).primaryColor),
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
    // Ensure value exists in items to prevent crash
    final safeValue = items.contains(value)
        ? value
        : (items.isNotEmpty ? items.first : null);

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
    required String value,
    required TextInputType keyboardType,
    required Function(String) onChanged,
  }) {
    return TextFormField(
      initialValue: value,
      style: TextStyle(color: Theme.of(context).textTheme.bodyLarge?.color),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: Colors.grey[400]),
        filled: true,
        fillColor: Theme.of(context).cardColor,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
      ),
      keyboardType: keyboardType,
      onChanged: onChanged,
    );
  }
}
