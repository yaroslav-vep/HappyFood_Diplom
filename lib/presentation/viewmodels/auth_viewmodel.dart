import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/auth_state.dart';

class AuthViewModel extends StateNotifier<AuthState> {
  AuthViewModel() : super(const AuthState(status: AuthStatus.unauthenticated));

  Future<void> login(String email, String password) async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    await Future.delayed(const Duration(seconds: 1)); // Mock delay

    if (email.isNotEmpty && password.length >= 6) {
      state = state.copyWith(
        status: AuthStatus.authenticated,
        email: email,
        isLoading: false,
      );
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
      state = state.copyWith(
        status: AuthStatus.authenticated,
        email: email,
        isLoading: false,
      );
    } else {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Registration failed',
      );
    }
  }

  void logout() {
    state = const AuthState(status: AuthStatus.unauthenticated);
  }
}

final authViewModelProvider = StateNotifierProvider<AuthViewModel, AuthState>((
  ref,
) {
  return AuthViewModel();
});
