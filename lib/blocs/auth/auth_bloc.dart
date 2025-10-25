// blocs/auth/auth_bloc.dart
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/repositries/auth_repository.dart';
import '../../data/repositries/location_repo.dart';
import 'auth_event.dart';
import 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthService authService;
  final LocationService locationService;

  AuthBloc({required this.authService, required this.locationService})
    : super(AuthInitial()) {
    on<AuthCheckRequested>(_onAuthCheckRequested);
    on<AuthSignInWithGoogleRequested>(_onSignInWithGoogle);
    on<AuthSignInWithEmailRequested>(_onSignInWithEmail);
    on<AuthSignUpWithEmailRequested>(_onSignUpWithEmail);
    on<AuthPasswordResetRequested>(_onPasswordReset);
    on<AuthEmailVerificationRequested>(_onEmailVerification);
    on<AuthCompleteProfileRequested>(_onCompleteProfile);
    on<AuthSignOutRequested>(_onSignOut);
  }

  // ============================================
  // AUTH CHECK
  // ============================================

  Future<void> _onAuthCheckRequested(
    AuthCheckRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());

    try {
      final user = authService.currentUser;

      if (user == null) {
        emit(AuthUnauthenticated());
        return;
      }

      // Check if email is verified (for email/password users)
      if (user.providerData.any((info) => info.providerId == 'password')) {
        if (!user.emailVerified) {
          emit(
            const AuthError(
              'Please verify your email before continuing. Check your inbox.',
            ),
          );
          await authService.signOut();
          emit(AuthUnauthenticated());
          return;
        }
      }

      final userProfile = await authService.getUserProfile(user.uid);

      if (userProfile == null || userProfile.interests.isEmpty) {
        final position = await locationService.getCurrentLocation();
        emit(
          AuthNeedsProfile(
            uid: user.uid,
            name: user.displayName ?? 'User',
            photoUrl: user.photoURL,
            lat: position?.latitude,
            lng: position?.longitude,
          ),
        );
      } else {
        emit(AuthAuthenticated(userProfile));
      }
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }

  // ============================================
  // GOOGLE SIGN IN
  // ============================================

  Future<void> _onSignInWithGoogle(
    AuthSignInWithGoogleRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());

    try {
      final user = await authService.signInWithGoogle();

      if (user == null) {
        emit(AuthUnauthenticated());
        return;
      }

      final userProfile = await authService.getUserProfile(user.uid);

      if (userProfile == null || userProfile.interests.isEmpty) {
        final position = await locationService.getCurrentLocation();
        emit(
          AuthNeedsProfile(
            uid: user.uid,
            name: user.displayName ?? 'User',
            photoUrl: user.photoURL,
            lat: position?.latitude,
            lng: position?.longitude,
          ),
        );
      } else {
        emit(AuthAuthenticated(userProfile));
      }
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }

  // ============================================
  // EMAIL SIGN IN
  // ============================================

  Future<void> _onSignInWithEmail(
    AuthSignInWithEmailRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());

    try {
      final user = await authService.signInWithEmail(
        email: event.email,
        password: event.password,
      );

      if (user == null) {
        emit(const AuthError('Sign in failed'));
        return;
      }

      final userProfile = await authService.getUserProfile(user.uid);

      if (userProfile == null || userProfile.interests.isEmpty) {
        final position = await locationService.getCurrentLocation();
        emit(
          AuthNeedsProfile(
            uid: user.uid,
            name: user.displayName ?? event.email.split('@')[0],
            photoUrl: user.photoURL,
            lat: position?.latitude,
            lng: position?.longitude,
          ),
        );
      } else {
        emit(AuthAuthenticated(userProfile));
      }
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }

  // ============================================
  // EMAIL SIGN UP
  // ============================================

  Future<void> _onSignUpWithEmail(
    AuthSignUpWithEmailRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());

    try {
      final user = await authService.signUpWithEmail(
        email: event.email,
        password: event.password,
        name: event.name,
      );

      if (user == null) {
        emit(const AuthError('Sign up failed'));
        return;
      }

      // Show success message and sign out (user needs to verify email first)
      emit(
        const AuthError(
          'Account created successfully! 🎉\n\nPlease check your email to verify your account before signing in.',
        ),
      );

      // Sign out until email is verified
      await authService.signOut();
      emit(AuthUnauthenticated());
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }

  // ============================================
  // PASSWORD RESET
  // ============================================

  Future<void> _onPasswordReset(
    AuthPasswordResetRequested event,
    Emitter<AuthState> emit,
  ) async {
    final currentState = state;
    emit(AuthLoading());

    try {
      await authService.resetPassword(event.email);

      // Show success message
      emit(
        const AuthError(
          'Password reset email sent! 📧\n\nCheck your inbox and follow the instructions to reset your password.',
        ),
      );

      // Restore previous state
      if (currentState is AuthUnauthenticated) {
        emit(AuthUnauthenticated());
      } else if (currentState is AuthAuthenticated) {
        emit(currentState);
      }
    } catch (e) {
      emit(AuthError(e.toString()));

      // Restore previous state on error
      if (currentState is AuthUnauthenticated) {
        emit(AuthUnauthenticated());
      } else if (currentState is AuthAuthenticated) {
        emit(currentState);
      }
    }
  }

  // ============================================
  // EMAIL VERIFICATION
  // ============================================

  Future<void> _onEmailVerification(
    AuthEmailVerificationRequested event,
    Emitter<AuthState> emit,
  ) async {
    final currentState = state;
    emit(AuthLoading());

    try {
      await authService.sendEmailVerification();

      // Show success message
      emit(
        const AuthError(
          'Verification email sent! ✉️\n\nPlease check your inbox and verify your email address.',
        ),
      );

      // Restore previous state
      if (currentState is AuthUnauthenticated) {
        emit(AuthUnauthenticated());
      } else if (currentState is AuthAuthenticated) {
        emit(currentState);
      }
    } catch (e) {
      emit(AuthError(e.toString()));

      // Restore previous state on error
      if (currentState is AuthUnauthenticated) {
        emit(AuthUnauthenticated());
      } else if (currentState is AuthAuthenticated) {
        emit(currentState);
      }
    }
  }

  // ============================================
  // COMPLETE PROFILE
  // ============================================

  Future<void> _onCompleteProfile(
    AuthCompleteProfileRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());

    try {
      await authService.createUserProfile(
        uid: event.user.uid,
        name: event.user.displayName ?? 'User',
        photoUrl: event.user.photoURL,
        interests: event.interests,
        lat: event.lat,
        lng: event.lng,
      );

      final userProfile = await authService.getUserProfile(event.user.uid);

      if (userProfile != null) {
        emit(AuthAuthenticated(userProfile));
      } else {
        emit(const AuthError('Failed to create profile'));
      }
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }

  // ============================================
  // SIGN OUT
  // ============================================

  Future<void> _onSignOut(
    AuthSignOutRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());

    try {
      await authService.signOut();
      emit(AuthUnauthenticated());
    } catch (e) {
      emit(AuthError(e.toString()));
      // Still sign out on error
      emit(AuthUnauthenticated());
    }
  }
}
