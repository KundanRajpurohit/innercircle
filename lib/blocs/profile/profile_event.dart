// blocs/profile/profile_event.dart
import 'package:equatable/equatable.dart';
import 'package:innercircle/data/models/app_user.dart';

abstract class ProfileEvent extends Equatable {
  const ProfileEvent();

  @override
  List<Object?> get props => [];
}

class ProfileLoadRequested extends ProfileEvent {
  final String uid;

  const ProfileLoadRequested(this.uid);

  @override
  List<Object?> get props => [uid];
}

class ProfileUpdateRequested extends ProfileEvent {
  final AppUser user;

  const ProfileUpdateRequested(this.user);

  @override
  List<Object?> get props => [user];
}
