import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:innercircle/data/models/event.dart';
import 'package:innercircle/core/theme/app_colors.dart';

class FullEventCard extends StatelessWidget {
  final Event event;
  final String? currentUserId;
  final double? distanceInKm;
  final VoidCallback? onTap;

  const FullEventCard({
    super.key,
    required this.event,
    this.currentUserId,
    this.distanceInKm,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isHost = currentUserId == event.hostId;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: const Color(0xFFF9C65C), // Yellow Header Color
          borderRadius: BorderRadius.circular(28),
          border: Border.all(color: const Color(0xFFF9C65C), width: 2),
        ),
        child: Column(
          children: [
            // ---------------------------------------------
            // HEADER SECTION (Yellow with rounded top)
            // ---------------------------------------------
            Container(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildCategory(),
                  const SizedBox(height: 14),
                  _buildPeopleJoined(),
                ],
              ),
            ),

            // SEPARATOR BORDER
            Container(
              height: 2,
              width: double.infinity,
              color: const Color(0xFF87581C),
            ),

            // ---------------------------------------------
            // BODY SECTION (Dark background with content)
            // ---------------------------------------------
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: const BoxDecoration(
                color: Color(0xFF2F3041),
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(28),
                  bottomRight: Radius.circular(28),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title + Host Badge
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          event.title,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 28,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),

                      if (isHost) _buildHostBadge(),
                    ],
                  ),
                  const SizedBox(height: 12),

                  Text(
                    event.description,
                    style: const TextStyle(color: Colors.white70, fontSize: 18),
                  ),

                  const SizedBox(height: 20),
                  _buildDateChip(event.dateTime),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // --------------------------------------------------------
  // CATEGORY TAG
  // --------------------------------------------------------
  Widget _buildCategory() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        border: Border.all(color: const Color(0xFF87581C), width: 1.5),
        borderRadius: BorderRadius.circular(22),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(_getCategoryIcon(), color: const Color(0xFF87581C)),
          const SizedBox(width: 8),
          Text(
            event.category,
            style: const TextStyle(
              color: Color(0xFF87581C),
              fontSize: 18,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }

  // --------------------------------------------------------
  // PEOPLE JOINED
  // --------------------------------------------------------
  Widget _buildPeopleJoined() {
    return Row(
      children: [
        CircleAvatar(
          backgroundColor: AppColors.white.withOpacity(0.4),
          radius: 18,
          child: Icon(
            Icons.group,
            color: AppColors.darkTextSecondary,
            size: 24,
          ),
        ),
        const SizedBox(width: 10),

        Text(
          "${event.joinedUsers.length} person joined",
          style: const TextStyle(
            color: Color(0xFF87581C),
            fontSize: 16,
            fontWeight: FontWeight.w400,
          ),
        ),
      ],
    );
  }

  // --------------------------------------------------------
  // HOST BADGE
  // --------------------------------------------------------
  Widget _buildHostBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.darkPrimary,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.darkTextSecondary, width: 1.5),
      ),
      child: const Row(
        children: [
          Icon(Icons.star, color: AppColors.darkTextSecondary, size: 16),
          SizedBox(width: 6),
          Text(
            "Host",
            style: TextStyle(
              color: AppColors.darkTextSecondary,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }

  // --------------------------------------------------------
  // DATE CHIP (Red)
  // --------------------------------------------------------
  Widget _buildDateChip(DateTime dt) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFFD87980), // Red chip
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.access_time, color: Colors.white),
          const SizedBox(width: 10),
          Text(
            _formatTime(dt),
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w700,
              fontSize: 18,
            ),
          ),
        ],
      ),
    );
  }

  // --------------------------------------------------------
  // FORMAT TIME
  // --------------------------------------------------------
  String _formatTime(DateTime dt) {
    final now = DateTime.now();

    if (dt.day == now.day && dt.month == now.month && dt.year == now.year) {
      return "Today, ${DateFormat('hh:mm a').format(dt)}";
    }

    return DateFormat("MMM d, hh:mm a").format(dt);
  }

  // --------------------------------------------------------
  // GET CATEGORY ICON
  // --------------------------------------------------------
  IconData _getCategoryIcon() {
    switch (event.category.toLowerCase()) {
      case "food & dining":
      case "food":
        return Icons.restaurant;
      case "movies":
        return Icons.movie;
      case "sports":
        return Icons.sports_soccer;
      default:
        return Icons.event;
    }
  }
}
