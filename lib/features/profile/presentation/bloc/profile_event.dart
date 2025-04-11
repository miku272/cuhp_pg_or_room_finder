part of 'profile_bloc.dart';

@immutable
sealed class ProfileEvent {}

final class ProfileGetCurrentUser extends ProfileEvent {
  final String token;

  ProfileGetCurrentUser({required this.token});
}
