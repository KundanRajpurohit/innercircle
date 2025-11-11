import 'package:flutter/material.dart';
import 'app_colors.dart';

class AppTextStyles {
  AppTextStyles._();

  static const String fontPrimary = 'Poppins';
  static const String fontSecondary = 'Inter';

  // Headline (Page Titles)
  static const TextStyle headline = TextStyle(
    fontFamily: fontPrimary,
    fontSize: 24,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
    height: 1.3,
  );

  static const TextStyle headlineDark = TextStyle(
    fontFamily: fontPrimary,
    fontSize: 24,
    fontWeight: FontWeight.w600,
    color: AppColors.darkText,
    height: 1.3,
  );

  // Subheading (Section Titles)
  static const TextStyle subheading = TextStyle(
    fontFamily: fontPrimary,
    fontSize: 18,
    fontWeight: FontWeight.w500,
    color: AppColors.textPrimary,
    height: 1.4,
  );

  static const TextStyle subheadingDark = TextStyle(
    fontFamily: fontPrimary,
    fontSize: 18,
    fontWeight: FontWeight.w500,
    color: AppColors.darkText,
    height: 1.4,
  );

  // Body (Descriptions)
  static const TextStyle body = TextStyle(
    fontFamily: fontSecondary,
    fontSize: 14,
    fontWeight: FontWeight.w400,
    color: AppColors.textSecondary,
    height: 1.5,
  );

  static const TextStyle bodyDark = TextStyle(
    fontFamily: fontSecondary,
    fontSize: 14,
    fontWeight: FontWeight.w400,
    color: AppColors.darkText,
    height: 1.5,
  );

  static const TextStyle bodyMedium = TextStyle(
    fontFamily: fontSecondary,
    fontSize: 14,
    fontWeight: FontWeight.w500,
    color: AppColors.textPrimary,
    height: 1.5,
  );

  // Caption (Hints, Timestamps)
  static const TextStyle caption = TextStyle(
    fontFamily: fontSecondary,
    fontSize: 12,
    fontWeight: FontWeight.w400,
    color: AppColors.textSecondary,
    height: 1.4,
  );

  static const TextStyle captionDark = TextStyle(
    fontFamily: fontSecondary,
    fontSize: 12,
    fontWeight: FontWeight.w400,
    color: AppColors.darkText,
    height: 1.4,
  );

  // Button Text
  static const TextStyle button = TextStyle(
    fontFamily: fontPrimary,
    fontSize: 16,
    fontWeight: FontWeight.w600,
    height: 1.2,
  );

  // Card Title
  static const TextStyle cardTitle = TextStyle(
    fontFamily: fontPrimary,
    fontSize: 16,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
    height: 1.3,
  );
}
