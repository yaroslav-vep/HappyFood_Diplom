import 'dart:convert';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:happyfood/firebase_options.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'core/constant/app_theme.dart';
import 'presentation/views/main_screen.dart';
import 'presentation/views/onboarding_screen.dart';
import 'presentation/viewmodels/theme_viewmodel.dart';
import 'core/auth_state.dart';
import 'presentation/viewmodels/auth_viewmodel.dart';
import 'presentation/views/login_screen.dart';
import 'presentation/viewmodels/user_viewmodel.dart';
import 'data/models/user_model.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // Load user data before app start
  final prefs = await SharedPreferences.getInstance();
  final userJson = prefs.getString('user_data');
  final initialUser = userJson != null
      ? UserModel.fromJson(jsonDecode(userJson))
      : null;

  final isLoggedIn = prefs.getBool('is_logged_in') ?? false;
  final email = prefs.getString('auth_email');
  final initialAuthState = isLoggedIn
      ? AuthState(status: AuthStatus.authenticated, email: email)
      : const AuthState(status: AuthStatus.unauthenticated);

  runApp(
    ProviderScope(
      overrides: [
        userViewModelProvider.overrideWith((ref) => UserViewModel(initialUser)),
        authViewModelProvider.overrideWith((ref) => AuthViewModel(initialAuthState)),
      ],
      child: const HappyFoodApp(),
    ),
  );
}

class HappyFoodApp extends ConsumerWidget {
  const HappyFoodApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeViewModelProvider);
    final authState = ref.watch(authViewModelProvider);
    final userState = ref.watch(userViewModelProvider);

    return MaterialApp(
      title: 'HappyFood',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: themeMode,
      home: authState.status == AuthStatus.authenticated
          ? (userState.isOnboardingCompleted
                ? const MainScreen()
                : const OnboardingScreen())
          : const LoginScreen(),
    );
  }
}
