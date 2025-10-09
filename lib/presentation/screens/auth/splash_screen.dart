// screens/splash/splash_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:innercircle/blocs/auth/auth_bloc.dart';
import 'package:innercircle/blocs/auth/auth_state.dart';
import 'package:innercircle/core/theme/app_colors.dart';
import 'package:innercircle/core/theme/app_text_styles.dart';
import 'dart:math' as math;

import '../home/home_screen.dart';
import '../user/interest_screen.dart';
import '../auth/login_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _liquidController;
  late AnimationController _fadeController;
  late AnimationController _scaleController;
  late AnimationController _rotateController;

  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;
  late Animation<double> _rotateAnimation;

  @override
  void initState() {
    super.initState();

    // Liquid wave animation
    _liquidController = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    )..repeat();

    // Fade in animation
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    // Scale animation
    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );

    // Rotate animation
    _rotateController = AnimationController(
      duration: const Duration(seconds: 20),
      vsync: this,
    )..repeat();

    _fadeAnimation = CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeIn,
    );

    _scaleAnimation = CurvedAnimation(
      parent: _scaleController,
      curve: Curves.elasticOut,
    );

    _rotateAnimation = CurvedAnimation(
      parent: _rotateController,
      curve: Curves.linear,
    );

    // Start animations
    _fadeController.forward();
    _scaleController.forward();
  }

  @override
  void dispose() {
    _liquidController.dispose();
    _fadeController.dispose();
    _scaleController.dispose();
    _rotateController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is AuthUnauthenticated) {
          Navigator.of(context).pushReplacement(
            PageRouteBuilder(
              pageBuilder:
                  (context, animation, secondaryAnimation) =>
                      const LoginScreen(),
              transitionsBuilder: (
                context,
                animation,
                secondaryAnimation,
                child,
              ) {
                const begin = Offset(1.0, 0.0);
                const end = Offset.zero;
                const curve = Curves.easeInOutCubic;
                var tween = Tween(
                  begin: begin,
                  end: end,
                ).chain(CurveTween(curve: curve));
                var offsetAnimation = animation.drive(tween);
                return SlideTransition(position: offsetAnimation, child: child);
              },
              transitionDuration: const Duration(milliseconds: 800),
            ),
          );
        } else if (state is AuthNeedsProfile) {
          Navigator.of(context).pushReplacement(
            PageRouteBuilder(
              pageBuilder:
                  (context, animation, secondaryAnimation) => InterestsScreen(
                    uid: state.uid,
                    name: state.name,
                    photoUrl: state.photoUrl,
                    lat: state.lat,
                    lng: state.lng,
                  ),
              transitionsBuilder: (
                context,
                animation,
                secondaryAnimation,
                child,
              ) {
                return FadeTransition(opacity: animation, child: child);
              },
              transitionDuration: const Duration(milliseconds: 800),
            ),
          );
        } else if (state is AuthAuthenticated) {
          Navigator.of(context).pushReplacement(
            PageRouteBuilder(
              pageBuilder:
                  (context, animation, secondaryAnimation) =>
                      const HomeScreen(),
              transitionsBuilder: (
                context,
                animation,
                secondaryAnimation,
                child,
              ) {
                return FadeTransition(opacity: animation, child: child);
              },
              transitionDuration: const Duration(milliseconds: 800),
            ),
          );
        }
      },
      child: Scaffold(
        body: Stack(
          children: [
            // Animated Gradient Background
            AnimatedBuilder(
              animation: _liquidController,
              builder: (context, child) {
                return Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        AppColors.primaryGradientStart,
                        AppColors.primaryGradientEnd,
                        AppColors.accentGradientStart,
                      ],
                      stops: [
                        0.0,
                        0.5 +
                            math.sin(_liquidController.value * 2 * math.pi) *
                                0.2,
                        1.0,
                      ],
                    ),
                  ),
                );
              },
            ),

            // Liquid Blobs
            ...List.generate(5, (index) {
              return AnimatedBuilder(
                animation: _liquidController,
                builder: (context, child) {
                  final offset = (index * 0.2) + _liquidController.value;
                  return Positioned(
                    top:
                        MediaQuery.of(context).size.height *
                        (0.1 + math.sin(offset * 2 * math.pi) * 0.3),
                    left:
                        MediaQuery.of(context).size.width *
                        (0.1 + math.cos(offset * 2 * math.pi) * 0.3),
                    child: Container(
                      width: 150 + (index * 30.0),
                      height: 150 + (index * 30.0),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: RadialGradient(
                          colors: [
                            Colors.white.withOpacity(0.1),
                            Colors.white.withOpacity(0.0),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              );
            }),

            // Rotating circles background
            Positioned.fill(
              child: AnimatedBuilder(
                animation: _rotateAnimation,
                builder: (context, child) {
                  return Transform.rotate(
                    angle: _rotateAnimation.value * 2 * math.pi,
                    child: CustomPaint(painter: CirclesPainter()),
                  );
                },
              ),
            ),

            // Main Content
            Center(
              child: FadeTransition(
                opacity: _fadeAnimation,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Animated Logo
                    ScaleTransition(
                      scale: _scaleAnimation,
                      child: Container(
                        padding: const EdgeInsets.all(32),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white.withOpacity(0.2),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 40,
                              spreadRadius: 10,
                            ),
                          ],
                        ),
                        child: Container(
                          padding: const EdgeInsets.all(24),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [
                                Colors.white.withOpacity(0.9),
                                Colors.white.withOpacity(0.7),
                              ],
                            ),
                          ),
                          child: const Icon(
                            Icons.people_alt_rounded,
                            size: 80,
                            color: AppColors.primary,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 48),

                    // Animated Title
                    ScaleTransition(
                      scale: _scaleAnimation,
                      child: DefaultTextStyle(
                        style: AppTextStyles.headline.copyWith(
                          color: Colors.white,
                          fontSize: 48,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 2,
                          shadows: [
                            Shadow(
                              color: Colors.black.withOpacity(0.3),
                              offset: const Offset(0, 4),
                              blurRadius: 20,
                            ),
                          ],
                        ),
                        child: AnimatedTextKit(
                          animatedTexts: [
                            TypewriterAnimatedText(
                              'Together',
                              speed: const Duration(milliseconds: 150),
                            ),
                          ],
                          isRepeatingAnimation: false,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Subtitle with animation
                    FadeTransition(
                      opacity: _fadeAnimation,
                      child: DefaultTextStyle(
                        style: AppTextStyles.body.copyWith(
                          color: Colors.white.withOpacity(0.95),
                          fontSize: 16,
                          letterSpacing: 1.5,
                          shadows: [
                            Shadow(
                              color: Colors.black.withOpacity(0.2),
                              offset: const Offset(0, 2),
                              blurRadius: 10,
                            ),
                          ],
                        ),
                        child: AnimatedTextKit(
                          animatedTexts: [
                            FadeAnimatedText(
                              'Connect. Explore. Together.',
                              duration: const Duration(milliseconds: 2000),
                            ),
                          ],
                          pause: const Duration(milliseconds: 1000),
                          repeatForever: true,
                        ),
                      ),
                    ),
                    const SizedBox(height: 60),

                    // Custom Liquid Loading Indicator
                    SizedBox(
                      width: 60,
                      height: 60,
                      child: AnimatedBuilder(
                        animation: _liquidController,
                        builder: (context, child) {
                          return CustomPaint(
                            painter: LiquidLoadingPainter(
                              progress: _liquidController.value,
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Bottom gradient overlay
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                height: 150,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Colors.transparent, Colors.black.withOpacity(0.1)],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Custom Painter for rotating circles
class CirclesPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint =
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1
          ..color = Colors.white.withOpacity(0.1);

    final center = Offset(size.width / 2, size.height / 2);

    for (int i = 1; i <= 5; i++) {
      canvas.drawCircle(center, i * 80.0, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// Custom Painter for liquid loading animation
class LiquidLoadingPainter extends CustomPainter {
  final double progress;

  LiquidLoadingPainter({required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    final paint =
        Paint()
          ..color = Colors.white
          ..style = PaintingStyle.fill;

    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;

    // Draw multiple liquid drops
    for (int i = 0; i < 3; i++) {
      final offset = (progress + i * 0.33) % 1.0;
      final scale = (1 - offset) * radius;
      final opacity = 1 - offset;

      paint.color = Colors.white.withOpacity(opacity * 0.6);
      canvas.drawCircle(center, scale, paint);
    }

    // Draw center dot
    paint.color = Colors.white;
    canvas.drawCircle(center, 8, paint);
  }

  @override
  bool shouldRepaint(LiquidLoadingPainter oldDelegate) =>
      oldDelegate.progress != progress;
}
