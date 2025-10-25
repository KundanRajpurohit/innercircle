// screens/event_detail/event_detail_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:innercircle/blocs/auth/auth_bloc.dart';
import 'package:innercircle/blocs/auth/auth_state.dart';
import 'package:innercircle/blocs/chat/chat_bloc.dart';
import 'package:innercircle/blocs/events/events_bloc.dart';
import 'package:innercircle/blocs/events/events_event.dart';
import 'package:innercircle/blocs/events/events_state.dart';
import 'package:innercircle/core/theme/app_colors.dart';
import 'package:innercircle/core/theme/app_dimensions.dart';
import 'package:innercircle/core/theme/app_text_styles.dart';
import 'package:innercircle/data/models/app_user.dart';
import 'package:innercircle/data/models/event.dart';
import 'package:innercircle/data/repositries/auth_repository.dart';
import 'package:innercircle/data/repositries/firebase_service.dart';
import 'package:innercircle/presentation/widgets/primary_button.dart';
import 'package:innercircle/presentation/widgets/secondary_button.dart';
import 'package:intl/intl.dart';
import 'package:cached_network_image/cached_network_image.dart';

import '../chat/chat_screen.dart';

class EventDetailScreen extends StatefulWidget {
  final Event event;

  const EventDetailScreen({Key? key, required this.event}) : super(key: key);

  @override
  State<EventDetailScreen> createState() => _EventDetailScreenState();
}

class _EventDetailScreenState extends State<EventDetailScreen> {
  AppUser? _hostUser;
  bool _isLoadingHost = true;

  @override
  void initState() {
    super.initState();
    _loadHostUser();
  }

  Future<void> _loadHostUser() async {
    final authService = context.read<AuthService>();
    final host = await authService.getUserProfile(widget.event.hostId);

    if (mounted) {
      setState(() {
        _hostUser = host;
        _isLoadingHost = false;
      });
    }
  }

  void _joinEvent(String userId) {
    context.read<EventsBloc>().add(EventJoinRequested(widget.event.id, userId));
  }

  void _leaveEvent(String userId) {
    context.read<EventsBloc>().add(
      EventLeaveRequested(widget.event.id, userId),
    );
  }

  void _deleteEvent() {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Delete Event'),
            content: const Text('Are you sure you want to delete this event?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () {
                  context.read<EventsBloc>().add(
                    EventDeleteRequested(widget.event.id),
                  );
                  Navigator.pop(context); // Close dialog
                  Navigator.pop(context); // Go back to feed
                },
                child: Text('Delete', style: TextStyle(color: AppColors.error)),
              ),
            ],
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocListener<EventsBloc, EventsState>(
        listener: (context, state) {
          if (state is EventJoined) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Joined event successfully!')),
            );
          } else if (state is EventLeft) {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(const SnackBar(content: Text('Left event')));
          } else if (state is EventDeleted) {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(const SnackBar(content: Text('Event deleted')));
          } else if (state is EventsError) {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text('Error: ${state.message}')));
          }
        },
        child: BlocBuilder<AuthBloc, AuthState>(
          builder: (context, authState) {
            if (authState is! AuthAuthenticated) {
              return const Center(child: CircularProgressIndicator());
            }

            final currentUser = authState.user;
            final isHost = widget.event.hostId == currentUser.uid;
            final hasJoined = widget.event.joinedUsers.contains(
              currentUser.uid,
            );

            return CustomScrollView(
              slivers: [
                // App Bar with Category Header
                SliverAppBar(
                  expandedHeight: 200,
                  pinned: true,
                  flexibleSpace: FlexibleSpaceBar(
                    background: _buildCategoryHeader(),
                  ),
                  actions: [
                    if (isHost)
                      IconButton(
                        icon: const Icon(Icons.delete_outline),
                        onPressed: _deleteEvent,
                      ),
                  ],
                ),

                // Content
                SliverToBoxAdapter(
                  child: Padding(
                    padding: AppDimensions.screenPadding,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Title
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                widget.event.title,
                                style: AppTextStyles.headline,
                              ),
                            ),
                            if (isHost)
                              Container(
                                padding: EdgeInsets.symmetric(
                                  horizontal: AppDimensions.spacingM,
                                  vertical: AppDimensions.spacingS,
                                ),
                                decoration: BoxDecoration(
                                  color: AppColors.primary.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(
                                    AppDimensions.radiusCircular,
                                  ),
                                ),
                                child: Text(
                                  'Host',
                                  style: AppTextStyles.body.copyWith(
                                    color: AppColors.primary,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                          ],
                        ),
                        SizedBox(height: AppDimensions.spacingL),

                        // Date & Time
                        _buildInfoRow(
                          Icons.calendar_today,
                          'Date & Time',
                          DateFormat(
                            'EEEE, MMM dd, yyyy',
                          ).format(widget.event.dateTime),
                        ),
                        SizedBox(height: AppDimensions.spacingS),
                        Padding(
                          padding: EdgeInsets.only(left: 40),
                          child: Text(
                            DateFormat('h:mm a').format(widget.event.dateTime),
                            style: AppTextStyles.body.copyWith(
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ),
                        SizedBox(height: AppDimensions.spacingM),

                        // Attendees
                        _buildInfoRow(
                          Icons.people_outline,
                          'Attendees',
                          '${widget.event.joinedUsers.length} joined',
                        ),
                        SizedBox(height: AppDimensions.spacingM),

                        // Category
                        _buildInfoRow(
                          Icons.category_outlined,
                          'Category',
                          widget.event.category,
                        ),
                        SizedBox(height: AppDimensions.spacingL),

                        // Description
                        Text('About', style: AppTextStyles.subheading),
                        SizedBox(height: AppDimensions.spacingS),
                        Text(
                          widget.event.description,
                          style: AppTextStyles.body,
                        ),
                        SizedBox(height: AppDimensions.spacingL),

                        // Host Info
                        Text('Host', style: AppTextStyles.subheading),
                        SizedBox(height: AppDimensions.spacingM),
                        _isLoadingHost
                            ? const Center(child: CircularProgressIndicator())
                            : _hostUser != null
                            ? _buildHostCard(_hostUser!)
                            : const SizedBox.shrink(),
                        SizedBox(height: AppDimensions.spacingL),

                        // Map
                        Text('Location', style: AppTextStyles.subheading),
                        SizedBox(height: AppDimensions.spacingM),
                        _buildMap(),
                        SizedBox(height: AppDimensions.spacingXL),

                        // Action Buttons
                        if (!isHost)
                          hasJoined
                              ? Column(
                                children: [
                                  PrimaryButton(
                                    text: 'Open Chat',
                                    onPressed: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder:
                                              (_) => BlocProvider(
                                                create:
                                                    (_) => ChatBloc(
                                                      firestoreService:
                                                          context
                                                              .read<
                                                                FirestoreService
                                                              >(),
                                                    ),
                                                child: ChatScreen(
                                                  event: widget.event,
                                                  currentUser: currentUser,
                                                ),
                                              ),
                                        ),
                                      );
                                    },
                                    icon: Icons.chat_bubble_outline,
                                  ),
                                  SizedBox(height: AppDimensions.spacingM),
                                  SecondaryButton(
                                    text: 'Leave Event',
                                    onPressed:
                                        () => _leaveEvent(currentUser.uid),
                                    icon: Icons.exit_to_app,
                                  ),
                                ],
                              )
                              : PrimaryButton(
                                text: 'Join Event',
                                onPressed: () => _joinEvent(currentUser.uid),
                                icon: Icons.add_circle_outline,
                              )
                        else
                          PrimaryButton(
                            text: 'Open Chat',
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder:
                                      (_) => BlocProvider(
                                        create:
                                            (_) => ChatBloc(
                                              firestoreService:
                                                  context
                                                      .read<FirestoreService>(),
                                            ),
                                        child: ChatScreen(
                                          event: widget.event,
                                          currentUser: currentUser,
                                        ),
                                      ),
                                ),
                              );
                            },
                            icon: Icons.chat_bubble_outline,
                          ),
                        SizedBox(height: AppDimensions.spacingXL),
                      ],
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildCategoryHeader() {
    final categoryData = _getCategoryData(widget.event.category);

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            categoryData['color'].withOpacity(0.8),
            categoryData['color'],
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(categoryData['icon'], size: 64, color: Colors.white),
            SizedBox(height: AppDimensions.spacingS),
            Text(
              widget.event.category,
              style: AppTextStyles.subheading.copyWith(
                color: Colors.white,
                fontSize: 20,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Container(
          padding: EdgeInsets.all(AppDimensions.spacingS),
          decoration: BoxDecoration(
            color: AppColors.primary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(AppDimensions.radiusS),
          ),
          child: Icon(icon, color: AppColors.primary, size: 20),
        ),
        SizedBox(width: AppDimensions.spacingM),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: AppTextStyles.caption),
              SizedBox(height: AppDimensions.spacingXS),
              Text(value, style: AppTextStyles.bodyMedium),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildHostCard(AppUser host) {
    return Container(
      padding: EdgeInsets.all(AppDimensions.spacingM),
      decoration: BoxDecoration(
        color: AppColors.grey50,
        borderRadius: BorderRadius.circular(AppDimensions.radiusM),
        border: Border.all(color: AppColors.borderLight),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 30,
            backgroundColor: AppColors.primary,
            backgroundImage:
                host.photoUrl != null
                    ? CachedNetworkImageProvider(host.photoUrl!)
                    : null,
            child:
                host.photoUrl == null
                    ? Text(
                      host.name[0].toUpperCase(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.w600,
                      ),
                    )
                    : null,
          ),
          SizedBox(width: AppDimensions.spacingM),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  host.name,
                  style: AppTextStyles.bodyMedium.copyWith(fontSize: 16),
                ),
                SizedBox(height: AppDimensions.spacingXS),
                Text('Event Host', style: AppTextStyles.caption),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMap() {
    return Container(
      height: 200,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppDimensions.radiusM),
        border: Border.all(color: AppColors.borderLight),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(AppDimensions.radiusM),
        child: GoogleMap(
          initialCameraPosition: CameraPosition(
            target: LatLng(widget.event.lat, widget.event.lng),
            zoom: 15,
          ),
          markers: {
            Marker(
              markerId: MarkerId(widget.event.id),
              position: LatLng(widget.event.lat, widget.event.lng),
              infoWindow: InfoWindow(title: widget.event.title),
            ),
          },
          zoomControlsEnabled: false,
          myLocationButtonEnabled: false,
        ),
      ),
    );
  }

  Map<String, dynamic> _getCategoryData(String category) {
    switch (category.toLowerCase()) {
      case 'movie':
      case 'movies':
        return {'icon': Icons.movie_outlined, 'color': AppColors.movieColor};
      case 'sports':
      case 'cricket':
      case 'football':
        return {
          'icon': Icons.sports_cricket_outlined,
          'color': AppColors.sportsColor,
        };
      case 'food':
      case 'food & dining':
      case 'dining':
        return {
          'icon': Icons.restaurant_outlined,
          'color': AppColors.foodColor,
        };
      case 'study':
      case 'study groups':
      case 'learning':
        return {'icon': Icons.school_outlined, 'color': AppColors.studyColor};
      case 'volunteer':
      case 'volunteering':
        return {
          'icon': Icons.volunteer_activism_outlined,
          'color': AppColors.volunteerColor,
        };
      case 'carpool':
      case 'carpooling':
      case 'ride':
        return {
          'icon': Icons.directions_car_outlined,
          'color': AppColors.carpoolColor,
        };
      case 'shopping':
      case 'mall':
        return {
          'icon': Icons.shopping_bag_outlined,
          'color': AppColors.shoppingColor,
        };
      case 'cultural':
      case 'cultural events':
      case 'garba':
      case 'festival':
        return {
          'icon': Icons.celebration_outlined,
          'color': AppColors.culturalColor,
        };
      default:
        return {'icon': Icons.event_outlined, 'color': AppColors.primary};
    }
  }
}
