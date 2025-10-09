// blocs/auth/auth_event.dart
import 'package:equatable/equatable.dart';
import 'package:firebase_auth/firebase_auth.dart';

abstract class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object?> get props => [];
}

class AuthCheckRequested extends AuthEvent {}

class AuthSignInWithGoogleRequested extends AuthEvent {}

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

class AuthSignOutRequested extends AuthEvent {}
