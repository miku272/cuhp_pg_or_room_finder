part of 'splash_bloc.dart';

@immutable
sealed class SplashEvent {}

final class SplashGetCurrentUser extends SplashEvent {
  final String? id;
  final String? token;

  SplashGetCurrentUser({
    this.id,
    this.token,
  });
}
