part of 'verify_email_or_phone_bloc.dart';

@immutable
sealed class VerifyEmailOrPhoneEvent {}

final class VerifyEmailOrPhoneResetEvent extends VerifyEmailOrPhoneEvent {}

final class SendEmailOtpEvent extends VerifyEmailOrPhoneEvent {
  final String id;
  final String token;

  SendEmailOtpEvent({required this.id, required this.token});
}

final class SendPhoneOtpEvent extends VerifyEmailOrPhoneEvent {
  final String id;
  final String token;

  SendPhoneOtpEvent({required this.id, required this.token});
}

final class VerifyEmailOtpEvent extends VerifyEmailOrPhoneEvent {
  final String id;
  final String token;
  final String otp;

  VerifyEmailOtpEvent(
      {required this.id, required this.token, required this.otp});
}

final class VerifyPhoneOtpEvent extends VerifyEmailOrPhoneEvent {
  final String id;
  final String token;
  final String otp;

  VerifyPhoneOtpEvent(
      {required this.id, required this.token, required this.otp});
}
