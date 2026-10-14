import 'package:flutter/material.dart';

enum AppAccentColor {
  blue,
  green,
  orange,
  purple,
  teal,
}

extension AppAccentColorExtension on AppAccentColor {
  String get nameArabic {
    switch (this) {
      case AppAccentColor.blue:
        return 'أزرق (Blue)';
      case AppAccentColor.green:
        return 'أخضر (Green)';
      case AppAccentColor.orange:
        return 'برتقالي (Orange)';
      case AppAccentColor.purple:
        return 'بنفسجي (Purple)';
      case AppAccentColor.teal:
        return 'تيل (Teal)';
    }
  }

  Color get color {
    switch (this) {
      case AppAccentColor.blue:
        return const Color(0xFF2563EB); // Royal Blue
      case AppAccentColor.green:
        return const Color(0xFF059669); // Emerald Green
      case AppAccentColor.orange:
        return const Color(0xFFEA580C); // Deep Orange
      case AppAccentColor.purple:
        return const Color(0xFF7C3AED); // Violet Purple
      case AppAccentColor.teal:
        return const Color(0xFF0D9488); // Dark Teal
    }
  }

  Color get lightBackground {
    switch (this) {
      case AppAccentColor.blue:
        return const Color(0xFFEFF6FF);
      case AppAccentColor.green:
        return const Color(0xFFECFDF5);
      case AppAccentColor.orange:
        return const Color(0xFFFFF7ED);
      case AppAccentColor.purple:
        return const Color(0xFFF5F3FF);
      case AppAccentColor.teal:
        return const Color(0xFFF0FDFA);
    }
  }
}

class AppColors {
  // Pure White Main Surfaces
  static const Color pureWhite = Color(0xFFFFFFFF);
  static const Color backgroundLight = Color(0xFFF9FAFB);
  static const Color surfaceLight = Color(0xFFFFFFFF);

  // Dark Mode Colors
  static const Color backgroundDark = Color(0xFF111827);
  static const Color surfaceDark = Color(0xFF1F2937);

  // Neutral Greys
  static const Color textDark = Color(0xFF111827);
  static const Color textMuted = Color(0xFF6B7280);
  static const Color textLight = Color(0xFF9CA3AF);
  static const Color borderLight = Color(0xFFE5E7EB);
  static const Color borderDark = Color(0xFF374151);

  // Status & Utility Colors
  static const Color success = Color(0xFF10B981);
  static const Color warning = Color(0xFFF59E0B);
  static const Color error = Color(0xFFEF4444);
  static const Color info = Color(0xFF3B82F6);
}
