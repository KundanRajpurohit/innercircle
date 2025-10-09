// widgets/inputs/custom_text_field.dart
import 'package:flutter/material.dart';
import 'package:innercircle/core/theme/app_colors.dart';
import 'package:innercircle/core/theme/app_dimensions.dart';
import 'package:innercircle/core/theme/app_text_styles.dart';

class CustomTextField extends StatelessWidget {
  final String? hintText;
  final String? labelText;
  final TextEditingController? controller;
  final TextInputType? keyboardType;
  final bool obscureText;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final String? Function(String?)? validator;
  final void Function(String)? onChanged;
  final void Function(String?)? onSaved;
  final int maxLines;
  final int? maxLength;
  final bool enabled;
  final TextInputAction? textInputAction;
  final void Function()? onEditingComplete;
  final FocusNode? focusNode;

  const CustomTextField({
    Key? key,
    this.hintText,
    this.labelText,
    this.controller,
    this.keyboardType,
    this.obscureText = false,
    this.prefixIcon,
    this.suffixIcon,
    this.validator,
    this.onChanged,
    this.onSaved,
    this.maxLines = 1,
    this.maxLength,
    this.enabled = true,
    this.textInputAction,
    this.onEditingComplete,
    this.focusNode,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      obscureText: obscureText,
      validator: validator,
      onChanged: onChanged,
      onSaved: onSaved,
      maxLines: maxLines,
      maxLength: maxLength,
      enabled: enabled,
      textInputAction: textInputAction,
      onEditingComplete: onEditingComplete,
      focusNode: focusNode,
      style: AppTextStyles.bodyMedium,
      decoration: InputDecoration(
        hintText: hintText,
        labelText: labelText,
        hintStyle: AppTextStyles.body.copyWith(color: AppColors.textSecondary),
        labelStyle: AppTextStyles.body.copyWith(color: AppColors.textSecondary),
        prefixIcon: prefixIcon,
        suffixIcon: suffixIcon,
        filled: true,
        fillColor: enabled ? AppColors.surface : AppColors.grey100,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppDimensions.radiusM),
          borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppDimensions.radiusM),
          borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppDimensions.radiusM),
          borderSide: const BorderSide(color: AppColors.primary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppDimensions.radiusM),
          borderSide: const BorderSide(color: AppColors.error),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppDimensions.radiusM),
          borderSide: const BorderSide(color: AppColors.error, width: 2),
        ),
        disabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppDimensions.radiusM),
          borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
        ),
        contentPadding: EdgeInsets.symmetric(
          horizontal: AppDimensions.spacingM,
          vertical: AppDimensions.spacingM,
        ),
        counterText: maxLength != null ? null : '',
      ),
    );
  }
}
