part of 'auth_bloc.dart';

@immutable
sealed class AuthEvent {}

final class AuthResetEvent extends AuthEvent {}

final class AuthSignup extends AuthEvent {
  final String name;
  final String email;
  final String password;

  AuthSignup({
    required this.name,
    required this.email,
    required this.password,
  });
}

final class AuthLogin extends AuthEvent {
  final String email;
  final String password;

  AuthLogin({
    required this.email,
    required this.password,
  });
}

final class AuthIsUserLoggedin extends AuthEvent {}

final class AuthGetCurrentUser extends AuthEvent {}
