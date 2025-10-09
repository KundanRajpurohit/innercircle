// screens/auth/login_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:innercircle/blocs/auth/auth_bloc.dart';
import 'package:innercircle/blocs/auth/auth_event.dart';
import 'package:innercircle/blocs/auth/auth_state.dart';
import 'package:innercircle/core/theme/app_colors.dart';
import 'package:innercircle/core/theme/app_dimensions.dart';
import 'package:innercircle/core/theme/app_text_styles.dart';
import 'package:innercircle/presentation/screens/home/home_screen.dart';
import 'package:innercircle/presentation/screens/user/interest_screen.dart';
import 'package:innercircle/presentation/widgets/primary_button.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocConsumer<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is AuthError) {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text(state.message)));
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
            child: Padding(
              padding: AppDimensions.screenPadding,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Spacer(),

                  // Logo
                  Icon(
                    Icons.people_alt_rounded,
                    size: 120,
                    color: AppColors.primary,
                  ),
                  SizedBox(height: AppDimensions.spacingL),

                  // Title
                  Text(
                    'Welcome to Together',
                    style: AppTextStyles.headline,
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: AppDimensions.spacingS),

                  // Subtitle
                  Text(
                    'Find events, make friends, and explore activities near you',
                    style: AppTextStyles.body,
                    textAlign: TextAlign.center,
                  ),

                  const Spacer(),

                  // Google Sign In Button
                  PrimaryButton(
                    text: 'Continue with Google',
                    onPressed:
                        isLoading
                            ? null
                            : () => context.read<AuthBloc>().add(
                              AuthSignInWithGoogleRequested(),
                            ),
                    isLoading: isLoading,
                    icon: Icons.g_mobiledata_rounded,
                  ),

                  SizedBox(height: AppDimensions.spacingL),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
