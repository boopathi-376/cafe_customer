import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../components/menu_bottom_nav.dart';
import 'auth_screen/login_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _checkUserLoggedIn();
  }

  Future<void> _checkUserLoggedIn() async {
    await Future.delayed(const Duration(seconds: 2)); // Show splash briefly

    final user = FirebaseAuth.instance.currentUser;

    if (!mounted) return;

    if (user != null) {
      await user.reload(); // Ensure we have latest emailVerified status
      if (!mounted) return;
      if (user.emailVerified) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => MainScreen()),
        );
        return;
      }
    }

    if (!mounted) return;

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => LoginScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SizedBox.expand(
        child: Image.asset(
          "lib/assets/images/cafeImage.jpg",
          fit: BoxFit.cover,
        ),
      ),
    );
  }
}
