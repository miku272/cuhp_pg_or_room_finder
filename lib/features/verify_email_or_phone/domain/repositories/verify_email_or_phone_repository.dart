import 'package:fpdart/fpdart.dart';

import '../../../../core/error/failures.dart';

abstract interface class VerifyEmailOrPhoneRepository {
  Future<Either<Failure, void>> sendEmailOtp({
    required String id,
    required String token,
  });

  Future<Either<Failure, void>> sendPhoneOtp({
    required String id,
    required String token,
  });

  Future<Either<Failure, bool>> verifyEmailOtp({
    required String id,
    required String token,
    required String otp,
  });

  Future<Either<Failure, bool>> verifyPhoneOtp({
    required String id,
    required String token,
    required String otp,
  });
}
