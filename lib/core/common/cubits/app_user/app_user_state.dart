part of './app_user_cubit.dart';

@immutable
sealed class AppUserState {}

final class AppUserInitial extends AppUserState {}

final class AppUserLoggedin extends AppUserState {
  final User user;

  AppUserLoggedin({
    required this.user,
  });
}
