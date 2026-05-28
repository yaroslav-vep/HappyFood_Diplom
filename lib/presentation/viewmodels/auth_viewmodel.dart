import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/auth_state.dart';

class AuthViewModel extends StateNotifier<AuthState> {
  AuthViewModel([AuthState? initialState])
      : super(initialState ?? const AuthState(status: AuthStatus.unauthenticated));

  Future<void> login(String email, String password) async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    await Future.delayed(const Duration(seconds: 1)); // Mock delay

    if (email.isNotEmpty && password.length >= 6) {
      final newState = state.copyWith(
        status: AuthStatus.authenticated,
        email: email,
        isLoading: false,
      );
      state = newState;
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('is_logged_in', true);
      await prefs.setString('auth_email', email);
    } else {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Invalid email or password (min 6 chars)',
      );
    }
  }

  Future<void> register(String email, String password) async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    await Future.delayed(const Duration(seconds: 1));

    if (email.isNotEmpty && password.length >= 6) {
      final newState = state.copyWith(
        status: AuthStatus.authenticated,
        email: email,
        isLoading: false,
      );
      state = newState;
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('is_logged_in', true);
      await prefs.setString('auth_email', email);
    } else {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Registration failed',
      );
    }
  }

  void logout() async {
    state = const AuthState(status: AuthStatus.unauthenticated);
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('is_logged_in');
    await prefs.remove('auth_email');
    await prefs.remove('user_data');
    await prefs.remove('last_selected_tab');
  }
}

final authViewModelProvider = StateNotifierProvider<AuthViewModel, AuthState>((
  ref,
) {
  return AuthViewModel();
});
