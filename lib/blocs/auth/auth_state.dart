// blocs/auth/auth_state.dart
import 'package:equatable/equatable.dart';
import 'package:innercircle/data/models/app_user.dart';

abstract class AuthState extends Equatable {
  const AuthState();

  @override
  List<Object?> get props => [];
}

class AuthInitial extends AuthState {}

class AuthLoading extends AuthState {}

class AuthUnauthenticated extends AuthState {}

class AuthNeedsProfile extends AuthState {
  final String uid;
  final String name;
  final String? photoUrl;
  final double? lat;
  final double? lng;

  const AuthNeedsProfile({
    required this.uid,
    required this.name,
    this.photoUrl,
    this.lat,
    this.lng,
  });

  @override
  List<Object?> get props => [uid, name, photoUrl, lat, lng];
}

class AuthAuthenticated extends AuthState {
  final AppUser user;

  const AuthAuthenticated(this.user);

  @override
  List<Object?> get props => [user];
}

class AuthError extends AuthState {
  final String message;

  const AuthError(this.message);

  @override
  List<Object?> get props => [message];
}
