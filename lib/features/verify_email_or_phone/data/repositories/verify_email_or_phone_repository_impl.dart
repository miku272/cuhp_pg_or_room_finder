import 'package:fpdart/fpdart.dart';

import '../../../../core/error/exception.dart';
import '../../../../core/error/failures.dart';

import '../../domain/repositories/verify_email_or_phone_repository.dart';
import '../datasources/verify_email_or_phone_remote_data_source.dart';

class VerifyEmailOrPhoneRepositoryImpl implements VerifyEmailOrPhoneRepository {
  final VerifyEmailOrPhoneRemoteDataSource verifyEmailOrPhoneRemoteDataSource;

  const VerifyEmailOrPhoneRepositoryImpl({
    required this.verifyEmailOrPhoneRemoteDataSource,
  });

  @override
  Future<Either<Failure, void>> sendEmailOtp({
    required String id,
    required String token,
  }) async {
    try {
      await verifyEmailOrPhoneRemoteDataSource.sendEmailOtp(id, token);

      return right(null);
    } on ServerException catch (error) {
      return left(Failure(status: error.status, message: error.message));
    } on UserException catch (error) {
      return left(Failure(status: error.status, message: error.message));
    } catch (error) {
      return left(Failure(message: error.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> sendPhoneOtp({
    required String id,
    required String token,
  }) {
    // TODO: implement sendPhoneOtp
    throw UnimplementedError();
  }

  @override
  Future<Either<Failure, bool>> verifyEmailOtp({
    required String id,
    required String token,
    required String otp,
  }) async {
    try {
      final isVerified =
          await verifyEmailOrPhoneRemoteDataSource.verifyEmailOtp(
        id,
        token,
        otp,
      );

      return right(isVerified);
    } on ServerException catch (error) {
      return left(Failure(status: error.status, message: error.message));
    } on UserException catch (error) {
      return left(Failure(status: error.status, message: error.message));
    } catch (error) {
      return left(Failure(message: error.toString()));
    }
  }

  @override
  Future<Either<Failure, bool>> verifyPhoneOtp({
    required String id,
    required String token,
    required String otp,
  }) {
    // TODO: implement verifyPhoneOtp
    throw UnimplementedError();
  }
}
