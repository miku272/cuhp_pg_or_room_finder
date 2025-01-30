import 'package:fpdart/fpdart.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecase/usecase.dart';

import '../repositories/verify_email_or_phone_repository.dart';

class VerifyEmailOtp implements Usecase<bool, VerifyEmailOtpParams> {
  final VerifyEmailOrPhoneRepository verifyEmailOrPhoneRepository;

  VerifyEmailOtp({required this.verifyEmailOrPhoneRepository});

  @override
  Future<Either<Failure, bool>> call(VerifyEmailOtpParams params) async {
    return await verifyEmailOrPhoneRepository.verifyEmailOtp(
      id: params.id,
      token: params.token,
      otp: params.otp,
    );
  }
}

class VerifyEmailOtpParams {
  final String id;
  final String token;
  final String otp;

  VerifyEmailOtpParams({
    required this.id,
    required this.token,
    required this.otp,
  });
}
