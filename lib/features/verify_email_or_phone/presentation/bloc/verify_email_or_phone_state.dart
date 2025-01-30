part of 'verify_email_or_phone_bloc.dart';

@immutable
sealed class VerifyEmailOrPhoneState {}

final class VerifyEmailOrPhoneInitialState extends VerifyEmailOrPhoneState {}

final class VerifyEmailOrPhoneLoadingState extends VerifyEmailOrPhoneState {}

final class VerifyEmailOrPhoneSentState extends VerifyEmailOrPhoneState {}

final class VerifyEmailOrPhoneFailureState extends VerifyEmailOrPhoneState {
  final int? status;
  final String message;

  VerifyEmailOrPhoneFailureState({this.status, required this.message});
}

final class VerifyEmailOtpSuccessState extends VerifyEmailOrPhoneState {
  final bool isVerified;

  VerifyEmailOtpSuccessState({required this.isVerified});
}

final class VerifyPhoneOtpSuccessState extends VerifyEmailOrPhoneState {
  final bool isVerified;

  VerifyPhoneOtpSuccessState({required this.isVerified});
}
