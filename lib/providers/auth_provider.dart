import 'package:flutter/foundation.dart';
import '../models/user_model.dart';
import '../services/auth_service.dart';

class AuthProvider with ChangeNotifier {
  final AuthService _authService = AuthService();

  UserModel? _user;
  UserModel? get user => _user;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  AuthProvider() {
    _initAuth();
  }

  Future<void> _initAuth() async {
    _authService.authStateChanges.listen((user) async {
      if (user != null) {
        _isLoading = true;
        notifyListeners();
        _user = await _authService.getUserData(user.uid);
        _isLoading = false;
        notifyListeners();
      } else {
        _user = null;
        notifyListeners();
      }
    });
  }

  Future<bool> register({
    required String email,
    required String password,
    required String fullName,
    required String phone,
    String? invitationCode,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _authService.registerWithEmailAndPassword(
        email: email,
        password: password,
        fullName: fullName,
        phone: phone,
        invitationCode: invitationCode,
      );
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _isLoading = false;
      _errorMessage = _getErrorMessage(e);
      notifyListeners();
      return false;
    }
  }

  Future<bool> login({
    required String email,
    required String password,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _authService.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      
      // Check if admin - if so, logout (mobile app is for users only)
      bool isAdmin = await _authService.isAdmin();
      if (isAdmin) {
        await _authService.signOut();
        _errorMessage = 'Admin access is not available on mobile app';
        _isLoading = false;
        notifyListeners();
        return false;
      }
      
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _isLoading = false;
      _errorMessage = _getErrorMessage(e);
      notifyListeners();
      return false;
    }
  }

  Future<void> logout() async {
    await _authService.signOut();
    _user = null;
    notifyListeners();
  }

  String _getErrorMessage(dynamic error) {
    if (error.toString().contains('email-already-in-use')) {
      return 'Email already registered. Please login.';
    } else if (error.toString().contains('invalid-email')) {
      return 'Invalid email address';
    } else if (error.toString().contains('weak-password')) {
      return 'Password is too weak. Please use a stronger password.';
    } else if (error.toString().contains('user-not-found')) {
      return 'User not found. Please register first.';
    } else if (error.toString().contains('wrong-password')) {
      return 'Wrong password. Please try again.';
    } else if (error.toString().contains('network-request-failed')) {
      return 'Network error. Please check your connection.';
    }
    return 'An error occurred. Please try again.';
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}
