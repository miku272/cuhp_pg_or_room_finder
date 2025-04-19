part of 'app_socket_cubit.dart';

@immutable
sealed class AppSocketState {
  const AppSocketState();
}

final class AppSocketInitial extends AppSocketState {}

final class AppSocketConnecting extends AppSocketState {}

final class AppSocketConnected extends AppSocketState {}

final class AppSocketDisconnected extends AppSocketState {
  final String? reason;
  const AppSocketDisconnected({this.reason});
}

final class AppSocketError extends AppSocketState {
  final String message;
  const AppSocketError(this.message);
}
