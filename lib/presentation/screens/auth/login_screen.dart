// screens/auth/login_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:innercircle/blocs/auth/auth_bloc.dart';
import 'package:innercircle/blocs/auth/auth_event.dart';
import 'package:innercircle/blocs/auth/auth_state.dart';
import 'package:innercircle/core/theme/app_colors.dart';
import 'package:innercircle/core/theme/app_dimensions.dart';
import 'package:innercircle/core/theme/app_text_styles.dart';
import 'package:innercircle/presentation/screens/auth/email_signin_screen.dart';
import 'package:innercircle/presentation/screens/auth/email_signup_screen.dart';
import 'dart:ui';

import '../home/home_screen.dart';
import '../user/interest_screen.dart';
import '../../widgets/primary_button.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppColors.primaryGradientStart,
              AppColors.primaryGradientEnd,
              AppColors.accentGradientStart,
            ],
          ),
        ),
        child: BlocConsumer<AuthBloc, AuthState>(
          listener: (context, state) {
            if (state is AuthError) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Row(
                    children: [
                      Icon(Icons.info_outline, color: Colors.white),
                      SizedBox(width: 12),
                      Expanded(child: Text(state.message)),
                    ],
                  ),
                  backgroundColor:
                      state.message.contains('success') ||
                              state.message.contains('sent')
                          ? AppColors.success
                          : AppColors.error,
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              );
            } else if (state is AuthNeedsProfile) {
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(
                  builder:
                      (_) => InterestsScreen(
                        uid: state.uid,
                        name: state.name,
                        photoUrl: state.photoUrl,
                        lat: state.lat,
                        lng: state.lng,
                      ),
                ),
              );
            } else if (state is AuthAuthenticated) {
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(builder: (_) => const HomeScreen()),
              );
            }
          },
          builder: (context, state) {
            final isLoading = state is AuthLoading;

            return SafeArea(
              child: SingleChildScrollView(
                padding: EdgeInsets.all(AppDimensions.spacingXL),
                child: Column(
                  children: [
                    SizedBox(height: 60),

                    // Logo with animation
                    TweenAnimationBuilder<double>(
                      tween: Tween(begin: 0, end: 1),
                      duration: const Duration(milliseconds: 800),
                      curve: Curves.elasticOut,
                      builder: (context, value, child) {
                        return Transform.scale(
                          scale: value,
                          child: Container(
                            padding: EdgeInsets.all(32),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.white.withOpacity(0.2),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.2),
                                  blurRadius: 30,
                                  spreadRadius: 5,
                                ),
                              ],
                            ),
                            child: Icon(
                              Icons.people_alt_rounded,
                              size: 80,
                              color: Colors.white,
                            ),
                          ),
                        );
                      },
                    ),
                    SizedBox(height: 40),

                    // Title
                    Text(
                      'Welcome to Together',
                      style: AppTextStyles.headline.copyWith(
                        color: Colors.white,
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 12),

                    // Subtitle
                    Text(
                      'Connect, explore, and create\namazing memories together',
                      style: AppTextStyles.body.copyWith(
                        color: Colors.white.withOpacity(0.9),
                        fontSize: 16,
                        height: 1.5,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 60),

                    // Email Sign In Button
                    _buildGlassButton(
                      icon: Icons.email_rounded,
                      text: 'Sign in with Email',
                      onPressed:
                          isLoading
                              ? null
                              : () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => const EmailSignInScreen(),
                                  ),
                                );
                              },
                    ),
                    SizedBox(height: 16),

                    // Google Sign In Button
                    _buildGlassButton(
                      icon: Icons.g_mobiledata_rounded,
                      text: 'Continue with Google',
                      onPressed:
                          isLoading
                              ? null
                              : () {
                                context.read<AuthBloc>().add(
                                  AuthSignInWithGoogleRequested(),
                                );
                              },
                    ),
                    SizedBox(height: 40),

                    // Divider
                    Row(
                      children: [
                        Expanded(
                          child: Container(
                            height: 1,
                            color: Colors.white.withOpacity(0.3),
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 16),
                          child: Text(
                            'New here?',
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.9),
                              fontSize: 14,
                            ),
                          ),
                        ),
                        Expanded(
                          child: Container(
                            height: 1,
                            color: Colors.white.withOpacity(0.3),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 24),

                    // Sign Up Button
                    TextButton(
                      onPressed:
                          isLoading
                              ? null
                              : () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => const EmailSignUpScreen(),
                                  ),
                                );
                              },
                      child: Text(
                        'Create an account',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildGlassButton({
    required IconData icon,
    required String text,
    required VoidCallback? onPressed,
  }) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          width: double.infinity,
          height: 60,
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.2),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: Colors.white.withOpacity(0.3),
              width: 1.5,
            ),
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: onPressed,
              borderRadius: BorderRadius.circular(16),
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(icon, color: Colors.white, size: 24),
                    SizedBox(width: 12),
                    Text(
                      text,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
