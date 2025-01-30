import 'package:fpdart/fpdart.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/error/exception.dart';
import '../../../../core/common/entities/user.dart';

import '../../domain/repository/auth_repository.dart';

import '../datasources/auth_remote_data_source.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource authRemoteDataSource;

  const AuthRepositoryImpl({
    required this.authRemoteDataSource,
  });

  @override
  Future<Either<Failure, User>> getCurrentUser() async {
    // TODO: implement getCurrentUser
    throw UnimplementedError();
  }

  @override
  Future<Either<Failure, User>> loginWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    return _getUser(
      () async => await authRemoteDataSource.loginWithEmailAndPassword(
        email,
        password,
      ),
    );
  }

  @override
  Future<Either<Failure, User>> signupWithEmailAndPassword(
      {required String name,
      required String email,
      required String password}) async {
    return _getUser(
      () async => await authRemoteDataSource.signupWithEmailAndPassword(
        name,
        email,
        password,
      ),
    );
  }

  Future<Either<Failure, User>> _getUser(Future<User> Function() fn) async {
    try {
      final User user = await fn();

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
