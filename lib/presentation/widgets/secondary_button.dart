// widgets/buttons/secondary_button.dart
import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_dimensions.dart';
import '../../core/theme/app_text_styles.dart';

class SecondaryButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final bool isFullWidth;
  final IconData? icon;
  final double? height;
  final Color? borderColor;
  final Color? textColor;
  final double? fontSize;

  const SecondaryButton({
    Key? key,
    required this.text,
    this.onPressed,
    this.isFullWidth = true,
    this.icon,
    this.height,
    this.borderColor,
    this.textColor,
    this.fontSize,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final effectiveBorderColor = borderColor ?? AppColors.primary;
    final effectiveTextColor = textColor ?? AppColors.primary;

    return SizedBox(
      width: isFullWidth ? double.infinity : null,
      height: height ?? AppDimensions.buttonHeightM,
      child: OutlinedButton(
        onPressed: onPressed,
        style: OutlinedButton.styleFrom(
          foregroundColor: effectiveTextColor,
          side: BorderSide(
            color: onPressed == null ? AppColors.grey400 : effectiveBorderColor,
            width: 2,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppDimensions.radiusM),
          ),
          padding: EdgeInsets.symmetric(
            horizontal: AppDimensions.spacingL,
            vertical: AppDimensions.spacingM,
          ),
          disabledForegroundColor: AppColors.grey400,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (icon != null) ...[
              Icon(
                icon,
                size: fontSize != null ? fontSize! + 2 : AppDimensions.iconS,
                color:
                    onPressed == null ? AppColors.grey400 : effectiveTextColor,
              ),
              SizedBox(width: AppDimensions.spacingS),
            ],
            Text(
              text,
              style: AppTextStyles.button.copyWith(
                color:
                    onPressed == null ? AppColors.grey400 : effectiveTextColor,
                fontSize: fontSize,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
