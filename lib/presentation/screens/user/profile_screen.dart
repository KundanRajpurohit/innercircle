// screens/profile/profile_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:innercircle/blocs/auth/auth_bloc.dart';
import 'package:innercircle/blocs/auth/auth_event.dart';
import 'package:innercircle/blocs/auth/auth_state.dart';
import 'package:innercircle/blocs/profile/profile_bloc.dart';
import 'package:innercircle/blocs/profile/profile_event.dart';
import 'package:innercircle/blocs/profile/profile_state.dart';
import 'package:innercircle/core/theme/app_colors.dart';
import 'package:innercircle/core/theme/app_dimensions.dart';
import 'package:innercircle/core/theme/app_text_styles.dart';
import 'package:innercircle/presentation/widgets/input/custom_text_feild.dart';
import 'package:innercircle/presentation/widgets/interest_chip.dart';
import 'package:innercircle/presentation/widgets/primary_button.dart';
import 'package:innercircle/presentation/widgets/secondary_button.dart';

import '../auth/login_screen.dart';

// screens/profile/profile_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'dart:ui';

import '../../widgets/input/custom_text_feild.dart';
import '../../widgets/interest_chip.dart';
import '../../widgets/primary_button.dart';
import '../../widgets/secondary_button.dart';
import '../auth/login_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen>
    with TickerProviderStateMixin {
  bool _isEditing = false;
  late TextEditingController _nameController;
  late TextEditingController _bioController;
  late Set<String> _selectedInterests;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  final List<Map<String, dynamic>> _availableInterests = [
    {'name': 'Movies', 'icon': '🎬', 'color': AppColors.movieColor},
    {'name': 'Sports', 'icon': '⚽', 'color': AppColors.sportsColor},
    {'name': 'Food & Dining', 'icon': '🍕', 'color': AppColors.foodColor},
    {'name': 'Study Groups', 'icon': '📚', 'color': AppColors.studyColor},
    {'name': 'Volunteering', 'icon': '❤️', 'color': AppColors.volunteerColor},
    {'name': 'Carpooling', 'icon': '🚗', 'color': AppColors.carpoolColor},
    {'name': 'Shopping', 'icon': '🛍️', 'color': AppColors.shoppingColor},
    {'name': 'Cultural Events', 'icon': '🎉', 'color': AppColors.culturalColor},
    {'name': 'Music', 'icon': '🎵', 'color': AppColors.primary},
    {'name': 'Art & Crafts', 'icon': '🎨', 'color': AppColors.accent},
    {'name': 'Gaming', 'icon': '🎮', 'color': AppColors.info},
    {'name': 'Fitness', 'icon': '💪', 'color': AppColors.success},
    {'name': 'Travel', 'icon': '✈️', 'color': AppColors.warning},
    {'name': 'Photography', 'icon': '📸', 'color': AppColors.movieColor},
    {'name': 'Reading', 'icon': '📖', 'color': AppColors.studyColor},
    {'name': 'Cooking', 'icon': '👨‍🍳', 'color': AppColors.foodColor},
  ];

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _bioController = TextEditingController();
    _selectedInterests = {};

    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _fadeAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOut,
    );

    _scaleAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.elasticOut,
    );

    _animationController.forward();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _bioController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  void _startEditing(String name, String? bio, List<String> interests) {
    setState(() {
      _isEditing = true;
      _nameController.text = name;
      _bioController.text = bio ?? '';
      _selectedInterests = interests.toSet();
    });
  }

  void _cancelEditing() {
    setState(() => _isEditing = false);
  }

  void _saveProfile(BuildContext context) {
    final authState = context.read<AuthBloc>().state;
    if (authState is! AuthAuthenticated) return;

    final updatedUser = authState.user.copyWith(
      name: _nameController.text.trim(),
      bio:
          _bioController.text.trim().isEmpty
              ? null
              : _bioController.text.trim(),
      interests: _selectedInterests.toList(),
    );

    context.read<ProfileBloc>().add(ProfileUpdateRequested(updatedUser));
  }

  void _signOut(BuildContext context) {
    showDialog(
      context: context,
      builder:
          (context) => BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
            child: AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              title: Row(
                children: [
                  Icon(Icons.logout_rounded, color: AppColors.error),
                  SizedBox(width: AppDimensions.spacingM),
                  Text('Sign Out', style: AppTextStyles.subheading),
                ],
              ),
              content: Text(
                'Are you sure you want to sign out?',
                style: AppTextStyles.body,
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text(
                    'Cancel',
                    style: TextStyle(color: AppColors.textSecondary),
                  ),
                ),
                Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        AppColors.error,
                        AppColors.error.withOpacity(0.8),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: TextButton(
                    onPressed: () {
                      context.read<AuthBloc>().add(AuthSignOutRequested());
                      Navigator.pop(context);
                    },
                    child: Text(
                      'Sign Out',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ),
              ],
            ),
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
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
        child: BlocListener<ProfileBloc, ProfileState>(
          listener: (context, state) {
            if (state is ProfileUpdated) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Row(
                    children: [
                      Icon(Icons.check_circle, color: Colors.white),
                      SizedBox(width: AppDimensions.spacingM),
                      Text('Profile updated successfully!'),
                    ],
                  ),
                  backgroundColor: AppColors.success,
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              );
              setState(() => _isEditing = false);
              context.read<AuthBloc>().add(AuthCheckRequested());
            } else if (state is ProfileError) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Row(
                    children: [
                      Icon(Icons.error, color: Colors.white),
                      SizedBox(width: AppDimensions.spacingM),
                      Expanded(child: Text(state.message)),
                    ],
                  ),
                  backgroundColor: AppColors.error,
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              );
            }
          },
          child: BlocBuilder<AuthBloc, AuthState>(
            builder: (context, authState) {
              if (authState is AuthLoading) {
                return const Center(child: CircularProgressIndicator());
              }

              if (authState is AuthUnauthenticated) {
                Future.microtask(() {
                  Navigator.of(context).pushReplacement(
                    MaterialPageRoute(builder: (_) => const LoginScreen()),
                  );
                });
                return const SizedBox.shrink();
              }

              if (authState is! AuthAuthenticated) {
                return const Center(child: CircularProgressIndicator());
              }

              final user = authState.user;

              return CustomScrollView(
                slivers: [
                  // Custom App Bar with Profile Header
                  SliverAppBar(
                    expandedHeight: 280,
                    floating: false,
                    pinned: true,
                    backgroundColor: Colors.transparent,
                    actions: [
                      if (!_isEditing)
                        Container(
                          margin: EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            gradient: AppColors.primaryGradient,
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.primary.withOpacity(0.3),
                                blurRadius: 10,
                                offset: Offset(0, 4),
                              ),
                            ],
                          ),
                          child: IconButton(
                            icon: Icon(Icons.edit_rounded, color: Colors.white),
                            onPressed: () {
                              _startEditing(
                                user.name,
                                user.bio,
                                user.interests,
                              );
                            },
                          ),
                        ),
                    ],
                    flexibleSpace: FlexibleSpaceBar(
                      background: FadeTransition(
                        opacity: _fadeAnimation,
                        child: _buildProfileHeader(user),
                      ),
                    ),
                  ),

                  // Content
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: EdgeInsets.all(AppDimensions.spacingM),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Bio Section
                          _buildBioSection(user),
                          SizedBox(height: AppDimensions.spacingXL),

                          // Interests Section
                          _buildInterestsSection(user),
                          SizedBox(height: AppDimensions.spacingXL),

                          // Stats Section (only when not editing)
                          if (!_isEditing) _buildStatsCard(user.uid),
                          if (!_isEditing)
                            SizedBox(height: AppDimensions.spacingXL),

                          // Action Buttons
                          _buildActionButtons(),
                          SizedBox(height: 100), // Bottom padding for nav
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
    );
  }

  Widget _buildProfileHeader(user) {
    return Container(
      decoration: BoxDecoration(gradient: AppColors.primaryGradient),
      child: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            ScaleTransition(
              scale: _scaleAnimation,
              child: Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      blurRadius: 20,
                      spreadRadius: 5,
                    ),
                  ],
                ),
                child: Stack(
                  children: [
                    CircleAvatar(
                      radius: 60,
                      backgroundColor: Colors.white,
                      child: CircleAvatar(
                        radius: 56,
                        backgroundColor: AppColors.primary,
                        backgroundImage:
                            user.photoUrl != null
                                ? CachedNetworkImageProvider(user.photoUrl!)
                                : null,
                        child:
                            user.photoUrl == null
                                ? Text(
                                  user.name[0].toUpperCase(),
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 48,
                                    fontWeight: FontWeight.w600,
                                  ),
                                )
                                : null,
                      ),
                    ),
                    if (_isEditing)
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: Container(
                          padding: EdgeInsets.all(AppDimensions.spacingS),
                          decoration: BoxDecoration(
                            gradient: AppColors.accentGradient,
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white, width: 3),
                          ),
                          child: Icon(
                            Icons.camera_alt_rounded,
                            color: Colors.white,
                            size: 20,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
            SizedBox(height: AppDimensions.spacingL),
            if (!_isEditing) ...[
              Text(
                user.name,
                style: AppTextStyles.headline.copyWith(
                  color: Colors.white,
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: AppDimensions.spacingS),
            ],
            SizedBox(height: AppDimensions.spacingM),
          ],
        ),
      ),
    );
  }

  Widget _buildBioSection(user) {
    return Container(
      padding: EdgeInsets.all(AppDimensions.spacingL),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 20,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.person_rounded, color: AppColors.primary, size: 24),
              SizedBox(width: AppDimensions.spacingS),
              Text(
                _isEditing ? 'Edit Profile' : 'About Me',
                style: AppTextStyles.subheading.copyWith(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          SizedBox(height: AppDimensions.spacingM),
          if (_isEditing) ...[
            CustomTextField(
              controller: _nameController,
              labelText: 'Name',
              hintText: 'Enter your name',
              prefixIcon: Icon(Icons.badge_rounded, color: AppColors.primary),
            ),
            SizedBox(height: AppDimensions.spacingM),
            CustomTextField(
              controller: _bioController,
              labelText: 'Bio',
              hintText: 'Tell us about yourself...',
              maxLines: 4,
              prefixIcon: Icon(
                Icons.description_rounded,
                color: AppColors.primary,
              ),
            ),
          ] else ...[
            if (user.bio != null && user.bio!.isNotEmpty)
              Text(
                user.bio!,
                style: AppTextStyles.body.copyWith(fontSize: 15, height: 1.5),
              )
            else
              Text(
                'No bio yet. Tap edit to add one!',
                style: AppTextStyles.body.copyWith(
                  color: AppColors.textSecondary,
                  fontStyle: FontStyle.italic,
                ),
              ),
          ],
        ],
      ),
    );
  }

  Widget _buildInterestsSection(user) {
    return Container(
      padding: EdgeInsets.all(AppDimensions.spacingL),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.primary.withOpacity(0.05),
            AppColors.accent.withOpacity(0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.primary.withOpacity(0.2), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.favorite_rounded, color: AppColors.accent, size: 24),
              SizedBox(width: AppDimensions.spacingS),
              Text(
                'Interests',
                style: AppTextStyles.subheading.copyWith(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          SizedBox(height: AppDimensions.spacingM),
          if (_isEditing)
            Wrap(
              spacing: AppDimensions.spacingS,
              runSpacing: AppDimensions.spacingS,
              children:
                  _availableInterests.map<Widget>((interest) {
                    // Add <Widget>
                    final isSelected = _selectedInterests.contains(
                      interest['name'],
                    );
                    return InterestChip(
                      label: interest['name'] as String, // Cast to String
                      isSelected: isSelected,
                      selectedColor:
                          interest['color'] as Color, // Cast to Color
                      onTap: () {
                        setState(() {
                          if (isSelected) {
                            _selectedInterests.remove(interest['name']);
                          } else {
                            _selectedInterests.add(interest['name'] as String);
                          }
                        });
                      },
                    );
                  }).toList(),
            )
          else
            Wrap(
              spacing: AppDimensions.spacingS,
              runSpacing: AppDimensions.spacingS,
              children:
                  user.interests.map<Widget>((interest) {
                    // Add <Widget>
                    final interestData = _availableInterests.firstWhere(
                      (i) => i['name'] == interest,
                      orElse:
                          () => {
                            'name': interest,
                            'icon': '⭐',
                            'color': AppColors.primary,
                          },
                    );
                    return InterestChip(
                      label: interest as String, // Cast to String
                      isSelected: true,
                      selectedColor:
                          interestData['color'] as Color, // Cast to Color
                    );
                  }).toList(),
            ),
        ],
      ),
    );
  }

  Widget _buildStatsCard(String userId) {
    return Container(
      padding: EdgeInsets.all(AppDimensions.spacingL),
      decoration: BoxDecoration(
        gradient: AppColors.primaryGradient,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.3),
            blurRadius: 20,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            '📊 Your Activity',
            style: AppTextStyles.subheading.copyWith(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: AppDimensions.spacingL),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildStatItem(
                icon: Icons.star_rounded,
                label: 'Hosted',
                value: '0',
              ),
              Container(
                width: 1,
                height: 50,
                color: Colors.white.withOpacity(0.3),
              ),
              _buildStatItem(
                icon: Icons.event_rounded,
                label: 'Joined',
                value: '0',
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Column(
      children: [
        Container(
          padding: EdgeInsets.all(AppDimensions.spacingM),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.2),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, size: 32, color: Colors.white),
        ),
        SizedBox(height: AppDimensions.spacingS),
        Text(
          value,
          style: AppTextStyles.headline.copyWith(
            fontSize: 28,
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: AppTextStyles.caption.copyWith(
            color: Colors.white.withOpacity(0.9),
            fontSize: 13,
          ),
        ),
      ],
    );
  }

  Widget _buildActionButtons() {
    if (_isEditing) {
      return BlocBuilder<ProfileBloc, ProfileState>(
        builder: (context, state) {
          final isLoading = state is ProfileLoading;
          return Column(
            children: [
              PrimaryButton(
                text: 'Save Changes',
                onPressed: isLoading ? null : () => _saveProfile(context),
                isLoading: isLoading,
                icon: Icons.check_circle_rounded,
              ),
              SizedBox(height: AppDimensions.spacingM),
              SecondaryButton(
                text: 'Cancel',
                onPressed: _cancelEditing,
                icon: Icons.close_rounded,
              ),
            ],
          );
        },
      );
    } else {
      return SecondaryButton(
        text: 'Sign Out',
        onPressed: () => _signOut(context),
        icon: Icons.logout_rounded,
        borderColor: AppColors.error,
        textColor: AppColors.error,
      );
    }
  }
}
