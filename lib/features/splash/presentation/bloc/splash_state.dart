part of 'splash_bloc.dart';

@immutable
sealed class SplashState {}

final class SplashLoading extends SplashState {}

final class SplashInitial extends SplashState {}

final class SplashSuccess extends SplashState {
  final User? user;

  SplashSuccess({this.user});
}

final class SplashFailure extends SplashState {
  final int? status;
  final String message;

  SplashFailure({this.status, required this.message});
}
