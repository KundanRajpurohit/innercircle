// widgets/chips/interest_chip.dart
import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_dimensions.dart';
import '../../core/theme/app_text_styles.dart';

class InterestChip extends StatefulWidget {
  final String label;
  final bool isSelected;
  final VoidCallback? onTap;
  final Color? selectedColor;
  final Color? unselectedColor;
  final String? emoji;
  final bool showCheckmark;

  const InterestChip({
    Key? key,
    required this.label,
    this.isSelected = false,
    this.onTap,
    this.selectedColor,
    this.unselectedColor,
    this.emoji,
    this.showCheckmark = true,
  }) : super(key: key);

  @override
  State<InterestChip> createState() => _InterestChipState();
}

class _InterestChipState extends State<InterestChip>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  bool _isPressed = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.92,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  String _getEmojiForLabel(String label) {
    // Return emoji based on label
    final emojiMap = {
      'Movies': '🎬',
      'Sports': '⚽',
      'Food & Dining': '🍕',
      'Study Groups': '📚',
      'Volunteering': '❤️',
      'Carpooling': '🚗',
      'Shopping': '🛍️',
      'Cultural Events': '🎉',
      'Music': '🎵',
      'Art & Crafts': '🎨',
      'Gaming': '🎮',
      'Fitness': '💪',
      'Travel': '✈️',
      'Photography': '📸',
      'Reading': '📖',
      'Cooking': '👨‍🍳',
    };
    return emojiMap[label] ?? '⭐';
  }

  @override
  Widget build(BuildContext context) {
    final effectiveSelectedColor = widget.selectedColor ?? AppColors.primary;
    final effectiveUnselectedColor =
        widget.unselectedColor ?? AppColors.grey100;
    final emoji = widget.emoji ?? _getEmojiForLabel(widget.label);

    return ScaleTransition(
      scale: _scaleAnimation,
      child: GestureDetector(
        onTapDown:
            widget.onTap == null
                ? null
                : (_) {
                  setState(() => _isPressed = true);
                  _controller.forward();
                },
        onTapUp:
            widget.onTap == null
                ? null
                : (_) {
                  setState(() => _isPressed = false);
                  _controller.reverse();
                  widget.onTap?.call();
                },
        onTapCancel: () {
          setState(() => _isPressed = false);
          _controller.reverse();
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
          padding: EdgeInsets.symmetric(
            horizontal: AppDimensions.spacingM + 2,
            vertical: AppDimensions.spacingS + 2,
          ),
          decoration: BoxDecoration(
            gradient:
                widget.isSelected
                    ? LinearGradient(
                      colors: [
                        effectiveSelectedColor,
                        effectiveSelectedColor.withOpacity(0.8),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    )
                    : null,
            color: widget.isSelected ? null : effectiveUnselectedColor,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color:
                  widget.isSelected
                      ? Colors.transparent
                      : AppColors.borderLight,
              width: 1.5,
            ),
            boxShadow:
                widget.isSelected
                    ? [
                      BoxShadow(
                        color: effectiveSelectedColor.withOpacity(0.3),
                        blurRadius: 12,
                        spreadRadius: 0,
                        offset: const Offset(0, 4),
                      ),
                    ]
                    : null,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Emoji
              Text(emoji, style: TextStyle(fontSize: 16)),
              SizedBox(width: 6),

              // Label
              Text(
                widget.label,
                style: AppTextStyles.body.copyWith(
                  color:
                      widget.isSelected ? Colors.white : AppColors.textPrimary,
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
              ),

              // Checkmark
              if (widget.isSelected && widget.showCheckmark) ...[
                SizedBox(width: 6),
                AnimatedScale(
                  scale: widget.isSelected ? 1.0 : 0.0,
                  duration: const Duration(milliseconds: 200),
                  curve: Curves.elasticOut,
                  child: Icon(
                    Icons.check_circle_rounded,
                    size: 16,
                    color: Colors.white,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
