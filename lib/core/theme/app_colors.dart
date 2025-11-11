// core/theme/app_colors.dart
import 'package:flutter/material.dart';

class AppColors {
  // Prevent instantiation
  AppColors._();

  // 🎨 PRIMARY BRAND COLORS - Vibrant & Modern
  static const Color primary = Color(0xFF6366F1); // Vibrant Indigo
  static const Color primaryLight = Color(0xFF818CF8);
  static const Color primaryDark = Color(0xFF4F46E5);
  static const Color primaryGradientStart = Color(0xFF8B5CF6); // Purple
  static const Color primaryGradientEnd = Color(0xFF6366F1); // Indigo

  // 🔥 ACCENT COLORS - Energetic
  static const Color accent = Color(0xFFEC4899); // Hot Pink
  static const Color accentLight = Color(0xFFF472B6);
  static const Color accentDark = Color(0xFFDB2777);
  static const Color accentGradientStart = Color(0xFFEC4899);
  static const Color accentGradientEnd = Color(0xFFF59E0B); // Amber

  // 🌈 BACKGROUND & SURFACE - Clean & Bright
  static const Color background = Color(
    0xFFFAFAFC,
  ); // Almost white with hint of purple
  static const Color backgroundGradientTop = Color(0xFFF8F9FF);
  static const Color backgroundGradientBottom = Color(0xFFFAFAFC);
  static const Color surface = Colors.white;
  static const Color surfaceElevated = Color(0xFFFFFBFE);

  // 📝 TEXT COLORS - High Contrast
  static const Color textPrimary = Color(0xFF1E1B2E);
  static const Color textSecondary = Color(0xFF64748B);
  static const Color textTertiary = Color(0xFF94A3B8);

  // ✨ STATUS COLORS - Vibrant & Clear
  static const Color success = Color(0xFF10B981); // Emerald
  static const Color successLight = Color(0xFFD1FAE5);
  static const Color warning = Color(0xFFF59E0B); // Amber
  static const Color warningLight = Color(0xFFFEF3C7);
  static const Color error = Color(0xFFEF4444); // Red
  static const Color errorLight = Color(0xFFFEE2E2);
  static const Color info = Color(0xFF06B6D4); // Cyan
  static const Color infoLight = Color(0xFFCFFAFE);

  // 🌙 DARK THEME COLORS
  static const Color darkPrimary = Color(0xFFF9C65C);
  static const Color darkAccent = Color(0xFFF472B6);
  static const Color darkBackground = Color(0xFF1E1E1E); // Slate
  static const Color darkSurface = Color(0xFF1E293B);
  static const Color darkSurfaceElevated = Color(0xFF334155);
  static const Color darkText = Color(0xFFF1F5F9);
  static const Color darkSecondary = Color(0xFF878961);
  static const Color darkTextSecondary = Color(0xFFA06200);

  // 🎯 NEUTRAL GRAYS - Modern
  static const Color grey50 = Color(0xFFF8FAFC);
  static const Color grey100 = Color(0xFFF1F5F9);
  static const Color grey200 = Color(0xFFE2E8F0);
  static const Color grey300 = Color(0xFFCBD5E1);
  static const Color grey400 = Color(0xFF94A3B8);
  static const Color grey500 = Color(0xFF64748B);
  static const Color grey600 = Color(0xFF475569);
  static const Color grey700 = Color(0xFF334155);
  static const Color grey800 = Color(0xFF1E293B);
  static const Color grey900 = Color(0xFF0F172A);

  // 🔲 BORDERS & DIVIDERS
  static const Color borderLight = Color(0xFFE2E8F0);
  static const Color borderMedium = Color(0xFFCBD5E1);
  static const Color divider = Color(0xFFE2E8F0);
  static const Color darkDivider = Color(0xFF334155);

  // 💫 OVERLAY & SHADOW
  static const Color overlay = Color(0x40000000);
  static const Color overlayLight = Color(0x1A000000);
  static const Color shadow = Color(0x1A000000);
  static const Color darkShadow = Color(0x40000000);

  // 🎨 EVENT CATEGORY COLORS - Vibrant & Distinctive
  static const Color movieColor = Color(0xFF8B5CF6); // Purple
  static const Color movieLight = Color(0xFFF3E8FF);

  static const Color sportsColor = Color(0xFF10B981); // Emerald
  static const Color sportsLight = Color(0xFFD1FAE5);

  static const Color foodColor = Color(0xFFEF4444); // Red
  static const Color foodLight = Color(0xFFFEE2E2);

  static const Color studyColor = Color(0xFF3B82F6); // Blue
  static const Color studyLight = Color(0xFFDBEAFE);

  static const Color volunteerColor = Color(0xFFF59E0B); // Amber
  static const Color volunteerLight = Color(0xFFFEF3C7);

  static const Color carpoolColor = Color(0xFF06B6D4); // Cyan
  static const Color carpoolLight = Color(0xFFCFFAFE);

  static const Color shoppingColor = Color(0xFFEC4899); // Pink
  static const Color shoppingLight = Color(0xFFFCE7F3);

  static const Color culturalColor = Color(0xFFA855F7); // Fuchsia
  static const Color culturalLight = Color(0xFFFAE8FF);

  // 💎 UTILITY COLORS
  static const Color transparent = Colors.transparent;
  static const Color white = Colors.white;
  static const Color black = Colors.black;

  // 🌟 GRADIENT DEFINITIONS
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [primaryGradientStart, primaryGradientEnd],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient accentGradient = LinearGradient(
    colors: [accentGradientStart, accentGradientEnd],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient backgroundGradient = LinearGradient(
    colors: [backgroundGradientTop, backgroundGradientBottom],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  // 🎯 CATEGORY GRADIENTS
  static LinearGradient getCategoryGradient(String category) {
    switch (category.toLowerCase()) {
      case 'movies':
      case 'movie':
        return const LinearGradient(
          colors: [Color(0xFF8B5CF6), Color(0xFFA78BFA)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        );
      case 'sports':
        return const LinearGradient(
          colors: [Color(0xFF10B981), Color(0xFF34D399)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        );
      case 'food & dining':
      case 'food':
        return const LinearGradient(
          colors: [Color(0xFFEF4444), Color(0xFFF87171)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        );
      case 'study groups':
      case 'study':
        return const LinearGradient(
          colors: [Color(0xFF3B82F6), Color(0xFF60A5FA)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        );
      case 'volunteering':
      case 'volunteer':
        return const LinearGradient(
          colors: [Color(0xFFF59E0B), Color(0xFFFBBF24)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        );
      case 'carpooling':
      case 'carpool':
        return const LinearGradient(
          colors: [Color(0xFF06B6D4), Color(0xFF22D3EE)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        );
      case 'shopping':
        return const LinearGradient(
          colors: [Color(0xFFEC4899), Color(0xFFF472B6)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        );
      case 'cultural events':
      case 'cultural':
        return const LinearGradient(
          colors: [Color(0xFFA855F7), Color(0xFFC084FC)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        );
      default:
        return primaryGradient;
    }
  }

  // 🎨 Get category colors
  static Color getCategoryColor(String category) {
    switch (category.toLowerCase()) {
      case 'movies':
      case 'movie':
        return movieColor;
      case 'sports':
        return sportsColor;
      case 'food & dining':
      case 'food':
        return foodColor;
      case 'study groups':
      case 'study':
        return studyColor;
      case 'volunteering':
      case 'volunteer':
        return volunteerColor;
      case 'carpooling':
      case 'carpool':
        return carpoolColor;
      case 'shopping':
        return shoppingColor;
      case 'cultural events':
      case 'cultural':
        return culturalColor;
      default:
        return primary;
    }
  }

  static Color getCategoryLightColor(String category) {
    switch (category.toLowerCase()) {
      case 'movies':
      case 'movie':
        return movieLight;
      case 'sports':
        return sportsLight;
      case 'food & dining':
      case 'food':
        return foodLight;
      case 'study groups':
      case 'study':
        return studyLight;
      case 'volunteering':
      case 'volunteer':
        return volunteerLight;
      case 'carpooling':
      case 'carpool':
        return carpoolLight;
      case 'shopping':
        return shoppingLight;
      case 'cultural events':
      case 'cultural':
        return culturalLight;
      default:
        return grey100;
    }
  }
}
