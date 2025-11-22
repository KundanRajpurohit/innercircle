// widgets/inputs/custom_text_field.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:innercircle/core/theme/app_colors.dart';
import 'package:innercircle/core/theme/app_dimensions.dart';
import 'package:innercircle/core/theme/app_text_styles.dart';

class CustomTextField extends StatefulWidget {
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
  final Color? fillColor;
  final Color? borderColor;
  final Color? focusedBorderColor;
  final TextStyle? style;
  final TextStyle? labelStyle;
  final TextStyle? hintStyle;
  final EdgeInsets? contentPadding;
  final List<TextInputFormatter>? inputFormatters;
  final bool autofocus;

  const CustomTextField({
    super.key,
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
    this.fillColor,
    this.borderColor,
    this.focusedBorderColor,
    this.style,
    this.labelStyle,
    this.hintStyle,
    this.contentPadding,
    this.inputFormatters,
    this.autofocus = false,
  });

  @override
  State<CustomTextField> createState() => _CustomTextFieldState();
}

class _CustomTextFieldState extends State<CustomTextField>
    with SingleTickerProviderStateMixin {
  late FocusNode _focusNode;
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  bool _isFocused = false;

  @override
  void initState() {
    super.initState();
    _focusNode = widget.focusNode ?? FocusNode();
    _focusNode.addListener(_onFocusChange);

    _animationController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.02).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    if (widget.focusNode == null) {
      _focusNode.dispose();
    }
    _animationController.dispose();
    super.dispose();
  }

  void _onFocusChange() {
    setState(() {
      _isFocused = _focusNode.hasFocus;
      if (_isFocused) {
        _animationController.forward();
      } else {
        _animationController.reverse();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final effectiveFillColor =
        widget.fillColor ??
        (widget.enabled ? AppColors.surface : AppColors.grey100);
    final effectiveBorderColor = widget.borderColor ?? const Color(0xFFE5E7EB);
    final effectiveFocusedBorderColor =
        widget.focusedBorderColor ?? AppColors.darkPrimary;

    return ScaleTransition(
      scale: _scaleAnimation,
      child: TextFormField(
        controller: widget.controller,
        keyboardType: widget.keyboardType,
        obscureText: widget.obscureText,
        validator: widget.validator,
        onChanged: widget.onChanged,
        onSaved: widget.onSaved,
        maxLines: widget.maxLines,
        maxLength: widget.maxLength,
        enabled: widget.enabled,
        textInputAction: widget.textInputAction,
        onEditingComplete: widget.onEditingComplete,
        focusNode: _focusNode,
        inputFormatters: widget.inputFormatters,
        autofocus: widget.autofocus,
        style: widget.style ?? AppTextStyles.bodyMedium,
        decoration: InputDecoration(
          hintText: widget.hintText,
          labelText: widget.labelText,
          
          hintStyle:
              widget.hintStyle ??
              AppTextStyles.body.copyWith(color: AppColors.white),
          labelStyle:
              widget.labelStyle ??
              AppTextStyles.body.copyWith(
                color:
                    _isFocused ? effectiveFocusedBorderColor : AppColors.white,
              ),
          // prefixIcon: widget.prefixIcon,
          suffixIcon: widget.suffixIcon,
          filled: false,
          fillColor: effectiveFillColor,
          enabledBorder: const UnderlineInputBorder(
            borderSide: BorderSide(color: Color(0xffF9C65C), width: 1),
          ),
          focusedBorder: const UnderlineInputBorder(
            borderSide: BorderSide(color: Color(0xffF9C65C), width: 2),
          ),
          // border: OutlineInputBorder(
          //   borderRadius: BorderRadius.circular(AppDimensions.radiusM),
          //   borderSide: BorderSide(color: effectiveBorderColor),
          // ),
          // enabledBorder: OutlineInputBorder(
          //   borderRadius: BorderRadius.circular(AppDimensions.radiusM),
          //   borderSide: BorderSide(color: effectiveBorderColor, width: 1.5),
          // ),
          // focusedBorder: OutlineInputBorder(
          //   borderRadius: BorderRadius.circular(AppDimensions.radiusM),
          //   borderSide: BorderSide(
          //     color: effectiveFocusedBorderColor,
          //     width: 2,
          //   ),
          // ),
          // errorBorder: OutlineInputBorder(
          //   borderRadius: BorderRadius.circular(AppDimensions.radiusM),
          //   borderSide: BorderSide(color: AppColors.error, width: 1.5),
          // ),
          // focusedErrorBorder: OutlineInputBorder(
          //   borderRadius: BorderRadius.circular(AppDimensions.radiusM),
          //   borderSide: BorderSide(color: AppColors.error, width: 2),
          // ),
          // disabledBorder: OutlineInputBorder(
          //   borderRadius: BorderRadius.circular(AppDimensions.radiusM),
          //   borderSide: BorderSide(color: AppColors.grey300, width: 1.5),
          // ),
          contentPadding:
              widget.contentPadding ??
              EdgeInsets.symmetric(
                horizontal: AppDimensions.spacingM,
                // vertical: AppDimensions.spacingM,
              ),
          counterText: widget.maxLength != null ? null : '',
          errorStyle: AppTextStyles.caption.copyWith(color: AppColors.error),
        ),
      ),
    );
  }
}
