import 'package:fpdart/fpdart.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecase/usecase.dart';

import '../repositories/verify_email_or_phone_repository.dart';

class SendEmailOtp implements Usecase<void, SendEmailOtpParams> {
  final VerifyEmailOrPhoneRepository verifyEmailOrPhoneRepository;

  SendEmailOtp({required this.verifyEmailOrPhoneRepository});

  @override
  Future<Either<Failure, void>> call(SendEmailOtpParams params) async {
    return await verifyEmailOrPhoneRepository.sendEmailOtp(
      id: params.id,
      token: params.token,
    );
  }
}

class SendEmailOtpParams {
  final String id;
  final String token;

  SendEmailOtpParams({required this.id, required this.token});
}
