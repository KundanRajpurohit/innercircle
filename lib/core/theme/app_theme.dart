import 'package:flutter/material.dart';

class TogetherTheme {
  // 🎨 Color Palette
  static const Color primary = Color(0xFF6C63FF);
  static const Color accent = Color(0xFFFF6B6B);
  static const Color background = Color(0xFFF9FAFB);
  static const Color surface = Colors.white;
  static const Color textPrimary = Color(0xFF1E1E1E);
  static const Color textSecondary = Color(0xFF6B7280);
  static const Color success = Color(0xFF4ADE80);
  static const Color warning = Color(0xFFFBBF24);

  // 🌙 Dark Mode Palette
  static const Color darkPrimary = Color(0xFF8B80FF);
  static const Color darkBackground = Color(0xFF18181B);
  static const Color darkSurface = Color(0xFF27272A);
  static const Color darkText = Color(0xFFF9FAFB);
  static const Color darkAccent = Color(0xFFFF7D7D);

  // 🧱 Spacing System
  static const double spacingXS = 4.0;
  static const double spacingS = 8.0;
  static const double spacingM = 16.0;
  static const double spacingL = 24.0;
  static const double spacingXL = 32.0;

  // 🔤 Typography
  static const String fontPrimary = 'Poppins';
  static const String fontSecondary = 'Inter';

  // 📱 Light Theme
  static ThemeData lightTheme = ThemeData(
    brightness: Brightness.light,
    scaffoldBackgroundColor: background,
    primaryColor: primary,
    colorScheme: const ColorScheme.light(
      primary: primary,
      secondary: accent,
      surface: surface,
    ),
    textTheme: const TextTheme(
      headlineSmall: TextStyle(
        fontFamily: fontPrimary,
        fontWeight: FontWeight.w600,
        fontSize: 24,
        color: textPrimary,
      ),
      titleMedium: TextStyle(
        fontFamily: fontPrimary,
        fontWeight: FontWeight.w500,
        fontSize: 18,
        color: textPrimary,
      ),
      bodyMedium: TextStyle(
        fontFamily: fontSecondary,
        fontSize: 14,
        fontWeight: FontWeight.w400,
        color: textSecondary,
      ),
      labelSmall: TextStyle(
        fontFamily: fontSecondary,
        fontSize: 12,
        color: textSecondary,
      ),
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: background,
      elevation: 0,
      iconTheme: IconThemeData(color: textPrimary),
      titleTextStyle: TextStyle(
        fontFamily: fontPrimary,
        fontWeight: FontWeight.w600,
        fontSize: 20,
        color: textPrimary,
      ),
    ),
    cardTheme: CardTheme(
      color: surface,
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: primary,
        foregroundColor: Colors.white,
        elevation: 0,
        padding: const EdgeInsets.symmetric(
          horizontal: spacingL,
          vertical: spacingM,
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        textStyle: const TextStyle(
          fontFamily: fontPrimary,
          fontWeight: FontWeight.w600,
          fontSize: 16,
        ),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: surface,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: primary, width: 2),
      ),
      contentPadding: const EdgeInsets.symmetric(
        horizontal: spacingM,
        vertical: spacingM,
      ),
    ),
  );

  // 🌙 Dark Theme
  // 🌙 New Dark Theme (Matching Your UI)
  static ThemeData darkTheme = ThemeData(
    brightness: Brightness.dark,
    useMaterial3: true,

    // Main background
    scaffoldBackgroundColor: const Color(0xFF2E2C3E),

    colorScheme: const ColorScheme.dark(
      primary: Color(0xFFE7C875), // golden yellow
      secondary: Color(0xFFD8898A), // soft pink
      surface: Color(0xFF3B394C),
      onPrimary: Colors.black,
      onSurface: Colors.white,
    ),

    // ✅ Text Colors
    textTheme: const TextTheme(
      headlineSmall: TextStyle(
        fontFamily: fontPrimary,
        fontWeight: FontWeight.w600,
        fontSize: 24,
        color: Colors.white,
      ),
      titleMedium: TextStyle(
        fontFamily: fontPrimary,
        fontWeight: FontWeight.w500,
        fontSize: 18,
        color: Colors.white,
      ),
      bodyMedium: TextStyle(
        fontFamily: fontSecondary,
        fontSize: 14,
        fontWeight: FontWeight.w400,
        color: Color(0xFFB6B6C4), // light grey-purple
      ),
      labelSmall: TextStyle(
        fontFamily: fontSecondary,
        fontSize: 12,
        color: Color(0xFFB6B6C4),
      ),
    ),

    // ✅ AppBar
    appBarTheme: const AppBarTheme(
      backgroundColor: Color(0xFF2E2C3E),
      elevation: 0,
      iconTheme: IconThemeData(color: Colors.white),
      titleTextStyle: TextStyle(
        fontFamily: fontPrimary,
        fontWeight: FontWeight.w600,
        fontSize: 20,
        color: Colors.white,
      ),
    ),

    // ✅ Cards
    cardTheme: CardTheme(
      color: const Color(0xFF3B394C),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    ),

    // ✅ Buttons (Golden Yellow)
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFFE7C875),
        foregroundColor: Colors.black,
        padding: const EdgeInsets.symmetric(
          horizontal: spacingL,
          vertical: spacingM,
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        textStyle: const TextStyle(
          fontFamily: fontPrimary,
          fontWeight: FontWeight.w600,
          fontSize: 16,
        ),
      ),
    ),

    // ✅ Inputs (Pink outline + soft surface)
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: const Color(0xFF3B394C),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFFD8898A)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFFD8898A)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFFE7C875), width: 2),
      ),
      contentPadding: const EdgeInsets.symmetric(
        horizontal: spacingM,
        vertical: spacingM,
      ),
    ),
  );
}
