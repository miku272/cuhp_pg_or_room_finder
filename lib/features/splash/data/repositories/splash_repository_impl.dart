import 'package:fpdart/fpdart.dart';

import '../../../../core/common/entities/user.dart';
import '../../../../core/error/exception.dart';
import '../../../../core/error/failures.dart';

import '../datasources/splash_remote_data_source.dart';

import '../../domain/repository/splash_repository.dart';

class SplashRepositoryImpl implements SplashRepository {
  final SplashRemoteDataSource splashRemoteDataSource;

  const SplashRepositoryImpl({
    required this.splashRemoteDataSource,
  });

  @override
  Future<Either<Failure, User?>> getCurrentUser(
    String? token,
    String? id,
  ) async {
    return _getUser(
      () async => splashRemoteDataSource.getCurrentUser(token, id),
    );
  }

  Future<Either<Failure, User?>> _getUser(Future<User?> Function() fn) async {
    try {
      final User? user = await fn();

      return right(user);
    } on ServerException catch (error) {
      return left(Failure(status: error.status, message: error.message));
    } on UserException catch (error) {
      return left(Failure(status: error.status, message: error.message));
    } catch (error) {
      return left(Failure(message: error.toString()));
    }
  }
}
