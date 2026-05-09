import 'package:firebase_auth/firebase_auth.dart';

class AppException implements Exception {
  final String message;
  const AppException(this.message);

  @override
  String toString() => message;

  factory AppException.fromFirebaseAuth(FirebaseAuthException e) {
    return switch (e.code) {
      'user-not-found' ||
      'wrong-password' ||
      'invalid-credential' ||
      'invalid-email' =>
        const AppException('Invalid email or password.'),
      'email-already-in-use' =>
        const AppException('An account already exists for that email.'),
      'weak-password' =>
        const AppException('Password must be at least 6 characters.'),
      'network-request-failed' =>
        const AppException('Check your internet connection.'),
      'too-many-requests' =>
        const AppException('Too many attempts. Try again later.'),
      _ => AppException('Authentication failed. Please try again.'),
    };
  }
}
