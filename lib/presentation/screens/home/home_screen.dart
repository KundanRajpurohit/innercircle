// screens/home/home_screen.dart
import 'package:animated_notch_bottom_bar/animated_notch_bottom_bar/animated_notch_bottom_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:innercircle/blocs/events/events_bloc.dart';
import 'package:innercircle/blocs/events/events_event.dart';
import 'package:innercircle/blocs/events/events_state.dart';

import 'package:innercircle/core/theme/app_colors.dart';

import '../event/create_event_screen.dart';
import 'feed_page.dart';
import '../event/my_events.dart';
import '../user/profile_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  int _currentIndex = 0;
  late final NotchBottomBarController _controller;
  late AnimationController _fabController;
  late AnimationController _navController;
  late Animation<double> _fabAnimation;

  @override
  void initState() {
    super.initState();
    _controller = NotchBottomBarController(index: 0);
    // Load events on app start
    context.read<EventsBloc>().add(EventsLoadRequested());

    // FAB animation controller
    _fabController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _fabAnimation = CurvedAnimation(
      parent: _fabController,
      curve: Curves.easeInOut,
    );

    // Nav items animation controller
    _navController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    // Create individual animations for each nav item

    _navController.forward();
    _fabController.forward();
  }

  @override
  void dispose() {
    _fabController.dispose();
    _navController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<EventsBloc, EventsState>(
      // buildWhen: (previous, current) {
      //   final shouldRebuild =
      //       current is EventsLoaded ||
      //       current is EventsError ||
      //       (current is EventsLoading && previous is! EventsLoaded) ||
      //       current is EventsInitial;
      //   return shouldRebuild;
      // },
      builder: (context, state) {
        return Scaffold(
          backgroundColor: AppColors.darkSurface,

          body: Stack(
            children: [
              // Page content
              IndexedStack(
                index: _currentIndex,
                children: const [
                  FeedPage(),
                  CreateEventScreen(),
                  MyEventsScreen(),
                  ProfileScreen(),
                ],
              ),

              // Floating gradient overlay for bottom nav
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: Container(height: 120, decoration: BoxDecoration()),
              ),
            ],
          ),
          extendBody: true,
          floatingActionButton:
              _currentIndex == 0 &&
                      state is EventsLoaded &&
                      state.events.isEmpty
                  ? ScaleTransition(
                    scale: _fabAnimation,
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        color: AppColors.darkPrimary,
                      ),
                      child: FloatingActionButton.extended(
                        onPressed: () {
                          setState(() => _currentIndex = 1);
                          _controller.jumpTo(1);
                        },
                        backgroundColor: Colors.transparent,
                        elevation: 0,
                        icon: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: AppColors.darkTextSecondary,
                              width: 1.5,
                            ),
                          ),
                          child: const Icon(
                            Icons.add_rounded,
                            color: AppColors.darkTextSecondary,
                          ),
                        ),
                        label: const Text(
                          'Create Event',
                          style: TextStyle(
                            color: AppColors.darkTextSecondary,
                            fontWeight: FontWeight.w600,
                            fontSize: 18,
                          ),
                        ),
                      ),
                    ),
                  )
                  : null,
          floatingActionButtonLocation:
              FloatingActionButtonLocation.centerFloat,
          bottomNavigationBar: _buildModernBottomNav(),
        );
      },
    );
  }

  Widget _buildModernBottomNav() {
    return Padding(
      padding: const EdgeInsets.only(left: 14, right: 14, bottom: 24),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(30),
        child: AnimatedNotchBottomBar(
          notchBottomBarController: _controller,
          color: const Color(0xFFDB7C84), // pink bar
          showLabel: false,
          showBlurBottomBar: false,
          shadowElevation: 8,
          kIconSize: 28,
          showShadow: true,
          notchColor: Color(0xFFDB7C84), // white active bubble
          removeMargins: true,
          kBottomRadius: 30,
          showTopRadius: true,
          showBottomRadius: true,
          topMargin: 14,
          circleMargin: 14,

          bottomBarItems: const [
            BottomBarItem(
              inActiveItem: Icon(Icons.home_rounded, size: 28),
              activeItem: Icon(Icons.home_rounded, size: 28),
              itemLabel: 'Home',
            ),
            BottomBarItem(
              inActiveItem: Icon(Icons.add_rounded, size: 28),
              activeItem: Icon(Icons.add_rounded, size: 28),
              itemLabel: 'Create',
            ),
            BottomBarItem(
              inActiveItem: Icon(Icons.calendar_month_rounded, size: 28),
              activeItem: Icon(Icons.calendar_month_rounded, size: 28),
              itemLabel: 'Events',
            ),
            BottomBarItem(
              inActiveItem: Icon(Icons.person_rounded, size: 28),
              activeItem: Icon(Icons.person_rounded, size: 28),
              itemLabel: 'Profile',
            ),
          ],

          onTap: (index) {
            setState(() => _currentIndex = index);
            _controller.jumpTo(index);
          },
        ),
      ),
    );
  }
}
