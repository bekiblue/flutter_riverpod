import 'package:agazh/application/auth/auth_states.dart';
import 'package:agazh/domain/auth/user_model.dart';
import 'package:agazh/infrastructure/auth/auth_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthNotifier extends StateNotifier<AuthState> {
  AuthRepository authRepository = AuthRepository();

  AuthNotifier() : super(AuthIitialState());

  Future<void> logout() async {
    var prefs = await SharedPreferences.getInstance();
    await prefs.remove('token');
    state = AuthIitialState();
  }

  Future<void> initialize() async {
    var prefs = await SharedPreferences.getInstance();
    var token = prefs.getString('token');
    if (token != null) {
      try {
        User user = await authRepository.getMe(token);
        state = AuthSuccessState(token: token, user: user);
      } catch (e) {
        state = AuthErrorState(message: e.toString());
      }
    } else {
      state = AuthIitialState();
    }
  }

  Future<void> register(String username, String email, String password, Role role) async {
    state = AuthLoadingState();
    try {
      await authRepository.register(username, email, password, role);

      var token = await authRepository.login(username, password);
      var prefs = await SharedPreferences.getInstance();
      prefs.setString('token', token);
      User user = await authRepository.getMe(token);
      state = AuthSuccessState(token: token, user: user);
    } catch (e) {
      state = AuthErrorState(message: e.toString());
    }
  }

  Future<void> login(String email, String password) async {
    state = AuthLoadingState();
    try {
      var token = await authRepository.login(email, password);
      var prefs = await SharedPreferences.getInstance();
      prefs.setString('token', token);
      User user = await authRepository.getMe(token);
      state = AuthSuccessState(token: token, user: user);
    } catch (e) {
      state = AuthErrorState(message: e.toString());
    }
  }
}

final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return AuthNotifier();
});
