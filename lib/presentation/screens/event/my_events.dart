// screens/my_events/my_events_screen.dart
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
import 'package:innercircle/data/models/event.dart';
import 'package:innercircle/presentation/screens/event/event_details.dart';
import 'package:innercircle/presentation/widgets/curved_top_container.dart';

import 'package:innercircle/presentation/widgets/event_card.dart';

import 'dart:math' as math;

import 'package:innercircle/presentation/widgets/full_eventcard.dart';

class MyEventsScreen extends StatefulWidget {
  const MyEventsScreen({super.key});

  @override
  State<MyEventsScreen> createState() => _MyEventsScreenState();
}

class _MyEventsScreenState extends State<MyEventsScreen>
    with SingleTickerProviderStateMixin, AutomaticKeepAliveClientMixin {
  late TabController _tabController;

  // Cache events to prevent flickering
  List<Event>? _cachedHostedEvents;
  List<Event>? _cachedJoinedEvents;

  bool _hasLoadedHosted = false;
  bool _hasLoadedJoined = false;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);

    // Add listener for tab changes
    _tabController.addListener(() {
      if (!_tabController.indexIsChanging) {
        _onTabChanged(_tabController.index);
      }
    });

    // Load hosted events initially
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final authState = context.read<AuthBloc>().state;
      if (authState is AuthAuthenticated && !_hasLoadedHosted) {
        context.read<EventsBloc>().add(
          EventsLoadHostedRequested(authState.user.uid),
        );
        _hasLoadedHosted = true;
      }
    });
  }

  void _onTabChanged(int index) {
    final authState = context.read<AuthBloc>().state;
    if (authState is! AuthAuthenticated) return;

    if (index == 0 && !_hasLoadedHosted) {
      context.read<EventsBloc>().add(
        EventsLoadHostedRequested(authState.user.uid),
      );
      _hasLoadedHosted = true;
    } else if (index == 1 && !_hasLoadedJoined) {
      context.read<EventsBloc>().add(
        EventsLoadJoinedRequested(authState.user.uid),
      );
      _hasLoadedJoined = true;
    }
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
              AppColors.darkBackground, // top dark purple/grey
              Color(0xFF2F2F40), // mid shadow tone
              AppColors.darkBackground, // bottom almost-black
            ],
            stops: [0.2, 0.5, 1.0],
          ),
        ),
        child: BlocBuilder<AuthBloc, AuthState>(
          builder: (context, authState) {
            if (authState is! AuthAuthenticated) {
              return const Center(child: CircularProgressIndicator());
            }

            final currentUser = authState.user;

            return CustomScrollView(
              slivers: [
                // Custom App Bar
                SliverAppBar(
                  expandedHeight: 120,
                  floating: true,
                  pinned: true,
                  backgroundColor: Colors.transparent,
                  flexibleSpace: FlexibleSpaceBar(
                    background: CurvedTopContainer(
                      child: SafeArea(
                        child: Padding(
                          padding: EdgeInsets.all(10),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Text(
                                'My Events ',
                                style: AppTextStyles.headline.copyWith(
                                  color: AppColors.darkTextSecondary,
                                  fontSize: 28,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              SizedBox(height: 4),
                              Text(
                                'Events you\'re hosting or attending',
                                style: AppTextStyles.body.copyWith(
                                  color: AppColors.darkTextSecondary
                                      .withOpacity(0.9),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),

                // Tab Bar
                SliverPersistentHeader(
                  pinned: true,
                  delegate: _StickyTabBarDelegate(
                    TabBar(
                      controller: _tabController,
                      labelColor: AppColors.white,
                      dividerColor: Colors.transparent,
                      unselectedLabelColor: AppColors.darkSecondary,
                      indicatorPadding: EdgeInsets.symmetric(
                        horizontal: 15,
                        vertical: 2,
                      ),
                      indicatorColor: AppColors.darkSecondary,
                      indicator: BoxDecoration(
                        color: AppColors.darkSecondary,
                        borderRadius: BorderRadius.circular(15),
                      ),
                      indicatorWeight: 2,
                      indicatorSize: TabBarIndicatorSize.tab,
                      labelStyle: AppTextStyles.bodyMedium.copyWith(
                        fontWeight: FontWeight.w700,
                        fontSize: 16,
                      ),
                      unselectedLabelStyle: AppTextStyles.bodyMedium.copyWith(
                        fontWeight: FontWeight.w500,
                        fontSize: 16,
                      ),
                      tabs: [
                        Tab(
                          child: Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: 40,
                              vertical: 8,
                            ),
                            decoration: BoxDecoration(
                              // color: AppColors.darkSecondary.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(15),
                              border: Border.all(
                                color: AppColors.darkSecondary,
                                width: 1,
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.star_rounded, size: 18),
                                SizedBox(width: 6),
                                Text('Hosting'),
                              ],
                            ),
                          ),
                        ),
                        Tab(
                          child: Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: 40,
                              vertical: 8,
                            ),
                            decoration: BoxDecoration(
                              // color: AppColors.darkSecondary.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(15),
                              border: Border.all(
                                color: AppColors.darkSecondary,
                                width: 1,
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.event_rounded, size: 18),
                                SizedBox(width: 6),
                                Text('Joined'),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // Tab Views
                SliverFillRemaining(
                  child: TabBarView(
                    controller: _tabController,
                    children: [
                      _buildHostedEvents(currentUser.uid),
                      _buildJoinedEvents(currentUser.uid),
                    ],
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildHostedEvents(String userId) {
    return BlocBuilder<EventsBloc, EventsState>(
      buildWhen: (previous, current) {
        // Only rebuild for relevant states
        return current is EventsHostedLoaded ||
            current is EventsLoading ||
            current is EventsError;
      },
      builder: (context, state) {
        // Handle loading state
        if (state is EventsLoading && _cachedHostedEvents == null) {
          return _buildLoadingState();
        }

        // Handle error state
        if (state is EventsError && _cachedHostedEvents == null) {
          return _buildErrorState(
            state.message,
            () => context.read<EventsBloc>().add(
              EventsLoadHostedRequested(userId),
            ),
          );
        }

        // Handle loaded state
        if (state is EventsHostedLoaded) {
          _cachedHostedEvents = state.hostedEvents;
        }

        // Show cached or empty state
        final events = _cachedHostedEvents ?? [];

        if (events.isEmpty) {
          return _buildEmptyState(
            icon: Icons.star_rounded,
            emoji: '🎯',
            title: 'No Hosted Events Yet',
            subtitle:
                'Be a host! Create your first event\nand bring people together.',
            actionText: 'Create Event',
            onAction: () {
              DefaultTabController.of(context).animateTo(1);
            },
          );
        }

        return _buildEventsList(events, userId, isHosted: true);
      },
    );
  }

  Widget _buildJoinedEvents(String userId) {
    return BlocBuilder<EventsBloc, EventsState>(
      buildWhen: (previous, current) {
        return current is EventsJoinedLoaded ||
            current is EventsLoading ||
            current is EventsError;
      },
      builder: (context, state) {
        if (state is EventsLoading && _cachedJoinedEvents == null) {
          return _buildLoadingState();
        }

        if (state is EventsError && _cachedJoinedEvents == null) {
          return _buildErrorState(
            state.message,
            () => context.read<EventsBloc>().add(
              EventsLoadJoinedRequested(userId),
            ),
          );
        }

        if (state is EventsJoinedLoaded) {
          _cachedJoinedEvents = state.joinedEvents;
        }

        final events = _cachedJoinedEvents ?? [];

        if (events.isEmpty) {
          return _buildEmptyState(
            icon: Icons.event_rounded,
            emoji: '🔍',
            title: 'No Joined Events',
            subtitle: 'Discover amazing events near you\nand start connecting!',
            actionText: 'Explore Events',
            onAction: () {
              DefaultTabController.of(context).animateTo(0);
            },
          );
        }

        return _buildEventsList(events, userId, isHosted: false);
      },
    );
  }

  Widget _buildEventsList(
    List<Event> events,
    String userId, {
    required bool isHosted,
  }) {
    return RefreshIndicator(
      onRefresh: () async {
        if (isHosted) {
          context.read<EventsBloc>().add(EventsLoadHostedRequested(userId));
        } else {
          context.read<EventsBloc>().add(EventsLoadJoinedRequested(userId));
        }
        await Future.delayed(const Duration(milliseconds: 500));
      },
      color: AppColors.primary,
      child: ListView.builder(
        padding: EdgeInsets.fromLTRB(
          AppDimensions.spacingM,
          AppDimensions.spacingM,
          AppDimensions.spacingM,
          100, // Bottom padding for nav
        ),
        itemCount: events.length,
        itemBuilder: (context, index) {
          final event = events[index];

          return TweenAnimationBuilder<double>(
            tween: Tween(begin: 0, end: 1),
            duration: Duration(milliseconds: 300 + (index * 50)),
            curve: Curves.easeOut,
            builder: (context, value, child) {
              return Opacity(
                opacity: value,
                child: Transform.translate(
                  offset: Offset(0, 20 * (1 - value)),
                  child: FullEventCard(
                    event: event,
                    currentUserId: userId,
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
        },
      ),
    );
  }

  Widget _buildLoadingState() {
    return Center(
      child: Column(
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
                  child: Icon(
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
            'Loading your events...',
            style: AppTextStyles.body.copyWith(color: AppColors.textSecondary),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState({
    required IconData icon,
    required String emoji,
    required String title,
    required String subtitle,
    required String actionText,
    required VoidCallback onAction,
  }) {
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
              child: Text(emoji, style: TextStyle(fontSize: 80)),
            ),
            SizedBox(height: AppDimensions.spacingXL),
            Text(
              title,
              style: AppTextStyles.headline.copyWith(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: AppDimensions.spacingM),
            Text(
              subtitle,
              style: AppTextStyles.body.copyWith(
                fontSize: 16,
                color: AppColors.textSecondary,
                height: 1.5,
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
                onPressed: onAction,
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
                icon: Icon(icon, color: Colors.white),
                label: Text(
                  actionText,
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

  Widget _buildErrorState(String message, VoidCallback onRetry) {
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
                onPressed: onRetry,
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
                icon: Icon(Icons.refresh_rounded, color: Colors.white),
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

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }
}

// Custom delegate for sticky tab bar
class _StickyTabBarDelegate extends SliverPersistentHeaderDelegate {
  final TabBar tabBar;

  _StickyTabBarDelegate(this.tabBar);

  @override
  double get minExtent => tabBar.preferredSize.height;

  @override
  double get maxExtent => tabBar.preferredSize.height;

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.darkBackground,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: tabBar,
    );
  }

  @override
  bool shouldRebuild(_StickyTabBarDelegate oldDelegate) {
    return false;
  }
}
