import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pinput/pinput.dart';
import 'package:timer_count_down/timer_controller.dart';
import 'package:timer_count_down/timer_count_down.dart';

import '../../../../core/common/cubits/app_user/app_user_cubit.dart';

import '../bloc/verify_email_or_phone_bloc.dart';

class VerifyEmailOrPhoneScreen extends StatefulWidget {
  final String verificationType;

  const VerifyEmailOrPhoneScreen({
    required this.verificationType,
    super.key,
  });

  @override
  State<VerifyEmailOrPhoneScreen> createState() =>
      _VerifyEmailOrPhoneScreenState();
}

class _VerifyEmailOrPhoneScreenState extends State<VerifyEmailOrPhoneScreen> {
  final _pinController = TextEditingController();
  final _countdownController = CountdownController();

  String? id;
  String? token;

  @override
  void initState() {
    final user = context.read<AppUserCubit>().state;

    if (user is AppUserLoggedin) {
      id = user.user.id;
      token = user.user.jwtToken;

      _sendOtp();
    }
    super.initState();
  }

  Future<void> _sendOtp() async {
    if (widget.verificationType == 'email') {
      context.read<VerifyEmailOrPhoneBloc>().add(
            SendEmailOtpEvent(
              id: id!,
              token: token!,
            ),
          );
    } else {
      context.read<VerifyEmailOrPhoneBloc>().add(
            SendPhoneOtpEvent(
              id: id!,
              token: token!,
            ),
          );
    }

    _countdownController.restart();
  }

  Future<void> _verifyOtp(String otp) async {
    if (widget.verificationType == 'email') {
      context.read<VerifyEmailOrPhoneBloc>().add(
            VerifyEmailOtpEvent(
              id: id!,
              token: token!,
              otp: otp,
            ),
          );
    } else {
      context.read<VerifyEmailOrPhoneBloc>().add(
            VerifyPhoneOtpEvent(
              id: id!,
              token: token!,
              otp: otp,
            ),
          );
    }
  }

  @override
  void dispose() {
    _pinController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final defaultPinTheme = PinTheme(
      width: 60,
      height: 64,
      textStyle: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontSize: 24,
            fontWeight: FontWeight.w600,
          ),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.5),
        ),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
            blurRadius: 8,
            spreadRadius: 1,
          ),
        ],
      ),
    );

    final errorPinTheme = defaultPinTheme.copyWith(
      decoration: defaultPinTheme.decoration!.copyWith(
        color: Theme.of(context).colorScheme.error.withValues(alpha: 0.1),
        border: Border.all(
          color: Theme.of(context).colorScheme.error,
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).colorScheme.error.withValues(alpha: 0.2),
            blurRadius: 8,
            spreadRadius: 1,
          ),
        ],
      ),
      textStyle: defaultPinTheme.textStyle?.copyWith(
        color: Theme.of(context).colorScheme.error,
      ),
    );

    return id == null || token == null
        ? const Center(
            child: CircularProgressIndicator(),
          )
        : BlocConsumer<VerifyEmailOrPhoneBloc, VerifyEmailOrPhoneState>(
            listener: (context, state) {
              if (state is VerifyEmailOrPhoneSentState) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      'Code sent successfully. Check your ${widget.verificationType}',
                    ),
                  ),
                );

                _countdownController.restart();
              }

              if (state is VerifyEmailOtpSuccessState) {
                if (state.isVerified) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Email verified successfully'),
                    ),
                  );

                  context.pop();
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Invalid code. Please try again'),
                      backgroundColor: Theme.of(context).colorScheme.error,
                    ),
                  );
                }
              }

              if (state is VerifyEmailOrPhoneFailureState) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(state.message),
                    backgroundColor: Theme.of(context).colorScheme.error,
                  ),
                );
              }
            },
            builder: (context, state) {
              return Column(
                children: [
                  AppBar(
                    backgroundColor: Theme.of(context).scaffoldBackgroundColor,
                    // leading: IconButton(
                    //   icon: const Icon(Icons.arrow_back),
                    //   onPressed: () => Navigator.pop(context),
                    // ),
                    elevation: 0,
                  ),
                  Expanded(
                    child: SingleChildScrollView(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24.0),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const SizedBox(height: 40),
                            Icon(
                              widget.verificationType == 'email'
                                  ? Icons.email_rounded
                                  : Icons.phone_android_rounded,
                              size: 64,
                              color: Theme.of(context).colorScheme.primary,
                            ),
                            const SizedBox(height: 32),
                            Text(
                              'Verification Required',
                              textAlign: TextAlign.center,
                              style: Theme.of(context)
                                  .textTheme
                                  .titleLarge
                                  ?.copyWith(
                                    fontSize: 28,
                                    fontWeight: FontWeight.bold,
                                  ),
                            ),
                            const SizedBox(height: 12),
                            Text(
                              'Enter the 6-digit code sent to your ${widget.verificationType}',
                              textAlign: TextAlign.center,
                              style: Theme.of(context).textTheme.bodyLarge,
                            ),
                            const SizedBox(height: 40),
                            Pinput(
                              length: 6,
                              controller: _pinController,
                              defaultPinTheme: defaultPinTheme,
                              focusedPinTheme: defaultPinTheme.copyWith(
                                decoration:
                                    defaultPinTheme.decoration!.copyWith(
                                  border: Border.all(
                                    color:
                                        Theme.of(context).colorScheme.primary,
                                    width: 2,
                                  ),
                                ),
                              ),
                              errorPinTheme: errorPinTheme,
                              forceErrorState:
                                  state is VerifyEmailOrPhoneFailureState,
                              // onCompleted: (pin) {

                              // },
                            ),
                            const SizedBox(height: 40),
                            SizedBox(
                              width: double.infinity,
                              height: 56,
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor:
                                      Theme.of(context).colorScheme.primary,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                                onPressed: state
                                        is VerifyEmailOrPhoneLoadingState
                                    ? null
                                    : () async {
                                        await _verifyOtp(_pinController.text);
                                      },
                                child: state is VerifyEmailOrPhoneLoadingState
                                    ? CircularProgressIndicator()
                                    : Text(
                                        'Verify',
                                        style: Theme.of(context)
                                            .textTheme
                                            .titleLarge
                                            ?.copyWith(
                                              color: Theme.of(context)
                                                  .colorScheme
                                                  .onPrimary,
                                              fontWeight: FontWeight.w600,
                                            ),
                                      ),
                              ),
                            ),
                            const SizedBox(height: 24),
                            Countdown(
                              controller: _countdownController,
                              seconds: 60,
                              build: (_, double time) => TextButton(
                                onPressed: time == 0
                                    ? state is VerifyEmailOrPhoneLoadingState
                                        ? () {
                                            _sendOtp();
                                          }
                                        : null
                                    : null,
                                child: Text(
                                  time == 0
                                      ? 'Resend Code'
                                      : 'Resend code in ${time.toInt()}s',
                                  style: Theme.of(context)
                                      .textTheme
                                      .titleMedium
                                      ?.copyWith(
                                        color: time == 0
                                            ? Theme.of(context)
                                                .colorScheme
                                                .primary
                                            : Theme.of(context)
                                                .colorScheme
                                                .onSurface
                                                .withValues(alpha: 0.5),
                                        fontWeight: FontWeight.w500,
                                      ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 24),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              );
            },
          );
  }
}
