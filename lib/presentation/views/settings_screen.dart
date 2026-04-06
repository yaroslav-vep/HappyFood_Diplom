import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../viewmodels/theme_viewmodel.dart';
import '../../core/constant/app_theme.dart';
import '../../core/localization/app_localizations.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeViewModelProvider);
    final isDark = themeMode == ThemeMode.dark;
    final lang = ref.watch(languageProvider);

    return Scaffold(
      appBar: AppBar(title: Text(tr('settings', lang))),
      body: ListView(
        children: [
          SwitchListTile(
            title: Text(tr('darkMode', lang)),
            subtitle: Text(isDark ? tr('enabled', lang) : tr('disabled', lang)),
            value: isDark,
            activeColor: AppTheme.primaryColor,
            onChanged: (val) {
              ref.read(themeViewModelProvider.notifier).toggleTheme();
            },
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.info_outline),
            title: Text(tr('aboutApp', lang)),
            subtitle: Text(tr('version', lang)),
          ),
        ],
      ),
    );
  }
}
