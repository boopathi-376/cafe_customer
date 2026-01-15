import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppColors {
  static const Color primary = Color(0xFF21C065); // Green
  static const Color secondary = Color(0xFF66FFB2); // Light green
  static const Color background = Color(0xFF1A1A1A);
  static const Color surface = Color(0xFF2A2A2A);
  static const Color card = Color(0xFF2E2E2E);
  static const Color textPrimary = Color(0xFFE0E0E0);
  static const Color textSecondary = Colors.grey;
  static const Color white = Colors.white;
  static const Color black = Colors.black;
}
class AppTextStyles {
  static final headline = GoogleFonts.poppins(
    fontSize: 22,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
  );

  static final subhead = GoogleFonts.poppins(
    fontSize: 16,
    fontWeight: FontWeight.w400,
    color: AppColors.textSecondary,
  );

  static final chipText = GoogleFonts.poppins(
    fontSize: 13,
    fontWeight: FontWeight.w500,
  );

  static final priceText = GoogleFonts.poppins(
    fontSize: 16,
    fontWeight: FontWeight.bold,
    color: AppColors.primary,
  );
}