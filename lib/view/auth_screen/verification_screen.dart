import 'package:flutter/material.dart';

class VerifiedScreen extends StatelessWidget {
  const VerifiedScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Text(
          'Email Verified Successfully!',
          style: TextStyle(fontSize: 24),
        ),
      ),
    );
  }
}
