// screens/home/home_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:innercircle/blocs/events/events_bloc.dart';
import 'package:innercircle/blocs/events/events_event.dart';
import 'package:innercircle/blocs/events/events_state.dart';
import 'package:innercircle/core/theme/app_colors.dart';
import 'package:innercircle/core/theme/app_dimensions.dart';
import 'dart:math' as math;

import '../event/create_event_screen.dart';
import 'feed_page.dart';
import '../event/my_events.dart';
import '../user/profile_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  int _currentIndex = 0;
  late AnimationController _fabController;
  late AnimationController _navController;
  late Animation<double> _fabAnimation;
  late List<Animation<double>> _navAnimations;

  @override
  void initState() {
    super.initState();

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
    _navAnimations = List.generate(
      4,
      (index) => Tween<double>(begin: 0, end: 1).animate(
        CurvedAnimation(
          parent: _navController,
          curve: Interval(
            index * 0.1,
            0.4 + index * 0.1,
            curve: Curves.elasticOut,
          ),
        ),
      ),
    );

    _navController.forward();
    _fabController.forward();
  }

  @override
  void dispose() {
    _fabController.dispose();
    _navController.dispose();
    super.dispose();
  }

  void _onTabTapped(int index) {
    if (index == _currentIndex) return;

    // Animate FAB on tab change
    _fabController.reverse().then((_) => _fabController.forward());

    // Only reload if switching TO feed page
    if (index == 0 && _currentIndex != 0) {
      final currentState = context.read<EventsBloc>().state;
      if (currentState is! EventsLoaded) {
        context.read<EventsBloc>().add(EventsLoadRequested());
      }
    }

    setState(() => _currentIndex = index);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
            child: Container(
              height: 120,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    AppColors.background.withOpacity(0.8),
                    AppColors.background,
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
      extendBody: true,
      floatingActionButton:
          _currentIndex == 0
              ? ScaleTransition(
                scale: _fabAnimation,
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    gradient: AppColors.primaryGradient,
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primary.withOpacity(0.4),
                        blurRadius: 20,
                        spreadRadius: 2,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: FloatingActionButton.extended(
                    onPressed: () {
                      setState(() => _currentIndex = 1);
                    },
                    backgroundColor: Colors.transparent,
                    elevation: 0,
                    icon: const Icon(Icons.add_rounded, color: Colors.white),
                    label: const Text(
                      'Create Event',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                        fontSize: 15,
                      ),
                    ),
                  ),
                ),
              )
              : null,
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      bottomNavigationBar: _buildModernBottomNav(),
    );
  }

  Widget _buildModernBottomNav() {
    return Container(
      margin: EdgeInsets.all(AppDimensions.spacingM),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 30,
            spreadRadius: 0,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border.all(
              color: AppColors.borderLight.withOpacity(0.5),
              width: 1,
            ),
          ),
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: AppDimensions.spacingM,
              vertical: AppDimensions.spacingS,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildNavItem(
                  index: 0,
                  icon: Icons.home_rounded,
                  label: 'Home',
                  animation: _navAnimations[0],
                ),
                _buildNavItem(
                  index: 1,
                  icon: Icons.add_circle_rounded,
                  label: 'Create',
                  animation: _navAnimations[1],
                ),
                _buildNavItem(
                  index: 2,
                  icon: Icons.event_rounded,
                  label: 'Events',
                  animation: _navAnimations[2],
                ),
                _buildNavItem(
                  index: 3,
                  icon: Icons.person_rounded,
                  label: 'Profile',
                  animation: _navAnimations[3],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem({
    required int index,
    required IconData icon,
    required String label,
    required Animation<double> animation,
  }) {
    final isSelected = _currentIndex == index;

    return ScaleTransition(
      scale: animation,
      child: GestureDetector(
        onTap: () => _onTabTapped(index),
        behavior: HitTestBehavior.opaque,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
          padding: EdgeInsets.symmetric(
            horizontal: isSelected ? 20 : 12,
            vertical: 12,
          ),
          decoration: BoxDecoration(
            gradient: isSelected ? AppColors.primaryGradient : null,
            borderRadius: BorderRadius.circular(16),
            boxShadow:
                isSelected
                    ? [
                      BoxShadow(
                        color: AppColors.primary.withOpacity(0.3),
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
              Icon(
                icon,
                color: isSelected ? Colors.white : AppColors.grey500,
                size: 24,
              ),
              if (isSelected) ...[
                SizedBox(width: AppDimensions.spacingS),
                Text(
                  label,
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
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
