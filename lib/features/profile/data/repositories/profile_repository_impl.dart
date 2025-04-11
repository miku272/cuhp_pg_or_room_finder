import 'package:fpdart/fpdart.dart';

import '../../../../core/common/entities/user.dart';
import '../../../../core/error/exception.dart';
import '../../../../core/error/failures.dart';

import '../../domain/repository/profile_repository.dart';
import '../datasources/profile_remote_datasource.dart';

class ProfileRepositoryImpl implements ProfileRepository {
  final ProfileRemoteDatasource profileRemoteDatasource;

  const ProfileRepositoryImpl({
    required this.profileRemoteDatasource,
  });

  @override
  Future<Either<Failure, User>> getCurrentUser(String token) async {
    try {
      final user = await profileRemoteDatasource.getCurrentUser(token);

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