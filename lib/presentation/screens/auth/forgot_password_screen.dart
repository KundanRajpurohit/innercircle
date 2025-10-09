// screens/auth/forgot_password_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:innercircle/blocs/auth/auth_bloc.dart';
import 'package:innercircle/blocs/auth/auth_event.dart';
import 'package:innercircle/blocs/auth/auth_state.dart';
import 'package:innercircle/core/theme/app_colors.dart';
import 'package:innercircle/core/theme/app_dimensions.dart';
import 'package:innercircle/core/theme/app_text_styles.dart';
import '../../widgets/input/custom_text_feild.dart';
import '../../widgets/primary_button.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({Key? key}) : super(key: key);

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen>
    with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();

  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

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

    _animationController.forward();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  void _resetPassword() {
    if (_formKey.currentState!.validate()) {
      context.read<AuthBloc>().add(
        AuthPasswordResetRequested(_emailController.text.trim()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        height: double.infinity,
        decoration: BoxDecoration(gradient: AppColors.primaryGradient),
        child: BlocConsumer<AuthBloc, AuthState>(
          listener: (context, state) {
            if (state is AuthError) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Row(
                    children: [
                      Icon(
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
                      state.message.contains('sent')
                          ? AppColors.success
                          : AppColors.error,
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  duration: Duration(seconds: 5),
                ),
              );

              if (state.message.contains('sent')) {
                Future.delayed(Duration(seconds: 2), () {
                  if (mounted) Navigator.pop(context);
                });
              }
            }
          },
          builder: (context, state) {
            final isLoading = state is AuthLoading;

            return SafeArea(
              child: SingleChildScrollView(
                padding: EdgeInsets.all(AppDimensions.spacingXL),
                child: FadeTransition(
                  opacity: _fadeAnimation,
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
                        SizedBox(height: 60),

                        // Icon
                        Center(
                          child: Container(
                            padding: EdgeInsets.all(24),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.2),
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: Colors.white.withOpacity(0.3),
                                width: 2,
                              ),
                            ),
                            child: Icon(
                              Icons.lock_reset_rounded,
                              size: 60,
                              color: Colors.white,
                            ),
                          ),
                        ),
                        SizedBox(height: 40),

                        // Title
                        Center(
                          child: Text(
                            'Forgot Password? 🔒',
                            style: AppTextStyles.headline.copyWith(
                              color: Colors.white,
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                        SizedBox(height: 16),

                        Center(
                          child: Text(
                            'Enter your email address and we\'ll send you a link to reset your password',
                            style: AppTextStyles.body.copyWith(
                              color: Colors.white.withOpacity(0.9),
                              fontSize: 15,
                              height: 1.5,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                        SizedBox(height: 60),

                        // Email Field Card
                        Container(
                          padding: EdgeInsets.all(AppDimensions.spacingXL),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(24),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.1),
                                blurRadius: 30,
                                offset: Offset(0, 10),
                              ),
                            ],
                          ),
                          child: Column(
                            children: [
                              CustomTextField(
                                controller: _emailController,
                                labelText: 'Email',
                                hintText: 'Enter your email',
                                keyboardType: TextInputType.emailAddress,
                                prefixIcon: Icon(
                                  Icons.email_rounded,
                                  color: AppColors.primary,
                                ),
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
                              SizedBox(height: AppDimensions.spacingXL),

                              // Reset Button
                              PrimaryButton(
                                text: 'Send Reset Link',
                                icon: Icons.send_rounded,
                                onPressed: isLoading ? null : _resetPassword,
                                isLoading: isLoading,
                              ),
                            ],
                          ),
                        ),
                      ],
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
}
