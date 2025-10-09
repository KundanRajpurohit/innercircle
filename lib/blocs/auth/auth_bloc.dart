// blocs/auth/auth_bloc.dart
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:innercircle/data/repositries/auth_repository.dart';
import 'package:innercircle/data/repositries/location_repo.dart';

import 'auth_event.dart';
import 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthService authService;
  final LocationService locationService;

  AuthBloc({required this.authService, required this.locationService})
    : super(AuthInitial()) {
    on<AuthCheckRequested>(_onAuthCheckRequested);
    on<AuthSignInWithGoogleRequested>(_onSignInWithGoogle);
    on<AuthCompleteProfileRequested>(_onCompleteProfile);
    on<AuthSignOutRequested>(_onSignOut);
  }

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

  Future<void> _onSignOut(
    AuthSignOutRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    await authService.signOut();
    emit(AuthUnauthenticated());
  }
}
