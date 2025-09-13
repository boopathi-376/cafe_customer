import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

class LoginAnimationHeader extends StatelessWidget {
  const LoginAnimationHeader({super.key});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return SizedBox(
      width: screenWidth * 0.9, 
      height: screenWidth * 0.5,
      child: Lottie.asset(
        'lib/assets/animation/login.json',
        fit: BoxFit.contain,
      ),
    );
  }
}
