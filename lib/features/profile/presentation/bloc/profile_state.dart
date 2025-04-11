part of 'profile_bloc.dart';

@immutable
sealed class ProfileState {
  final User? user;

  const ProfileState({this.user});
}

final class ProfileInitial extends ProfileState {
  const ProfileInitial({super.user});
}

final class ProfileLoading extends ProfileState {
  const ProfileLoading({super.user});
}

final class ProfileSuccess extends ProfileState {
  const ProfileSuccess({required super.user});
}

final class ProfileFailure extends ProfileState {
  final int? status;
  final String message;

  const ProfileFailure({
    this.status,
    required this.message,
    super.user,
  });
}