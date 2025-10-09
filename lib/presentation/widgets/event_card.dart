// widgets/event_card.dart
import 'package:flutter/material.dart';
import 'package:innercircle/core/theme/app_colors.dart';
import 'package:innercircle/core/theme/app_dimensions.dart';
import 'package:innercircle/core/theme/app_text_styles.dart';
import 'package:innercircle/data/models/event.dart';
import 'package:intl/intl.dart';
import 'dart:ui';

class EventCard extends StatefulWidget {
  final Event event;
  final double? distanceInKm;
  final VoidCallback? onTap;
  final String? currentUserId;

  const EventCard({
    Key? key,
    required this.event,
    this.distanceInKm,
    this.onTap,
    this.currentUserId,
  }) : super(key: key);

  @override
  State<EventCard> createState() => _EventCardState();
}

class _EventCardState extends State<EventCard>
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
    final isHost =
        widget.currentUserId != null &&
        widget.event.hostId == widget.currentUserId;
    final hasJoined =
        widget.currentUserId != null &&
        widget.event.joinedUsers.contains(widget.currentUserId);

    return ScaleTransition(
      scale: _scaleAnimation,
      child: GestureDetector(
        onTapDown: (_) {
          setState(() => _isPressed = true);
          _controller.forward();
        },
        onTapUp: (_) {
          setState(() => _isPressed = false);
          _controller.reverse();
          widget.onTap?.call();
        },
        onTapCancel: () {
          setState(() => _isPressed = false);
          _controller.reverse();
        },
        child: Container(
          margin: EdgeInsets.symmetric(
            horizontal: AppDimensions.spacingM,
            vertical: AppDimensions.spacingS,
          ),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: _getCategoryColor().withOpacity(0.2),
                blurRadius: 20,
                spreadRadius: 0,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(24),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Gradient Header with Category
                  _buildGradientHeader(isHost, hasJoined),

                  // Content Section
                  Padding(
                    padding: EdgeInsets.all(AppDimensions.spacingL),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Title with badges
                        _buildTitle(isHost, hasJoined),
                        SizedBox(height: AppDimensions.spacingM),

                        // Description
                        Text(
                          widget.event.description,
                          style: AppTextStyles.body.copyWith(
                            height: 1.5,
                            color: AppColors.textSecondary,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        SizedBox(height: AppDimensions.spacingL),

                        // Info chips
                        _buildInfoSection(),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildGradientHeader(bool isHost, bool hasJoined) {
    return Container(
      height: 140,
      decoration: BoxDecoration(
        gradient: AppColors.getCategoryGradient(widget.event.category),
      ),
      child: Stack(
        children: [
          // Decorative circles
          Positioned(
            top: -30,
            right: -30,
            child: Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withOpacity(0.1),
              ),
            ),
          ),
          Positioned(
            bottom: -20,
            left: -20,
            child: Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withOpacity(0.1),
              ),
            ),
          ),

          // Content
          Padding(
            padding: EdgeInsets.all(AppDimensions.spacingL),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Category badge
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: AppDimensions.spacingM,
                    vertical: AppDimensions.spacingS,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.25),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: Colors.white.withOpacity(0.5),
                      width: 1.5,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(_getCategoryIcon(), size: 16, color: Colors.white),
                      SizedBox(width: 6),
                      Text(
                        widget.event.category,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),

                // Participants count
                Row(
                  children: [
                    Container(
                      padding: EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.25),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.people_rounded,
                        size: 20,
                        color: Colors.white,
                      ),
                    ),
                    SizedBox(width: 8),
                    Text(
                      '${widget.event.joinedUsers.length} ${widget.event.joinedUsers.length == 1 ? "person" : "people"} joined',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTitle(bool isHost, bool hasJoined) {
    return Row(
      children: [
        Expanded(
          child: Text(
            widget.event.title,
            style: AppTextStyles.subheading.copyWith(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        if (isHost)
          Container(
            padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              gradient: AppColors.primaryGradient,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withOpacity(0.3),
                  blurRadius: 8,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.star_rounded, size: 14, color: Colors.white),
                SizedBox(width: 4),
                Text(
                  'Host',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        if (hasJoined && !isHost)
          Container(
            padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: AppColors.successLight,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.success, width: 1.5),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.check_circle_rounded,
                  size: 14,
                  color: AppColors.success,
                ),
                SizedBox(width: 4),
                Text(
                  'Joined',
                  style: TextStyle(
                    color: AppColors.success,
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }

  Widget _buildInfoSection() {
    return Row(
      children: [
        // Date & Time
        Expanded(
          child: _buildInfoChip(
            icon: Icons.access_time_rounded,
            text: _formatDateTime(widget.event.dateTime),
            color: AppColors.primary,
            gradient: LinearGradient(
              colors: [
                AppColors.primary.withOpacity(0.1),
                AppColors.primary.withOpacity(0.05),
              ],
            ),
          ),
        ),
        if (widget.distanceInKm != null) ...[
          SizedBox(width: 8),
          _buildInfoChip(
            icon: Icons.location_on_rounded,
            text: _formatDistance(widget.distanceInKm!),
            color: AppColors.accent,
            gradient: LinearGradient(
              colors: [
                AppColors.accent.withOpacity(0.1),
                AppColors.accent.withOpacity(0.05),
              ],
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildInfoChip({
    required IconData icon,
    required String text,
    required Color color,
    Gradient? gradient,
  }) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        gradient: gradient,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3), width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: color),
          SizedBox(width: 6),
          Flexible(
            child: Text(
              text,
              style: TextStyle(
                color: color,
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Color _getCategoryColor() {
    return AppColors.getCategoryColor(widget.event.category);
  }

  IconData _getCategoryIcon() {
    switch (widget.event.category.toLowerCase()) {
      case 'movies':
      case 'movie':
        return Icons.movie_rounded;
      case 'sports':
        return Icons.sports_basketball_rounded;
      case 'food & dining':
      case 'food':
        return Icons.restaurant_rounded;
      case 'study groups':
      case 'study':
        return Icons.school_rounded;
      case 'volunteering':
      case 'volunteer':
        return Icons.volunteer_activism_rounded;
      case 'carpooling':
      case 'carpool':
        return Icons.directions_car_rounded;
      case 'shopping':
        return Icons.shopping_bag_rounded;
      case 'cultural events':
      case 'cultural':
        return Icons.celebration_rounded;
      default:
        return Icons.event_rounded;
    }
  }

  String _formatDistance(double km) {
    if (km < 1) {
      return '${(km * 1000).round()}m away';
    } else if (km < 10) {
      return '${km.toStringAsFixed(1)}km away';
    } else {
      return '${km.round()}km away';
    }
  }

  String _formatDateTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = dateTime.difference(now);

    if (dateTime.day == now.day &&
        dateTime.month == now.month &&
        dateTime.year == now.year) {
      return 'Today, ${DateFormat('h:mm a').format(dateTime)}';
    }

    final tomorrow = now.add(const Duration(days: 1));
    if (dateTime.day == tomorrow.day &&
        dateTime.month == tomorrow.month &&
        dateTime.year == tomorrow.year) {
      return 'Tomorrow, ${DateFormat('h:mm a').format(dateTime)}';
    }

    if (difference.inDays < 7 && difference.inDays >= 0) {
      return DateFormat('EEE, h:mm a').format(dateTime);
    }

    return DateFormat('MMM d, h:mm a').format(dateTime);
  }
}
