import 'package:fpdart/fpdart.dart';

import '../../../../core/error/failures.dart';

import '../../../../core/common/entities/user.dart';

abstract interface class AuthRepository {
  Future<Either<Failure, User>> signupWithEmailAndPassword({
    required String name,
    required String email,
    required String password,
  });

  Future<Either<Failure, User>> loginWithEmailAndPassword({
    required String email,
    required String password,
  });

  Future<Either<Failure, User>> getCurrentUser();
}
