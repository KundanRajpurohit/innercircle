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
    super.key,
    required this.event,
    this.distanceInKm,
    this.onTap,
    this.currentUserId,
  });

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
        child: ClipPath(
          clipper: TicketClipper(),
          child: Container(
            color: AppColors.darkPrimary, // yellow ticket color
            padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // CATEGORY + ICON (Movie, Sports etc.)
                Row(
                  children: [
                    Row(
                      children: [
                        Icon(
                          _getCategoryIcon(),
                          size: 28,
                          color: const Color(0xFF87581C), // dark brown icon
                        ),
                        const SizedBox(width: 8),
                        Text(
                          widget.event.category,
                          style: const TextStyle(
                            color: Color(0xFF87581C),
                            fontSize: 20,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                    const Spacer(),
                    // HOST BADGE
                    if (isHost)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          gradient: AppColors.primaryGradient,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.primary.withOpacity(0.3),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: const [
                            Icon(
                              Icons.star_rounded,
                              size: 14,
                              color: Colors.white,
                            ),
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
                  ],
                ),

                const SizedBox(height: 8),

                // TITLE
                Center(
                  child: Text(
                    widget.event.title,
                    style: const TextStyle(
                      color: Color(0xFF87581C),
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),

                const SizedBox(height: 8),

                // DOTTED DIVIDER
                Center(
                  child: Container(
                    height: 1,
                    width: double.infinity,
                    decoration: const BoxDecoration(
                      border: Border(
                        top: BorderSide(
                          color: Color(0xFF87581C),
                          width: 1,
                          style: BorderStyle.solid,
                        ),
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 8),

                // TIME RANGE
                Center(
                  child: Text(
                    "Time :-  ${DateFormat('hh:mm a').format(widget.event.dateTime)} "
                    "to ${DateFormat('hh:mm a').format(widget.event.dateTime.add(const Duration(hours: 3)))}",
                    style: const TextStyle(
                      color: Color(0xFF87581C),
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),

                const SizedBox(height: 2),

                Text(
                  widget.event.description,
                  maxLines: 2,
                  style: const TextStyle(
                    color: Color(0xFF87581C),
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),

                const SizedBox(height: 8),

                // DATE + LOCATION
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "Date :-  ${DateFormat('dd.MM.yyyy').format(widget.event.dateTime)}",
                      style: const TextStyle(
                        color: Color(0xFF87581C),
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Row(
                      children: [
                        const Icon(
                          Icons.location_on,
                          size: 16,
                          color: Color(0xFF87581C),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          "${widget.distanceInKm} Kms away" ?? "Unknown",
                          style: const TextStyle(
                            color: Color(0xFF87581C),
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
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

class TicketClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    const bigR = 18.0;
    const smallR1 = 7.0;
    const smallR2 = 6.0;

    final path = Path();

    // Start at top-left
    path.moveTo(0, 0);

    // Top edge
    path.lineTo(size.width, 0);

    // -----------------------------------
    // RIGHT SIDE PERFORATION (original)
    // -----------------------------------

    path.lineTo(size.width, size.height * 0.10);
    path.arcToPoint(
      Offset(size.width, size.height * 0.18),
      radius: const Radius.circular(smallR1),
      clockwise: false,
    );

    path.lineTo(size.width, size.height * 0.25);
    path.arcToPoint(
      Offset(size.width, size.height * 0.33),
      radius: const Radius.circular(smallR2),
      clockwise: false,
    );

    path.lineTo(size.width, size.height * 0.40);
    path.arcToPoint(
      Offset(size.width, size.height * 0.60),
      radius: const Radius.circular(bigR),
      clockwise: false,
    );

    path.lineTo(size.width, size.height * 0.70);
    path.arcToPoint(
      Offset(size.width, size.height * 0.78),
      radius: const Radius.circular(smallR2),
      clockwise: false,
    );

    path.lineTo(size.width, size.height * 0.83);
    path.arcToPoint(
      Offset(size.width, size.height * 0.92),
      radius: const Radius.circular(smallR1),
      clockwise: false,
    );

    path.lineTo(size.width, size.height);

    // Bottom edge
    path.lineTo(0, size.height);

    // -----------------------------------
    // LEFT SIDE PERFORATION (mirrored)
    // -----------------------------------

    path.lineTo(0, size.height * 0.92);
    path.arcToPoint(
      Offset(0, size.height * 0.83),
      radius: const Radius.circular(smallR1),
      clockwise: false,
    );

    path.lineTo(0, size.height * 0.78);
    path.arcToPoint(
      Offset(0, size.height * 0.70),
      radius: const Radius.circular(smallR2),
      clockwise: false,
    );

    path.lineTo(0, size.height * 0.60);
    path.arcToPoint(
      Offset(0, size.height * 0.40),
      radius: const Radius.circular(bigR),
      clockwise: false,
    );

    path.lineTo(0, size.height * 0.33);
    path.arcToPoint(
      Offset(0, size.height * 0.25),
      radius: const Radius.circular(smallR2),
      clockwise: false,
    );

    path.lineTo(0, size.height * 0.18);
    path.arcToPoint(
      Offset(0, size.height * 0.10),
      radius: const Radius.circular(smallR1),
      clockwise: false,
    );

    path.lineTo(0, 0);

    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => true;
}
