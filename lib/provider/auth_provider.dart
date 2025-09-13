import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/user.dart';
import '../service/auth_service.dart';

class AuthenticationProvider with ChangeNotifier {
  final AuthenticationService _authService = AuthenticationService();
  UserModel? _user;
  bool _isLoading = false;
  String? _error;

  AuthenticationProvider() {
    _initializeUser();
  }

  UserModel? get user => _user;
  Stream<UserModel?> get userStream => _authService.user;
  bool get isLoading => _isLoading;
  String? get error => _error;

  void _initializeUser() {
    _authService.user.listen((userData) {
      _user = userData;
      notifyListeners();
    });
  }

  void setError(String? message) {
    _error = message;
    notifyListeners();
  }

  Future<bool> signIn(String email, String password) async {
    _isLoading = true;
    notifyListeners();

    try {
      _user = await _authService.signIn(email, password);
      _error = null;

      final firebaseUser = FirebaseAuth.instance.currentUser;
      if (firebaseUser != null && !firebaseUser.emailVerified) {
        _error = "Please verify your email address.";
        await FirebaseAuth.instance.signOut();
        _user = null;
        return false;
      }

      return true;
    } catch (e) {
      _error = e.toString();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> register(String email, String password, String name) async {
    _isLoading = true;
    notifyListeners();

    try {
      _user = await _authService.register(email, password, name);
      _error = null;

      await FirebaseAuth.instance.currentUser?.updateDisplayName(name);

      await FirebaseAuth.instance.currentUser?.sendEmailVerification(
        ActionCodeSettings(
          url: 'https://yourproject.page.link/emailVerify',
          handleCodeInApp: true,
          androidPackageName: 'com.example.cafe',
          androidInstallApp: true,
          androidMinimumVersion: '1',
        ),
      );

      return true;
    } catch (e) {
      _error = e.toString();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> resendEmailVerification() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null && !user.emailVerified) {
        await user.sendEmailVerification(
          ActionCodeSettings(
            url: 'https://yourproject.page.link/emailVerify',
            handleCodeInApp: true,
            androidPackageName: 'com.example.cafe',
            androidInstallApp: true,
            androidMinimumVersion: '1',
          ),
        );
      }
    } catch (e) {
      _error = "Failed to resend email verification.";
      notifyListeners();
    }
  }

  Future<bool> isEmailVerified() async {
    final user = FirebaseAuth.instance.currentUser;
    await user?.reload();
    return user?.emailVerified ?? false;
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

  Future<User?> reloadAndCheckVerified() async {
    final user = FirebaseAuth.instance.currentUser;
    await user?.reload();
    return FirebaseAuth.instance.currentUser;
  }

  Future<void> sendEmailVerification() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null && !user.emailVerified) {
        await user.sendEmailVerification(
          ActionCodeSettings(
            url: 'https://yourproject.page.link/emailVerify',
            handleCodeInApp: true,
            androidPackageName: 'com.example.cafe',
            androidInstallApp: true,
            androidMinimumVersion: '1',
          ),
        );
      }
    } catch (e) {
      _error = "Failed to send verification email.";
      notifyListeners();
    }
  }

  Future<void> saveUserToFirestore(User user) async {
    final firestore = FirebaseFirestore.instance;

    await firestore.collection("customeruser").doc(user.uid).set({
      'uid': user.uid,
      'email': user.email,
      'name': user.displayName ?? '',
      'createdAt': Timestamp.now(),
    });
  }
}
