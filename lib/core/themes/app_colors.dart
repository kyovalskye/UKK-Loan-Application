import 'package:flutter/material.dart';

class AppColors {
  // Primary Colors - Modern Purple/Blue Gradient
  static const Color primary = Color(0xFF6C5CE7);
  static const Color primaryDark = Color(0xFF5F3DC4);
  static const Color primaryLight = Color(0xFF9B8AFF);
  
  // Accent Colors
  static const Color accent = Color(0xFF00D9FF);
  static const Color accentDark = Color(0xFF00B8D4);
  
  // Background Colors - Dark Theme
  static const Color background = Color(0xFF0A0E27);
  static const Color surface = Color(0xFF151A35);
  static const Color surfaceLight = Color(0xFF1E2544);
  
  // Card Colors
  static const Color card = Color(0xFF1A1F3A);
  static const Color cardHover = Color(0xFF252B4A);
  
  // Text Colors
  static const Color textPrimary = Color(0xFFFFFFFF);
  static const Color textSecondary = Color(0xFFB4B9D0);
  static const Color textTertiary = Color(0xFF6E7491);
  
  // Status Colors
  static const Color success = Color(0xFF00E676);
  static const Color successDark = Color(0xFF00C853);
  static const Color warning = Color(0xFFFFAB00);
  static const Color warningDark = Color(0xFFFF8F00);
  static const Color error = Color(0xFFFF5252);
  static const Color errorDark = Color(0xFFE53935);
  static const Color info = Color(0xFF00D9FF);
  
  // Border & Divider
  static const Color border = Color(0xFF2A3150);
  static const Color divider = Color(0xFF1E2544);
  
  // Gradient
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [primary, accent],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  
  static const LinearGradient cardGradient = LinearGradient(
    colors: [surface, surfaceLight],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  
  // Shimmer Colors
  static const Color shimmerBase = Color(0xFF1A1F3A);
  static const Color shimmerHighlight = Color(0xFF252B4A);
}