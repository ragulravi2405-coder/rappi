import 'package:flutter/material.dart';
import '../models/user.dart';
import '../services/auth_service.dart';

class AuthProvider extends ChangeNotifier {
  final AuthService _authService;
  
  User? _currentUser;
  bool _isLoading = false;
  String? _errorMessage;

  AuthProvider({AuthService? authService}) : _authService = authService ?? AuthService();

  User? get currentUser => _currentUser;
  bool get isAuthenticated => _currentUser != null;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  void _setError(String? message) {
    _errorMessage = message;
    notifyListeners();
  }

  /// Automatically attempt login on startup using persisted token
  Future<bool> tryAutoLogin() async {
    _setLoading(true);
    _setError(null);
    try {
      final hasSession = await _authService.hasSavedSession();
      if (!hasSession) {
        _setLoading(false);
        return false;
      }

      _currentUser = await _authService.getProfile();
      _setLoading(false);
      return true;
    } catch (e) {
      // Invalidate token if profile fetch fails (e.g. token expired)
      await _authService.clearSession();
      _currentUser = null;
      _setError(e.toString().replaceAll('Exception: ', ''));
      _setLoading(false);
      return false;
    }
  }

  /// Register a user
  Future<bool> register(String name, String email, String password) async {
    _setLoading(true);
    _setError(null);
    try {
      _currentUser = await _authService.register(name, email, password);
      _setLoading(false);
      return true;
    } catch (e) {
      _setError(e.toString().replaceAll('Exception: ', ''));
      _setLoading(false);
      return false;
    }
  }

  /// Authenticate credentials
  Future<bool> login(String email, String password) async {
    _setLoading(true);
    _setError(null);
    try {
      _currentUser = await _authService.login(email, password);
      _setLoading(false);
      return true;
    } catch (e) {
      _setError(e.toString().replaceAll('Exception: ', ''));
      _setLoading(false);
      return false;
    }
  }

  /// Logout active session
  Future<void> logout() async {
    _setLoading(true);
    try {
      await _authService.clearSession();
      _currentUser = null;
    } catch (e) {
      _setError(e.toString().replaceAll('Exception: ', ''));
    } finally {
      _setLoading(false);
    }
  }

  /// Delete account and wipe states
  Future<bool> deleteAccount() async {
    _setLoading(true);
    _setError(null);
    try {
      await _authService.deleteAccount();
      _currentUser = null;
      _setLoading(false);
      return true;
    } catch (e) {
      _setError(e.toString().replaceAll('Exception: ', ''));
      _setLoading(false);
      return false;
    }
  }
}
