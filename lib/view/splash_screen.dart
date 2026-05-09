import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../components/menu_bottom_nav.dart';
import 'auth_screen/login_screen.dart';
import 'auth_screen/register_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _checkAuth();
  }

  Future<void> _checkAuth() async {
    await Future.delayed(const Duration(seconds: 2));
    if (!mounted) return;

    final user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      // Reload with timeout — never hang on slow network
      try {
        await user.reload().timeout(const Duration(seconds: 5));
      } catch (_) {
        // Use cached state on timeout
      }

      if (!mounted) return;

      final refreshed = FirebaseAuth.instance.currentUser;

      if (refreshed != null && refreshed.emailVerified) {
        // Fully verified — go to main app
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const MainScreen()),
        );
        return;
      }

      if (refreshed != null && !refreshed.emailVerified) {
        // Registered but not yet verified — go back to verification screen
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const RegisterScreen()),
        );
        return;
      }
    }

    // No user — go to login
    if (!mounted) return;
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const LoginScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SizedBox.expand(
        child: Image.asset(
          'assets/images/cafeImage.jpg',
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => Container(
            color: const Color(0xFF1A1A1A),
            child: const Center(
              child: Icon(Icons.coffee, size: 80, color: Color(0xFF21C065)),
            ),
          ),
        ),
      ),
    );
  }
}
