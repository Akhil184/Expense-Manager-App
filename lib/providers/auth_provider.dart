
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../features/auth/services/auth_service.dart';

class AuthProvider extends ChangeNotifier {
  final AuthService _authService;

  AuthProvider(this._authService) {
    _currentUser = _authService.currentUser;

    _authSubscription = _authService.authStateChanges.listen((data) {
      _currentUser = data.session?.user;
      notifyListeners();
    });
  }

  User? _currentUser;
  bool _isLoading = false;
  String? _errorMessage;

  late final StreamSubscription<AuthState> _authSubscription;

  User? get currentUser => _currentUser;

  bool get isAuthenticated => _currentUser != null;

  bool get isLoading => _isLoading;

  String? get errorMessage => _errorMessage;

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  // Register new user
  Future<bool> signUp({
    required String email,
    required String password,
  }) async {
    _errorMessage = null;
    _setLoading(true);

    try {
      await _authService.signUp(
        email: email,
        password: password,
      );
      return true;
    } on AuthException catch (e) {
      _errorMessage = e.message;
      return false;
    } catch (e) {
      _errorMessage = 'Registration failed. Please try again.';
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Login
  Future<bool> login({
    required String email,
    required String password,
  }) async {
    _errorMessage = null;
    _setLoading(true);

    try {
      await _authService.login(
        email: email,
        password: password,
      );
      return true;
    } on AuthException catch (e) {
      _errorMessage = e.message;
      return false;
    } catch (e) {
      _errorMessage = 'Login failed. Please try again.';
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Logout
  Future<bool> logout() async {
    _errorMessage = null;
    _setLoading(true);

    try {
      await _authService.logout();
      return true;
    } on AuthException catch (e) {
      _errorMessage = e.message;
      return false;
    } catch (e) {
      _errorMessage = 'Logout failed. Please try again.';
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Forgot password
  Future<bool> resetPassword(String email) async {
    _errorMessage = null;
    _setLoading(true);

    try {
      await _authService.resetPassword(email);
      return true;
    } on AuthException catch (e) {
      _errorMessage = e.message;
      return false;
    } catch (e) {
      _errorMessage = 'Password reset failed. Please try again.';
      return false;
    } finally {
      _setLoading(false);
    }
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  @override
  void dispose() {
    _authSubscription.cancel();
    super.dispose();
  }
}

