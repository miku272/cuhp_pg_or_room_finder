part of 'auth_bloc.dart';

@immutable
sealed class AuthState {}

final class AuthInitial extends AuthState {}

final class AuthLoading extends AuthState {}

final class AuthSuccess extends AuthState {
  final User user;

  AuthSuccess({required this.user});
}

final class AuthFailure extends AuthState {
  final int? status;
  final String message;

  AuthFailure({this.status, required this.message});
}
