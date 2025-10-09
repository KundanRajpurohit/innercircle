import 'package:flutter/material.dart';

class AppDimensions {
  AppDimensions._();

  // Spacing System (8px grid)
  static const double spacingXS = 4.0;
  static const double spacingS = 8.0;
  static const double spacingM = 16.0;
  static const double spacingL = 24.0;
  static const double spacingXL = 32.0;
  static const double spacingXXL = 48.0;

  // Border Radius
  static const double radiusS = 8.0;
  static const double radiusM = 12.0;
  static const double radiusL = 16.0;
  static const double radiusXL = 24.0;
  static const double radiusCircular = 999.0;

  // Elevation
  static const double elevationNone = 0.0;
  static const double elevationLow = 2.0;
  static const double elevationMedium = 4.0;
  static const double elevationHigh = 8.0;

  // Icon Sizes
  static const double iconXS = 16.0;
  static const double iconS = 20.0;
  static const double iconM = 24.0;
  static const double iconL = 32.0;
  static const double iconXL = 48.0;

  // Card & Container
  static const double cardMaxWidth = 340.0;
  static const double eventImageHeight = 180.0;
  static const double imageAspectRatio = 16 / 9;

  // Screen Padding
  static const double screenPaddingH = 16.0;
  static const double screenPaddingV = 16.0;
  static const EdgeInsets screenPadding = EdgeInsets.symmetric(
    horizontal: screenPaddingH,
    vertical: screenPaddingV,
  );

  // Button Heights
  static const double buttonHeightS = 40.0;
  static const double buttonHeightM = 48.0;
  static const double buttonHeightL = 56.0;

  // Input Field
  static const double inputHeight = 48.0;
}
