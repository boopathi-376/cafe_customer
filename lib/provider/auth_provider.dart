import 'dart:async';
import 'package:flutter/material.dart';
import '../models/user.dart';
import '../service/auth_service.dart';
import '../core/error/app_exception.dart';

class AuthenticationProvider with ChangeNotifier {
  final AuthenticationService _authService = AuthenticationService();

  UserModel? _user;
  bool _isLoading = false;
  String? _error;
  StreamSubscription<UserModel?>? _authSubscription;

  AuthenticationProvider() {
    _listenToAuthState();
  }

  UserModel? get user => _user;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isAuthenticated => _user != null;

  void _listenToAuthState() {
    _authSubscription = _authService.userStream.listen((userData) {
      _user = userData;
      notifyListeners();
    });
  }

  Future<bool> signIn(String email, String password) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      _user = await _authService.signIn(email, password);
      return true;
    } on AppException catch (e) {
      _error = e.message;
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> register(
      String email, String password, String name) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      _user = await _authService.register(email, password, name);
      return true;
    } on AppException catch (e) {
      _error = e.message;
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> resendEmailVerification() async {
    try {
      await _authService.sendEmailVerification();
    } on AppException catch (e) {
      _error = e.message;
      notifyListeners();
    }
  }

  Future<bool> isEmailVerified() => _authService.isEmailVerified();

  Future<void> resetPassword(String email) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      await _authService.resetPassword(email);
    } on AppException catch (e) {
      _error = e.message;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> signOut() async {
    await _authService.signOut();
    _user = null;
    notifyListeners();
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }

  @override
  void dispose() {
    _authSubscription?.cancel();
    super.dispose();
  }
}
