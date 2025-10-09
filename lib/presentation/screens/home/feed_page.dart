// screens/home/feed_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:innercircle/blocs/auth/auth_bloc.dart';
import 'package:innercircle/blocs/auth/auth_state.dart';
import 'package:innercircle/blocs/events/events_bloc.dart';
import 'package:innercircle/blocs/events/events_event.dart';
import 'package:innercircle/blocs/events/events_state.dart';
import 'package:innercircle/core/theme/app_colors.dart';
import 'package:innercircle/core/theme/app_dimensions.dart';
import 'package:innercircle/core/theme/app_text_styles.dart';
import 'package:innercircle/core/utils/location_util.dart';
import 'package:innercircle/data/models/app_user.dart';
import 'package:innercircle/data/models/event.dart';
import 'package:innercircle/presentation/screens/event/event_details.dart';

import 'package:innercircle/presentation/widgets/event_card.dart';

import 'dart:math' as math;

class FeedPage extends StatefulWidget {
  const FeedPage({Key? key}) : super(key: key);

  @override
  State<FeedPage> createState() => _FeedPageState();
}

class _FeedPageState extends State<FeedPage>
    with AutomaticKeepAliveClientMixin, TickerProviderStateMixin {
  String _selectedCategory = 'All';
  List<Event>? _cachedEvents;
  late AnimationController _headerController;
  late AnimationController _categoriesController;
  late Animation<double> _headerAnimation;

  final List<Map<String, dynamic>> _categories = [
    {
      'name': 'All',
      'icon': Icons.grid_view_rounded,
      'color': AppColors.primary,
    },
    {
      'name': 'Movies',
      'icon': Icons.movie_rounded,
      'color': AppColors.movieColor,
    },
    {
      'name': 'Sports',
      'icon': Icons.sports_basketball_rounded,
      'color': AppColors.sportsColor,
    },
    {
      'name': 'Food & Dining',
      'icon': Icons.restaurant_rounded,
      'color': AppColors.foodColor,
    },
    {
      'name': 'Study Groups',
      'icon': Icons.school_rounded,
      'color': AppColors.studyColor,
    },
    {
      'name': 'Volunteering',
      'icon': Icons.volunteer_activism_rounded,
      'color': AppColors.volunteerColor,
    },
    {
      'name': 'Carpooling',
      'icon': Icons.directions_car_rounded,
      'color': AppColors.carpoolColor,
    },
    {
      'name': 'Shopping',
      'icon': Icons.shopping_bag_rounded,
      'color': AppColors.shoppingColor,
    },
    {
      'name': 'Cultural Events',
      'icon': Icons.celebration_rounded,
      'color': AppColors.culturalColor,
    },
  ];

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();

    _headerController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );

    _categoriesController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _headerAnimation = CurvedAnimation(
      parent: _headerController,
      curve: Curves.easeOut,
    );

    _headerController.forward();
    _categoriesController.forward();
  }

  @override
  void dispose() {
    _headerController.dispose();
    _categoriesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              AppColors.backgroundGradientTop,
              AppColors.backgroundGradientBottom,
            ],
          ),
        ),
        child: CustomScrollView(
          slivers: [
            _buildAnimatedHeader(),
            _buildCategoryFilter(),
            _buildEventsList(),
          ],
        ),
      ),
    );
  }

  Widget _buildAnimatedHeader() {
    return SliverToBoxAdapter(
      child: FadeTransition(
        opacity: _headerAnimation,
        child: SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(0, -0.5),
            end: Offset.zero,
          ).animate(_headerAnimation),
          child: Container(
            padding: EdgeInsets.fromLTRB(
              AppDimensions.spacingL,
              MediaQuery.of(context).padding.top + AppDimensions.spacingM,
              AppDimensions.spacingL,
              AppDimensions.spacingM,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                BlocBuilder<AuthBloc, AuthState>(
                  builder: (context, state) {
                    final name =
                        state is AuthAuthenticated
                            ? state.user.name.split(' ')[0]
                            : 'User';
                    return Text(
                      'Hey, $name! 👋',
                      style: AppTextStyles.headline.copyWith(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    );
                  },
                ),
                SizedBox(height: AppDimensions.spacingS),
                Text(
                  'Discover amazing events near you',
                  style: AppTextStyles.body.copyWith(
                    fontSize: 16,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCategoryFilter() {
    return SliverToBoxAdapter(
      child: Container(
        height: 110,
        padding: EdgeInsets.symmetric(vertical: AppDimensions.spacingM),
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          padding: EdgeInsets.symmetric(horizontal: AppDimensions.spacingM),
          itemCount: _categories.length,
          itemBuilder: (context, index) {
            final category = _categories[index];
            final isSelected = category['name'] == _selectedCategory;

            return TweenAnimationBuilder<double>(
              tween: Tween(begin: 0, end: 1),
              duration: Duration(milliseconds: 400 + (index * 50)),
              curve: Curves.elasticOut,
              builder: (context, value, child) {
                return Transform.scale(
                  scale: value,
                  child: _buildCategoryChip(
                    name: category['name'],
                    icon: category['icon'],
                    color: category['color'],
                    isSelected: isSelected,
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }

  Widget _buildCategoryChip({
    required String name,
    required IconData icon,
    required Color color,
    required bool isSelected,
  }) {
    return Padding(
      padding: EdgeInsets.only(right: AppDimensions.spacingM),
      child: GestureDetector(
        onTap: () {
          setState(() => _selectedCategory = name);
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
          width: isSelected ? 140 : 80,
          decoration: BoxDecoration(
            gradient:
                isSelected
                    ? LinearGradient(
                      colors: [color, color.withOpacity(0.7)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    )
                    : null,
            color: isSelected ? null : Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: isSelected ? Colors.transparent : AppColors.borderLight,
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color:
                    isSelected
                        ? color.withOpacity(0.3)
                        : Colors.black.withOpacity(0.05),
                blurRadius: isSelected ? 15 : 8,
                spreadRadius: 0,
                offset: Offset(0, isSelected ? 6 : 2),
              ),
            ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                color: isSelected ? Colors.white : color,
                size: isSelected ? 28 : 24,
              ),
              if (isSelected) ...[
                SizedBox(height: AppDimensions.spacingS),
                Text(
                  name,
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                    fontSize: 12,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEventsList() {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, authState) {
        if (authState is! AuthAuthenticated) {
          return const SliverFillRemaining(
            child: Center(child: CircularProgressIndicator()),
          );
        }

        final currentUser = authState.user;

        return BlocBuilder<EventsBloc, EventsState>(
          buildWhen: (previous, current) {
            final shouldRebuild =
                current is EventsLoaded ||
                current is EventsError ||
                (current is EventsLoading && previous is! EventsLoaded) ||
                current is EventsInitial;
            return shouldRebuild;
          },
          builder: (context, state) {
            // Handle non-feed states with cached events
            if (state is EventsHostedLoaded ||
                state is EventsJoinedLoaded ||
                state is EventCreated ||
                state is EventJoined ||
                state is EventLeft ||
                state is EventDeleted) {
              if (_cachedEvents != null) {
                return _buildEventsGrid(_cachedEvents!, currentUser);
              }
              return const SliverFillRemaining(
                child: Center(child: CircularProgressIndicator()),
              );
            }

            // Loading state
            if (state is EventsLoading || state is EventsInitial) {
              if (_cachedEvents != null) {
                return _buildEventsGrid(_cachedEvents!, currentUser);
              }
              return SliverFillRemaining(
                child: Center(child: _buildCustomLoader()),
              );
            }

            // Error state
            if (state is EventsError) {
              if (_cachedEvents != null) {
                return _buildEventsGrid(_cachedEvents!, currentUser);
              }
              return SliverFillRemaining(
                child: _buildErrorState(state.message),
              );
            }

            // Loaded state
            if (state is EventsLoaded) {
              _cachedEvents = state.events;
              return _buildEventsGrid(state.events, currentUser);
            }

            // Fallback
            if (_cachedEvents != null) {
              return _buildEventsGrid(_cachedEvents!, currentUser);
            }
            return const SliverFillRemaining(
              child: Center(child: CircularProgressIndicator()),
            );
          },
        );
      },
    );
  }

  Widget _buildEventsGrid(List<Event> allEvents, AppUser currentUser) {
    var events = allEvents;

    // Filter by category
    if (_selectedCategory != 'All') {
      events = events.where((e) => e.category == _selectedCategory).toList();
    }

    // Filter out past events
    final now = DateTime.now();
    events = events.where((e) => e.dateTime.isAfter(now)).toList();

    if (events.isEmpty) {
      return SliverFillRemaining(child: _buildEmptyState());
    }

    return SliverPadding(
      padding: EdgeInsets.fromLTRB(
        AppDimensions.spacingM,
        AppDimensions.spacingS,
        AppDimensions.spacingM,
        100, // Extra bottom padding for FAB
      ),
      sliver: SliverList(
        delegate: SliverChildBuilderDelegate((context, index) {
          final event = events[index];
          final distance = _calculateDistance(currentUser, event);

          return TweenAnimationBuilder<double>(
            tween: Tween(begin: 0, end: 1),
            duration: Duration(milliseconds: 300 + (index * 50)),
            curve: Curves.easeOut,
            builder: (context, value, child) {
              return Opacity(
                opacity: value,
                child: Transform.translate(
                  offset: Offset(0, 20 * (1 - value)),
                  child: EventCard(
                    event: event,
                    distanceInKm: distance,
                    currentUserId: currentUser.uid,
                    onTap: () {
                      Navigator.push(
                        context,
                        PageRouteBuilder(
                          pageBuilder:
                              (context, animation, secondaryAnimation) =>
                                  BlocProvider.value(
                                    value: context.read<EventsBloc>(),
                                    child: EventDetailScreen(event: event),
                                  ),
                          transitionsBuilder: (
                            context,
                            animation,
                            secondaryAnimation,
                            child,
                          ) {
                            return FadeTransition(
                              opacity: animation,
                              child: child,
                            );
                          },
                          transitionDuration: const Duration(milliseconds: 300),
                        ),
                      );
                    },
                  ),
                ),
              );
            },
          );
        }, childCount: events.length),
      ),
    );
  }

  Widget _buildCustomLoader() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        TweenAnimationBuilder<double>(
          tween: Tween(begin: 0, end: 1),
          duration: const Duration(seconds: 1),
          builder: (context, value, child) {
            return Transform.rotate(
              angle: value * 2 * math.pi,
              child: Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  gradient: AppColors.primaryGradient,
                  borderRadius: BorderRadius.circular(30),
                ),
                child: const Icon(
                  Icons.refresh_rounded,
                  color: Colors.white,
                  size: 30,
                ),
              ),
            );
          },
        ),
        SizedBox(height: AppDimensions.spacingL),
        Text(
          'Loading amazing events...',
          style: AppTextStyles.body.copyWith(color: AppColors.textSecondary),
        ),
      ],
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: SingleChildScrollView(
        padding: EdgeInsets.all(AppDimensions.spacingXL),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: EdgeInsets.all(AppDimensions.spacingXL),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppColors.primary.withOpacity(0.1),
                    AppColors.accent.withOpacity(0.1),
                  ],
                ),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.event_busy_rounded,
                size: 80,
                color: AppColors.primary,
              ),
            ),
            SizedBox(height: AppDimensions.spacingXL),
            Text(
              _selectedCategory == 'All'
                  ? 'No Events Yet! 🎉'
                  : 'No $_selectedCategory Events',
              style: AppTextStyles.headline.copyWith(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: AppDimensions.spacingM),
            Text(
              _selectedCategory == 'All'
                  ? 'Be the pioneer! Create the first event\nand bring people together.'
                  : 'Try exploring other categories\nor create your own event!',
              style: AppTextStyles.body.copyWith(
                fontSize: 16,
                color: AppColors.textSecondary,
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: AppDimensions.spacingXL),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorState(String message) {
    return Center(
      child: SingleChildScrollView(
        padding: EdgeInsets.all(AppDimensions.spacingXL),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: EdgeInsets.all(AppDimensions.spacingXL),
              decoration: BoxDecoration(
                color: AppColors.errorLight,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.error_outline_rounded,
                size: 80,
                color: AppColors.error,
              ),
            ),
            SizedBox(height: AppDimensions.spacingXL),
            Text(
              'Oops! Something went wrong',
              style: AppTextStyles.headline.copyWith(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: AppDimensions.spacingM),
            Text(
              message,
              style: AppTextStyles.body.copyWith(
                fontSize: 15,
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: AppDimensions.spacingXL),
            Container(
              decoration: BoxDecoration(
                gradient: AppColors.primaryGradient,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withOpacity(0.3),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: ElevatedButton.icon(
                onPressed: () {
                  context.read<EventsBloc>().add(EventsLoadRequested());
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  shadowColor: Colors.transparent,
                  padding: EdgeInsets.symmetric(
                    horizontal: AppDimensions.spacingXL,
                    vertical: AppDimensions.spacingM,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                icon: const Icon(Icons.refresh_rounded, color: Colors.white),
                label: Text(
                  'Try Again',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  double? _calculateDistance(AppUser user, Event event) {
    if (user.lat == null || user.lng == null) return null;
    return LocationUtils.calculateDistance(
      user.lat!,
      user.lng!,
      event.lat,
      event.lng,
    );
  }
}
