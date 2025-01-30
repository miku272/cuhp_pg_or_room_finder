import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/common/cubits/app_user/app_user_cubit.dart';

import '../../domain/usecases/send_email_otp.dart';
import '../../domain/usecases/verify_email_otp.dart';

part 'verify_email_or_phone_event.dart';
part 'verify_email_or_phone_state.dart';

class VerifyEmailOrPhoneBloc
    extends Bloc<VerifyEmailOrPhoneEvent, VerifyEmailOrPhoneState> {
  final SendEmailOtp _sendEmailOtp;
  // final SendPhoneOtp _sendPhoneOtp;
  final VerifyEmailOtp _verifyEmailOtp;
  // final VerifyPhoneOtp _verifyPhoneOtp;
  final AppUserCubit _appUserCubit;

  VerifyEmailOrPhoneBloc({
    required SendEmailOtp sendEmailOtp,
    required VerifyEmailOtp verifyEmailOtp,
    required AppUserCubit appUserCubit,
  })  : _sendEmailOtp = sendEmailOtp,
        _verifyEmailOtp = verifyEmailOtp,
        _appUserCubit = appUserCubit,
        super(VerifyEmailOrPhoneInitialState()) {
    on<VerifyEmailOrPhoneEvent>(
      (event, emit) => VerifyEmailOrPhoneLoadingState(),
    );

    on<SendEmailOtpEvent>(
      (event, emit) async {
        final res = await _sendEmailOtp(SendEmailOtpParams(
          id: event.id,
          token: event.token,
        ));

        res.fold((failure) {
          emit(VerifyEmailOrPhoneFailureState(
            status: failure.status,
            message: failure.message,
          ));
        }, (_) {
          emit(VerifyEmailOrPhoneSentState());
        });
      },
    );

    on<SendPhoneOtpEvent>(
      (event, emit) {},
    );

    on<VerifyEmailOtpEvent>(
      (event, emit) async {
        final res = await _verifyEmailOtp(VerifyEmailOtpParams(
          id: event.id,
          token: event.token,
          otp: event.otp,
        ));

        res.fold(
          (failure) => emit(VerifyEmailOrPhoneFailureState(
            message: failure.message,
          )),
          (isVerified) {
            final state = _appUserCubit.state;

            if (state is AppUserLoggedin) {
              _appUserCubit.setUser(state.user.copyWith(isEmailVerified: true));
            }

            emit(
              VerifyEmailOtpSuccessState(isVerified: isVerified),
            );
          },
        );
      },
    );

    on<VerifyPhoneOtpEvent>(
      (event, emit) {},
    );
  }
}
