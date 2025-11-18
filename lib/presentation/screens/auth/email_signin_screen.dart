// screens/auth/email_sign_in_screen.dart
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:innercircle/blocs/auth/auth_bloc.dart';
import 'package:innercircle/blocs/auth/auth_event.dart';
import 'package:innercircle/blocs/auth/auth_state.dart';
import 'package:innercircle/core/theme/app_colors.dart';
import 'package:innercircle/core/theme/app_dimensions.dart';
import 'package:innercircle/core/theme/app_text_styles.dart';
import 'package:innercircle/presentation/screens/auth/email_signup_screen.dart';

import '../../widgets/input/custom_text_feild.dart';
import '../../widgets/primary_button.dart';
import '../home/home_screen.dart';
import '../user/interest_screen.dart';
import 'forgot_password_screen.dart';

class EmailSignInScreen extends StatefulWidget {
  const EmailSignInScreen({super.key});

  @override
  State<EmailSignInScreen> createState() => _EmailSignInScreenState();
}

class _EmailSignInScreenState extends State<EmailSignInScreen>
    with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;

  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _fadeAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOut,
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
    );

    _animationController.forward();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  void _signIn() {
    if (_formKey.currentState!.validate()) {
      context.read<AuthBloc>().add(
        AuthSignInWithEmailRequested(
          email: _emailController.text.trim(),
          password: _passwordController.text,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: AppColors.darkprimaryGradient,
          image: DecorationImage(
            image: AssetImage('assets/images/ic_bg.png'),
            fit: BoxFit.cover,
          ),
        ),
        child: BlocConsumer<AuthBloc, AuthState>(
          listener: (context, state) {
            if (state is AuthError) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Row(
                    children: [
                      Icon(
                        state.message.contains('success') ||
                                state.message.contains('sent')
                            ? Icons.check_circle
                            : Icons.error_outline,
                        color: Colors.white,
                      ),
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
                child: FadeTransition(
                  opacity: _fadeAnimation,
                  child: SlideTransition(
                    position: _slideAnimation,
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(height: 20),

                          // Back Button
                          Container(
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: Colors.white.withOpacity(0.3),
                                width: 1,
                              ),
                            ),
                            child: IconButton(
                              icon: Icon(Icons.arrow_back, color: Colors.white),
                              onPressed: () => Navigator.pop(context),
                            ),
                          ),
                          SizedBox(height: 20),

                          // Title
                          Center(
                            child: Text(
                              'Welcome Back! 👋',
                              style: AppTextStyles.headline.copyWith(
                                color: AppColors.darkPrimary,
                                fontSize: 32,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          SizedBox(height: 4),

                          Center(
                            child: Text(
                              'Sign in to continue your journey',
                              style: AppTextStyles.body.copyWith(
                                color: AppColors.darkPrimary.withOpacity(0.6),
                                fontSize: 16,
                              ),
                            ),
                          ),
                          SizedBox(height: 30),

                          // Form Card
                          _buildFormCard(isLoading),

                          SizedBox(height: 20),

                          Divider(
                            color: AppColors.white.withOpacity(0.7),
                            thickness: 1,
                          ),

                          Center(
                            child: Text(
                              'or',
                              style: AppTextStyles.body.copyWith(
                                color: AppColors.white.withOpacity(0.6),
                                fontSize: 16,
                              ),
                            ),
                          ),
                          SizedBox(height: 20),

                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Image.asset(
                                'assets/images/Google (icon — Colour).png',
                                height: 25,
                              ),
                              SizedBox(width: 30),
                              Image.asset(
                                'assets/images/Apple (icon — Colour).png',
                                height: 30,
                              ),
                            ],
                          ),

                          SizedBox(height: 40),

                          PrimaryButton(
                            text: 'Log In',
                            icon: Icons.login_rounded,
                            backgroundColor: AppColors.darkPrimary,
                            onPressed: isLoading ? null : _signIn,
                            isLoading: isLoading,
                          ),

                          SizedBox(height: 20),

                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Text(
                                "Don’t have an account? ",
                                style: TextStyle(
                                  color: Colors.white70,
                                  fontSize: 16,
                                ),
                              ),
                              GestureDetector(
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => const EmailSignUpScreen(),
                                    ),
                                  );
                                  // navigate to register screen
                                  // Navigator.push(...)
                                },
                                child: const Text(
                                  "Register Now",
                                  style: TextStyle(
                                    color: Color(
                                      0xffF8C255,
                                    ), // same yellow as your UI
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ],
                          ),

                          // Forgot Password
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildFormCard(bool isLoading) {
    return Material(
      color: Colors.transparent,
      child: Column(
        children: [
          // Email Field
          CustomTextField(
            controller: _emailController,
            labelText: 'Email',
            hintText: 'Enter your email',
            keyboardType: TextInputType.emailAddress,
            prefixIcon: Icon(Icons.email_rounded, color: AppColors.darkPrimary),
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Please enter your email';
              }
              if (!value.contains('@')) {
                return 'Please enter a valid email';
              }
              return null;
            },
          ),
          SizedBox(height: AppDimensions.spacingL),

          // Password Field
          CustomTextField(
            controller: _passwordController,
            labelText: 'Password',
            hintText: 'Enter your password',
            obscureText: _obscurePassword,
            prefixIcon: Icon(Icons.lock_rounded, color: AppColors.darkPrimary),
            suffixIcon: IconButton(
              icon: Icon(
                _obscurePassword
                    ? Icons.visibility_off_rounded
                    : Icons.visibility_rounded,
                color: AppColors.darkPrimary,
              ),
              onPressed: () {
                setState(() => _obscurePassword = !_obscurePassword);
              },
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter your password';
              }
              return null;
            },
          ),
          SizedBox(height: 3),
          Align(
            alignment: Alignment.bottomRight,
            child: TextButton(
              onPressed:
                  isLoading
                      ? null
                      : () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const ForgotPasswordScreen(),
                          ),
                        );
                      },
              child: Text(
                'Forgot Password?',
                style: TextStyle(
                  color: AppColors.darkPrimary,
                  fontSize: 15,
                  fontWeight: FontWeight.w600,

                  decorationColor: Colors.white,
                ),
              ),
            ),
          ),

          // Sign In Button
        ],
      ),
    );
  }

  //TODO: Glassy effect - keep for reference
  // Widget _buildFormCard(bool isLoading) {
  //   return ClipRRect(
  //     borderRadius: BorderRadius.circular(16),
  //     child: BackdropFilter(
  //       filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
  //       child: Container(
  //         padding: EdgeInsets.all(AppDimensions.spacingXL),
  //         decoration: BoxDecoration(
  //           color: Colors.white.withOpacity(0.15),
  //           borderRadius: BorderRadius.circular(16),
  //           border: Border.all(
  //             color: Colors.white.withOpacity(0.3),
  //             width: 1.5,
  //           ),
  //         ),
  //         child: Material(
  //           color: Colors.transparent,
  //           child: Column(
  //             children: [
  //               // Email Field
  //               CustomTextField(
  //                 controller: _emailController,
  //                 labelText: 'Email',
  //                 hintText: 'Enter your email',
  //                 keyboardType: TextInputType.emailAddress,
  //                 prefixIcon: Icon(
  //                   Icons.email_rounded,
  //                   color: AppColors.primary,
  //                 ),
  //                 validator: (value) {
  //                   if (value == null || value.trim().isEmpty) {
  //                     return 'Please enter your email';
  //                   }
  //                   if (!value.contains('@')) {
  //                     return 'Please enter a valid email';
  //                   }
  //                   return null;
  //                 },
  //               ),
  //               SizedBox(height: AppDimensions.spacingL),

  //               // Password Field
  //               CustomTextField(
  //                 controller: _passwordController,
  //                 labelText: 'Password',
  //                 hintText: 'Enter your password',
  //                 obscureText: _obscurePassword,
  //                 prefixIcon: Icon(
  //                   Icons.lock_rounded,
  //                   color: AppColors.primary,
  //                 ),
  //                 suffixIcon: IconButton(
  //                   icon: Icon(
  //                     _obscurePassword
  //                         ? Icons.visibility_off_rounded
  //                         : Icons.visibility_rounded,
  //                     color: AppColors.grey600,
  //                   ),
  //                   onPressed: () {
  //                     setState(() => _obscurePassword = !_obscurePassword);
  //                   },
  //                 ),
  //                 validator: (value) {
  //                   if (value == null || value.isEmpty) {
  //                     return 'Please enter your password';
  //                   }
  //                   return null;
  //                 },
  //               ),
  //               SizedBox(height: AppDimensions.spacingXL),

  //               // Sign In Button
  //               PrimaryButton(
  //                 text: 'Sign In',
  //                 icon: Icons.login_rounded,
  //                 onPressed: isLoading ? null : _signIn,
  //                 isLoading: isLoading,
  //               ),
  //             ],
  //           ),
  //         ),
  //       ),
  //     ),
  //   );
  // }
}
