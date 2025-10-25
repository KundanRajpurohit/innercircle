// blocs/auth/auth_event.dart
import 'package:equatable/equatable.dart';
import 'package:firebase_auth/firebase_auth.dart';

abstract class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object?> get props => [];
}

// ============================================
// AUTH CHECK
// ============================================

class AuthCheckRequested extends AuthEvent {}

// ============================================
// GOOGLE SIGN IN
// ============================================

class AuthSignInWithGoogleRequested extends AuthEvent {}

// ============================================
// EMAIL/PASSWORD AUTHENTICATION
// ============================================

class AuthSignInWithEmailRequested extends AuthEvent {
  final String email;
  final String password;

  const AuthSignInWithEmailRequested({
    required this.email,
    required this.password,
  });

  @override
  List<Object?> get props => [email, password];
}

class AuthSignUpWithEmailRequested extends AuthEvent {
  final String email;
  final String password;
  final String name;

  const AuthSignUpWithEmailRequested({
    required this.email,
    required this.password,
    required this.name,
  });

  @override
  List<Object?> get props => [email, password, name];
}

class AuthPasswordResetRequested extends AuthEvent {
  final String email;

  const AuthPasswordResetRequested(this.email);

  @override
  List<Object?> get props => [email];
}

class AuthEmailVerificationRequested extends AuthEvent {}

// ============================================
// PROFILE COMPLETION
// ============================================

class AuthCompleteProfileRequested extends AuthEvent {
  final User user;
  final List<String> interests;
  final double? lat;
  final double? lng;

  const AuthCompleteProfileRequested({
    required this.user,
    required this.interests,
    this.lat,
    this.lng,
  });

  @override
  List<Object?> get props => [user, interests, lat, lng];
}

// ============================================
// SIGN OUT
// ============================================

class AuthSignOutRequested extends AuthEvent {}

// ============================================
// ACCOUNT MANAGEMENT (Optional - for future use)
// ============================================

class AuthUpdateEmailRequested extends AuthEvent {
  final String newEmail;
  final String password;

  const AuthUpdateEmailRequested({
    required this.newEmail,
    required this.password,
  });

  @override
  List<Object?> get props => [newEmail, password];
}

class AuthUpdatePasswordRequested extends AuthEvent {
  final String currentPassword;
  final String newPassword;

  const AuthUpdatePasswordRequested({
    required this.currentPassword,
    required this.newPassword,
  });

  @override
  List<Object?> get props => [currentPassword, newPassword];
}

class AuthDeleteAccountRequested extends AuthEvent {
  final String password;

  const AuthDeleteAccountRequested(this.password);

  @override
  List<Object?> get props => [password];
}
