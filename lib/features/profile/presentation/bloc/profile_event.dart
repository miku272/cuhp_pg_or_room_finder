part of 'profile_bloc.dart';

@immutable
sealed class ProfileEvent {}

final class ProfileGetTotalPropertiesCount extends ProfileEvent {
  final String token;

  ProfileGetTotalPropertiesCount({required this.token});
}

final class ProfileGetPropertiesActiveAndInactiveCount extends ProfileEvent {
  final String token;

  ProfileGetPropertiesActiveAndInactiveCount({required this.token});
}

final class ProfileGetCurrentUser extends ProfileEvent {
  final String token;

  ProfileGetCurrentUser({required this.token});
}
