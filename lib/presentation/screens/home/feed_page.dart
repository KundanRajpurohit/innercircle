// screens/home/feed_page.dart
import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
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

class FeedPage extends StatefulWidget {
  const FeedPage({super.key});

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

  // Map / Feed toggle
  bool _showMapView = false;
  final Completer<GoogleMapController> _mapController = Completer();

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

    // Ensure events are loaded on first mount
    Future.microtask(() {
      final bloc = context.read<EventsBloc>();
      final currentState = bloc.state;
      if (currentState is! EventsLoaded && currentState is! EventsLoading) {
        bloc.add(EventsLoadRequested());
      }
    });

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

  void _toggleMap() => setState(() => _showMapView = !_showMapView);

  void _onMarkerTap(BuildContext context, Event event) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.background,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder:
          (_) => FractionallySizedBox(
            heightFactor: 0.85,
            child: EventDetailScreen(event: event),
          ),
    );
  }

  // ==== Target palette (hardcoded for now) ====
  // page bg
  static const _surfaceDark = Color(0xFF3B394C); // not used yet
  static const _olive = Color(0xFF8A8E57); // header + canopy
  // category pill bg
  static const _yellowIcon = Color(0xFF7A5B2F); // brown-ish icon/text on pills
  static const _pinkAccent = Color(0xFFD8898A); // accent (filter FAB etc.)
  static const _textOnDark = Colors.white; // white
  // for contrast on olive if needed

  @override
  Widget build(BuildContext context) {
    super.build(context);

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,

      body: Stack(
        children: [
          CustomScrollView(
            slivers: [
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(14.0),
                  child: _buildHeader(context),
                ),
              ),

              _buildEventsList(), // rewritten version
            ],
          ),

          // FILTER FAB
          // Positioned(right: 16, bottom: 120, child: _buildFilterFab()),
        ],
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
          child: Padding(
            padding: EdgeInsets.fromLTRB(
              AppDimensions.spacingL,
              MediaQuery.of(context).padding.top + AppDimensions.spacingM,
              AppDimensions.spacingL,
              AppDimensions.spacingM,
            ),
            child: BlocBuilder<AuthBloc, AuthState>(
              builder: (context, state) {
                final name =
                    state is AuthAuthenticated
                        ? (state.user.name.split(' ').isNotEmpty
                            ? state.user.name.split(' ')[0]
                            : state.user.name)
                        : 'User';
                final avatarUrl =
                    state is AuthAuthenticated ? state.user.photoUrl : null;

                return Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // Avatar
                    if (avatarUrl != null && avatarUrl.isNotEmpty)
                      CircleAvatar(
                        radius: 22,
                        backgroundImage: NetworkImage(avatarUrl),
                      )
                    else
                      CircleAvatar(
                        radius: 22,
                        backgroundColor: AppColors.primary.withOpacity(0.12),
                        child: Text(
                          name.isNotEmpty ? name[0].toUpperCase() : 'U',
                          style: AppTextStyles.headline.copyWith(
                            fontSize: 18,
                            color: AppColors.primary,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    SizedBox(width: AppDimensions.spacingM),
                    // Greeting + subtitle
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Hey, $name! 👋',
                            style: AppTextStyles.headline.copyWith(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          SizedBox(height: AppDimensions.spacingXS),
                          Text(
                            'Discover amazing events near you',
                            style: AppTextStyles.body.copyWith(
                              fontSize: 14,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    // Map / Feed toggle button
                    GestureDetector(
                      onTap: _toggleMap,
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 320),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(18),
                          gradient:
                              _showMapView
                                  ? LinearGradient(
                                    colors: [
                                      AppColors.primary,
                                      AppColors.primaryLight,
                                    ],
                                  )
                                  : LinearGradient(
                                    colors: [
                                      Colors.grey.shade200,
                                      Colors.grey.shade300,
                                    ],
                                  ),
                          boxShadow:
                              _showMapView
                                  ? [
                                    BoxShadow(
                                      color: AppColors.primary.withOpacity(0.2),
                                      blurRadius: 8,
                                      offset: const Offset(0, 4),
                                    ),
                                  ]
                                  : [],
                        ),
                        child: Row(
                          children: [
                            Icon(
                              _showMapView
                                  ? Icons.list_rounded
                                  : Icons.map_rounded,
                              size: 18,
                              color:
                                  _showMapView ? Colors.white : Colors.black87,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              _showMapView ? 'Feed' : 'Map',
                              style: TextStyle(
                                color:
                                    _showMapView
                                        ? Colors.white
                                        : Colors.black87,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSuggestedSlot() {
    // Use EventsBloc + AuthBloc states to compute suggestions.
    final eventsState = context.read<EventsBloc>().state;
    final authState = context.read<AuthBloc>().state;

    if (eventsState is! EventsLoaded || authState is! AuthAuthenticated) {
      // No suggestions available yet
      return const SliverToBoxAdapter(child: SizedBox.shrink());
    }

    final currentUser = authState.user;
    final allEvents = eventsState.events;

    // Build a mocked "suggested" selection:
    // 1) upcoming events
    // 2) within 6km if user location present
    // 3) prefer interest/tag overlap if available
    final now = DateTime.now();
    List<Event> candidates =
        allEvents.where((e) => e.dateTime.isAfter(now)).toList();

    if (currentUser.lat != null && currentUser.lng != null) {
      candidates =
          candidates.where((e) {
            final d = LocationUtils.calculateDistance(
              currentUser.lat!,
              currentUser.lng!,
              e.lat,
              e.lng,
            );
            return d <= 8.0; // keep within 8 km for suggestions
          }).toList();
    }

    // Prefer by interest/tag overlap if available on event model (mocked as 'tags' property may not exist)
    // We'll fallback to the closest events if no tags.
    // For mocking, just take first few after filtering.
    final suggested =
        (candidates..sort((a, b) => a.dateTime.compareTo(b.dateTime)))
            .take(6)
            .toList();

    if (suggested.isEmpty) {
      return SliverToBoxAdapter(
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: AppDimensions.spacingM),
          child: Center(
            child: Text(
              'No suggested events for now',
              style: AppTextStyles.body.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ),
        ),
      );
    }

    return SliverToBoxAdapter(
      child: Padding(
        padding: EdgeInsets.only(
          left: AppDimensions.spacingM,
          top: AppDimensions.spacingS,
          bottom: AppDimensions.spacingS,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Suggested for you',
              style: AppTextStyles.headline.copyWith(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
            SizedBox(height: AppDimensions.spacingS),
            SizedBox(
              height: 150,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                padding: EdgeInsets.symmetric(
                  horizontal: AppDimensions.spacingM,
                ),
                itemCount: suggested.length,
                separatorBuilder:
                    (_, __) => SizedBox(width: AppDimensions.spacingM),
                itemBuilder: (context, i) {
                  final e = suggested[i];
                  return GestureDetector(
                    onTap: () => _openEventDetails(e),
                    child: Container(
                      width: 260,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(14),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 12,
                            offset: const Offset(0, 6),
                          ),
                        ],
                      ),
                      child: Padding(
                        padding: EdgeInsets.all(AppDimensions.spacingM),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 6,
                                  ),
                                  decoration: BoxDecoration(
                                    color: AppColors.primary.withOpacity(0.08),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Text(
                                    e.category,
                                    style: AppTextStyles.body.copyWith(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                      color: AppColors.primary,
                                    ),
                                  ),
                                ),
                                Text(
                                  _formatEventTime(e.dateTime),
                                  style: AppTextStyles.body.copyWith(
                                    fontSize: 12,
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: AppDimensions.spacingS),
                            Text(
                              e.title,
                              style: AppTextStyles.headline.copyWith(
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                                color: AppColors.textPrimary,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const Spacer(),
                            Row(
                              children: [
                                CircleAvatar(
                                  radius: 12,
                                  backgroundColor: AppColors.primary
                                      .withOpacity(0.12),
                                  child: Text(
                                    e.hostId.isNotEmpty
                                        ? e.hostId[0].toUpperCase()
                                        : 'H',
                                    style: TextStyle(
                                      color: AppColors.primary,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ),
                                SizedBox(width: AppDimensions.spacingS),
                                Expanded(
                                  child: Text(
                                    'Host',
                                    style: AppTextStyles.body.copyWith(
                                      fontSize: 12,
                                      color: AppColors.textSecondary,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                SizedBox(width: AppDimensions.spacingS),
                                Builder(
                                  builder: (ctx) {
                                    final d = _maybeDistanceForCurrentUser(e);
                                    return Text(
                                      d != null
                                          ? '${d.toStringAsFixed(1)} km'
                                          : '',
                                      style: AppTextStyles.body.copyWith(
                                        fontSize: 12,
                                        color: AppColors.textSecondary,
                                      ),
                                    );
                                  },
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _openEventDetails(Event e) {
    Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder:
            (context, animation, secondaryAnimation) => BlocProvider.value(
              value: context.read<EventsBloc>(),
              child: EventDetailScreen(event: e),
            ),
        transitionsBuilder:
            (context, animation, secondaryAnimation, child) =>
                FadeTransition(opacity: animation, child: child),
      ),
    );
  }

  double? _maybeDistanceForCurrentUser(Event event) {
    final authState = context.read<AuthBloc>().state;
    if (authState is! AuthAuthenticated) return null;
    final user = authState.user;
    if (user.lat == null || user.lng == null) return null;
    return LocationUtils.calculateDistance(
      user.lat!,
      user.lng!,
      event.lat,
      event.lng,
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
            final cat = _categories[index];
            final isSelected = cat['name'] == _selectedCategory;
            return TweenAnimationBuilder<double>(
              tween: Tween(begin: 0, end: 1),
              duration: Duration(milliseconds: 400 + (index * 50)),
              curve: Curves.elasticOut,
              builder: (context, value, child) {
                return Transform.scale(
                  scale: value,
                  child: _buildCategoryChip(
                    name: cat['name'],
                    icon: cat['icon'],
                    color: cat['color'],
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
        onTap: () => setState(() => _selectedCategory = name),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
          width: isSelected ? 140 : 80,
          decoration: BoxDecoration(
            gradient:
                isSelected
                    ? LinearGradient(colors: [color, color.withOpacity(0.7)])
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
                        ? color.withOpacity(0.28)
                        : Colors.black.withOpacity(0.05),
                blurRadius: isSelected ? 15 : 8,
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
                  style: const TextStyle(
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
            // non-feed states -> show cached if exists
            if (state is EventsHostedLoaded ||
                state is EventsJoinedLoaded ||
                state is EventCreated ||
                state is EventJoined ||
                state is EventLeft ||
                state is EventDeleted) {
              if (_cachedEvents != null)
                return _buildEventsGrid(_cachedEvents!, currentUser);
              return SliverFillRemaining(
                child: Center(child: _buildCustomLoader()),
              );
            }

            // loading
            if (state is EventsLoading || state is EventsInitial) {
              if (_cachedEvents != null)
                return _buildEventsGrid(_cachedEvents!, currentUser);
              return SliverFillRemaining(
                child: Center(child: _buildCustomLoader()),
              );
            }

            // error
            if (state is EventsError) {
              if (_cachedEvents != null)
                return _buildEventsGrid(_cachedEvents!, currentUser);
              return SliverFillRemaining(
                child: _buildErrorState(state.message),
              );
            }

            // loaded
            if (state is EventsLoaded) {
              _cachedEvents = state.events;
              // If map view is requested, show full map overlay instead of list:
              if (_showMapView) {
                // Return a sliver that contains a single child: the full map.
                return SliverToBoxAdapter(
                  child: SizedBox(
                    height: MediaQuery.of(context).size.height - 140,
                    child: _buildMapView(state.events),
                  ),
                );
              }
              return _buildEventsGrid(state.events, currentUser);
            }

            // fallback
            if (_cachedEvents != null)
              return _buildEventsGrid(_cachedEvents!, currentUser);
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

    // category filter
    if (_selectedCategory != 'All')
      events = events.where((e) => e.category == _selectedCategory).toList();

    // upcoming only
    final now = DateTime.now();
    events = events.where((e) => e.dateTime.isAfter(now)).toList();

    if (events.isEmpty) return SliverFillRemaining(child: _buildEmptyState());

    return SliverPadding(
      padding: EdgeInsets.fromLTRB(
        AppDimensions.spacingM,
        AppDimensions.spacingS,
        AppDimensions.spacingM,
        100,
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
                    onTap: () => _openEventDetails(event),
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
    return SingleChildScrollView(
      padding: EdgeInsets.all(AppDimensions.spacingXL),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Container(
            padding: EdgeInsets.all(AppDimensions.spacingXL),
            decoration: BoxDecoration(
              color: AppColors.darkText.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.event_busy_rounded,
              size: 80,
              color: AppColors.darkPrimary,
            ),
          ),
          SizedBox(height: AppDimensions.spacingXL),
          Text(
            _selectedCategory == 'All'
                ? 'No Events Yet! '
                : 'No $_selectedCategory Events',
            style: AppTextStyles.headline.copyWith(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: AppColors.darkText,
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
                onPressed:
                    () => context.read<EventsBloc>().add(EventsLoadRequested()),
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
                label: const Text(
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

  String _formatEventTime(DateTime dt) {
    final now = DateTime.now();
    if (dt.year == now.year && dt.month == now.month && dt.day == now.day) {
      return '${dt.hour}:${dt.minute.toString().padLeft(2, '0')}';
    }
    return '${dt.day}/${dt.month}';
  }

  /// Full-screen map overlay built from events list
  Widget _buildMapView(List<Event> events) {
    final Set<Marker> markers =
        events.map((event) {
          return Marker(
            markerId: MarkerId(event.id),
            position: LatLng(event.lat, event.lng),
            infoWindow: InfoWindow(title: event.title),
            icon: BitmapDescriptor.defaultMarkerWithHue(
              BitmapDescriptor.hueAzure,
            ),
            onTap: () => _onMarkerTap(context, event),
          );
        }).toSet();

    final initialPosition =
        events.isNotEmpty
            ? LatLng(events.first.lat, events.first.lng)
            : const LatLng(28.6139, 77.2090);

    return Stack(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: GoogleMap(
            initialCameraPosition: CameraPosition(
              target: initialPosition,
              zoom: 12.5,
            ),
            markers: markers,
            zoomControlsEnabled: false,
            myLocationEnabled: true,
            myLocationButtonEnabled: true,
            onMapCreated: (controller) {
              if (!_mapController.isCompleted)
                _mapController.complete(controller);
            },
          ),
        ),
        // Top fade to keep header readable when overlaying
        Positioned(
          top: 0,
          left: 0,
          right: 0,
          height: 80,
          child: IgnorePointer(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    AppColors.background.withOpacity(0.9),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),
        ),
        // Floating control to switch back to feed
        Positioned(
          top: 28 + MediaQuery.of(context).padding.top,
          right: 16,
          child: FloatingActionButton.small(
            onPressed: () => setState(() => _showMapView = false),
            backgroundColor: Colors.white,
            child: const Icon(
              Icons.keyboard_arrow_left_rounded,
              color: Colors.black,
            ),
          ),
        ),
      ],
    );
  }

  Widget _categoryPill({
    required String label,
    required IconData icon,
    required bool selected,
  }) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 220),
      width: 100,
      height: 50,
      decoration: BoxDecoration(
        color: AppColors.darkPrimary,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: selected ? Colors.white : Colors.transparent,
          width: 2,
        ),
        // boxShadow: [
        //   BoxShadow(
        //     color: Colors.black.withOpacity(.25),
        //     blurRadius: 10,
        //     offset: const Offset(0, 6),
        //   ),
        // ],
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: () => setState(() => _selectedCategory = label),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: _yellowIcon, size: 28),
            const SizedBox(height: 8),
            Text(
              label,
              style: TextStyle(color: _yellowIcon, fontWeight: FontWeight.w700),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterFab() {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.secondary,
        borderRadius: BorderRadius.circular(32),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: const [
          Icon(Icons.tune_rounded, color: Colors.white, size: 28),
          SizedBox(height: 12),
          Icon(Icons.filter_alt_rounded, color: Colors.white, size: 28),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) {
        final name =
            state is AuthAuthenticated
                ? (state.user.name.split(' ').isNotEmpty
                    ? state.user.name.split(' ')[0]
                    : state.user.name)
                : 'User';
        final avatarUrl =
            state is AuthAuthenticated ? state.user.photoUrl : null;
        return Stack(
          children: [
            // Olive blob background
            CustomPaint(
              painter: _HeaderBlobPainter(color: _olive),
              child: const SizedBox(height: 300, width: double.infinity),
            ),

            // Content
            Positioned.fill(
              child: Padding(
                padding: EdgeInsets.only(
                  left: 10,
                  right: AppDimensions.spacingL,
                  top: MediaQuery.of(context).padding.top,
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Texts
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Hey, $name! 👋",
                            style: Theme.of(
                              context,
                            ).textTheme.headlineSmall?.copyWith(
                              color: _textOnDark,
                              fontSize: 26,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          const SizedBox(height: 3),
                          Text(
                            "Discover amazing events near you",
                            style: Theme.of(
                              context,
                            ).textTheme.bodyMedium?.copyWith(
                              color: _textOnDark.withOpacity(.85),
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Round badge (star) on the top-right corner of the blob
                  ],
                ),
              ),
            ),
            Positioned(
              top: MediaQuery.of(context).padding.top - 30,
              right: -1,
              child: GestureDetector(
                onTap: _toggleMap,
                child: Container(
                  margin: const EdgeInsets.only(top: 8),
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: _surfaceDark,
                    shape: BoxShape.circle,
                  ),
                  child: CircleAvatar(
                    radius: 30,
                    backgroundColor: _pinkAccent,
                    child: const Icon(Icons.map, color: Colors.white),
                  ),
                ),
              ),
            ),
            Positioned(
              top: 105,
              child: SizedBox(
                height: 95,
                width: MediaQuery.of(context).size.width,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  padding: EdgeInsets.symmetric(
                    horizontal: AppDimensions.spacingL,
                  ),
                  separatorBuilder:
                      (_, __) => SizedBox(width: AppDimensions.spacingM),
                  itemCount: _categories.length,
                  itemBuilder: (_, i) {
                    final cat = _categories[i];
                    final isSelected = cat['name'] == _selectedCategory;
                    return _categoryPill(
                      label: cat['name'],
                      icon: cat['icon'],
                      selected: isSelected,
                    );
                  },
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

class HeaderCanopyClipper extends CustomClipper<Path> {
  HeaderCanopyClipper({
    this.cornerRadius = 24.0,
    this.concaveDepth = 38.0,
    this.notchRadius = 32.0,
    this.notchFromRight = 36.0,
    this.notchFromTop = 18.0,
    this.concaveInsetStart = 0.14, // % from left where the bottom wave begins
    this.concaveInsetEnd = 0.86, // % from left where the bottom wave ends
  });

  /// Outer corner radius
  final double cornerRadius;

  /// How far the bottom wave pulls UP at the middle
  final double concaveDepth;

  /// Circular notch (scoop) near the top-right corner
  final double notchRadius;
  final double notchFromRight;
  final double notchFromTop;

  /// Where the bottom wave begins/ends along width (0..1)
  final double concaveInsetStart;
  final double concaveInsetEnd;

  @override
  Path getClip(Size size) {
    final w = size.width;
    final h = size.height;
    final r = cornerRadius;

    // Bottom wave x positions
    final x1 = w * concaveInsetStart;
    final x2 = w * concaveInsetEnd;

    // Build the outer path with rounded corners and a concave bottom
    final base =
        Path()
          // Top-left corner
          ..moveTo(r, 0)
          ..quadraticBezierTo(0, 0, 0, r)
          // Left edge -> bottom-left corner
          ..lineTo(0, h - r)
          ..quadraticBezierTo(0, h, r, h)
          // Bottom straight segment (left -> start of wave)
          ..lineTo(x1, h)
          // Concave wave up to the middle (peak at h - concaveDepth) and down
          ..quadraticBezierTo(
            w * 0.50,
            h - concaveDepth, // control @ mid high
            x2,
            h, // end of wave
          )
          // Bottom straight segment (end of wave -> bottom-right corner)
          ..lineTo(w - r, h)
          ..quadraticBezierTo(w, h, w, h - r)
          // Right edge -> top-right corner
          ..lineTo(w, r)
          ..quadraticBezierTo(w, 0, w - r, 0)
          // Top edge back to start
          ..lineTo(r, 0)
          ..close();

    // Circular scoop (subtract from top-right)
    final notchCenter = Offset(w - notchFromRight, notchFromTop);
    final scoop =
        Path()
          ..addOval(Rect.fromCircle(center: notchCenter, radius: notchRadius));

    // Subtract the scoop from the base
    final result = Path.combine(PathOperation.difference, base, scoop);
    return result;
  }

  @override
  bool shouldReclip(covariant HeaderCanopyClipper oldClipper) {
    return cornerRadius != oldClipper.cornerRadius ||
        concaveDepth != oldClipper.concaveDepth ||
        notchRadius != oldClipper.notchRadius ||
        notchFromRight != oldClipper.notchFromRight ||
        notchFromTop != oldClipper.notchFromTop ||
        concaveInsetStart != oldClipper.concaveInsetStart ||
        concaveInsetEnd != oldClipper.concaveInsetEnd;
  }
}

class _HeaderBlobPainter extends CustomPainter {
  final Color color;
  _HeaderBlobPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint =
        Paint()
          ..color = Color(0xFF878961)
          ..style = PaintingStyle.fill;

    final path = Path();

    // 1. Start at left edge, 0.3 of height
    path.moveTo(0, size.height * 0.3);

    // 2. Go down to the bottom
    path.lineTo(0, size.height);

    // 3. Concave curve moving right along the bottom
    path.quadraticBezierTo(
      0,
      size.height - 60, // Concave dip upward
      60,
      size.height - 60,
    );
    path.lineTo(size.width - 60, size.height - 60);

    // 4. Another concave curve to bottom-right
    path.quadraticBezierTo(
      size.width,
      size.height - 60, // Concave dip upward
      size.width,
      size.height,
    );

    // 5. Move up the right edge
    path.moveTo(size.width, size.height);
    path.lineTo(size.width, 30);
    path.lineTo(size.width * 0.7, 30);

    // path.lineTo(size.width * 0.6, size.height);

    // // 6. Curve from top-right towards left (halfway point with rounded pocket)
    path.quadraticBezierTo(size.width * 0.65, 30, size.width * 0.65, 50);

    // Continue curving left to create the pocket area
    // path.quadraticBezierTo(
    //   size.width,
    //   size.height,
    //   size.width * 0.5,
    //   size.height * 0.25,
    // );
    // path.lineTo(size.width * 0.65, 75);

    // 7. Curve down and connect back to start
    path.quadraticBezierTo(
      size.width * 0.65,
      size.height * 0.3,
      size.width * 0.55,
      size.height * 0.3,
    );

    path.lineTo(30, size.height * 0.3);

    path.quadraticBezierTo(0, size.height * 0.3, 0, size.height * 0.38);
    path.lineTo(0, size.height * 0.3);

    path.close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
