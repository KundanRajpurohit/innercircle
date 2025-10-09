import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_dimensions.dart';
import '../../core/theme/app_text_styles.dart';

class PrimaryButton extends StatefulWidget {
  final String text;
  final VoidCallback? onPressed;
  final bool isLoading;
  final bool isFullWidth;
  final double? height;
  final IconData? icon;
  final Color? backgroundColor;
  final Color? textColor;
  final Gradient? gradient;

  const PrimaryButton({
    Key? key,
    required this.text,
    this.onPressed,
    this.isLoading = false,
    this.isFullWidth = true,
    this.height,
    this.icon,
    this.backgroundColor,
    this.textColor,
    this.gradient,
  }) : super(key: key);

  @override
  State<PrimaryButton> createState() => _PrimaryButtonState();
}

class _PrimaryButtonState extends State<PrimaryButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  bool _isPressed = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.95,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDisabled = widget.onPressed == null || widget.isLoading;
    final effectiveGradient = widget.gradient ?? AppColors.primaryGradient;

    return ScaleTransition(
      scale: _scaleAnimation,
      child: GestureDetector(
        onTapDown:
            isDisabled
                ? null
                : (_) {
                  setState(() => _isPressed = true);
                  _controller.forward();
                },
        onTapUp:
            isDisabled
                ? null
                : (_) {
                  setState(() => _isPressed = false);
                  _controller.reverse();
                  widget.onPressed?.call();
                },
        onTapCancel: () {
          setState(() => _isPressed = false);
          _controller.reverse();
        },
        child: Container(
          width: widget.isFullWidth ? double.infinity : null,
          height: widget.height ?? AppDimensions.buttonHeightM,
          decoration: BoxDecoration(
            gradient: isDisabled ? null : effectiveGradient,
            color: isDisabled ? AppColors.grey300 : widget.backgroundColor,
            borderRadius: BorderRadius.circular(AppDimensions.radiusM),
            boxShadow:
                isDisabled
                    ? null
                    : [
                      BoxShadow(
                        color: (widget.backgroundColor ?? AppColors.primary)
                            .withOpacity(0.4),
                        blurRadius: 20,
                        spreadRadius: 0,
                        offset: const Offset(0, 8),
                      ),
                    ],
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: isDisabled ? null : widget.onPressed,
              borderRadius: BorderRadius.circular(AppDimensions.radiusM),
              child: Container(
                padding: EdgeInsets.symmetric(
                  horizontal: AppDimensions.spacingL,
                  vertical: AppDimensions.spacingM,
                ),
                child:
                    widget.isLoading
                        ? Center(
                          child: SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2.5,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                widget.textColor ?? Colors.white,
                              ),
                            ),
                          ),
                        )
                        : Row(
                          mainAxisSize: MainAxisSize.min,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            if (widget.icon != null) ...[
                              Icon(
                                widget.icon,
                                size: AppDimensions.iconS,
                                color:
                                    isDisabled
                                        ? AppColors.grey500
                                        : (widget.textColor ?? Colors.white),
                              ),
                              SizedBox(width: AppDimensions.spacingS),
                            ],
                            Text(
                              widget.text,
                              style: AppTextStyles.button.copyWith(
                                color:
                                    isDisabled
                                        ? AppColors.grey500
                                        : (widget.textColor ?? Colors.white),
                                fontWeight: FontWeight.w700,
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
