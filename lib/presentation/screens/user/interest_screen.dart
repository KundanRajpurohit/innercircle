// screens/auth/interests_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:innercircle/blocs/auth/auth_bloc.dart';
import 'package:innercircle/blocs/auth/auth_event.dart';
import 'package:innercircle/blocs/auth/auth_state.dart';
import 'package:innercircle/core/theme/app_colors.dart';
import 'package:innercircle/core/theme/app_dimensions.dart';
import 'package:innercircle/core/theme/app_text_styles.dart';
import 'package:innercircle/presentation/screens/home/home_screen.dart';
import 'package:innercircle/presentation/widgets/interest_chip.dart';
import 'package:innercircle/presentation/widgets/primary_button.dart';

class InterestsScreen extends StatefulWidget {
  final String uid;
  final String name;
  final String? photoUrl;
  final double? lat;
  final double? lng;

  const InterestsScreen({
    Key? key,
    required this.uid,
    required this.name,
    this.photoUrl,
    this.lat,
    this.lng,
  }) : super(key: key);

  @override
  State<InterestsScreen> createState() => _InterestsScreenState();
}

class _InterestsScreenState extends State<InterestsScreen> {
  final List<String> _availableInterests = [
    'Movies',
    'Sports',
    'Food & Dining',
    'Study Groups',
    'Volunteering',
    'Carpooling',
    'Shopping',
    'Cultural Events',
    'Music',
    'Art & Crafts',
    'Gaming',
    'Fitness',
    'Travel',
    'Photography',
    'Reading',
    'Cooking',
  ];

  final Set<String> _selectedInterests = {};

  void _completeProfile(BuildContext context) {
    if (_selectedInterests.length < 3) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select at least 3 interests')),
      );
      return;
    }

    // Create a mock User object for the event
    final user = FirebaseAuth.instance.currentUser!;

    context.read<AuthBloc>().add(
      AuthCompleteProfileRequested(
        user: user,
        interests: _selectedInterests.toList(),
        lat: widget.lat,
        lng: widget.lng,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Select Interests')),
      body: BlocConsumer<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is AuthError) {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text(state.message)));
          } else if (state is AuthAuthenticated) {
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(builder: (_) => const HomeScreen()),
            );
          }
        },
        builder: (context, state) {
          final isLoading = state is AuthLoading;

          return SafeArea(
            child: Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    padding: AppDimensions.screenPadding,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'What are you interested in?',
                          style: AppTextStyles.headline.copyWith(fontSize: 28),
                        ),
                        SizedBox(height: AppDimensions.spacingS),
                        Text(
                          'Select at least 3 interests to help us find the best events for you',
                          style: AppTextStyles.body,
                        ),
                        SizedBox(height: AppDimensions.spacingXL),

                        // Interests Grid
                        Wrap(
                          spacing: AppDimensions.spacingM,
                          runSpacing: AppDimensions.spacingM,
                          children:
                              _availableInterests.map((interest) {
                                final isSelected = _selectedInterests.contains(
                                  interest,
                                );
                                return InterestChip(
                                  label: interest,
                                  isSelected: isSelected,
                                  onTap: () {
                                    setState(() {
                                      if (isSelected) {
                                        _selectedInterests.remove(interest);
                                      } else {
                                        _selectedInterests.add(interest);
                                      }
                                    });
                                  },
                                );
                              }).toList(),
                        ),
                      ],
                    ),
                  ),
                ),

                // Bottom Button
                Container(
                  padding: AppDimensions.screenPadding,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 10,
                        offset: const Offset(0, -5),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        '${_selectedInterests.length} interests selected',
                        style: AppTextStyles.body.copyWith(
                          color:
                              _selectedInterests.length >= 3
                                  ? AppColors.success
                                  : AppColors.textSecondary,
                        ),
                      ),
                      SizedBox(height: AppDimensions.spacingM),
                      PrimaryButton(
                        text: 'Continue',
                        onPressed:
                            _selectedInterests.length >= 3 && !isLoading
                                ? () => _completeProfile(context)
                                : null,
                        isLoading: isLoading,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
