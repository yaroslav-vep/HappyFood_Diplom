import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/constant/app_theme.dart';
import 'presentation/views/main_screen.dart';
import 'presentation/viewmodels/theme_viewmodel.dart';
import 'core/auth_state.dart';
import 'presentation/viewmodels/auth_viewmodel.dart';
import 'presentation/views/login_screen.dart';

void main() {
  runApp(const ProviderScope(child: HappyFoodApp()));
}

class HappyFoodApp extends ConsumerWidget {
  const HappyFoodApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeViewModelProvider);
    final authState = ref.watch(authViewModelProvider);

    return MaterialApp(
      title: 'HappyFood',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: themeMode,
      home: authState.status == AuthStatus.authenticated
          ? const MainScreen()
          : const LoginScreen(),
    );
  }
}
