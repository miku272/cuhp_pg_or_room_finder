import 'package:fpdart/fpdart.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecase/usecase.dart';

import '../repository/auth_repository.dart';

import '../../../../core/common/entities/user.dart';

class UserLogin implements Usecase<User, UserLoginParams> {
  final AuthRepository authRepository;

  UserLogin({required this.authRepository});

  @override
  Future<Either<Failure, User>> call(UserLoginParams params) async {
    return await authRepository.loginWithEmailAndPassword(
      email: params.email,
      password: params.password,
    );
  }
}

class UserLoginParams {
  final String email;
  final String password;

  UserLoginParams({required this.email, required this.password});
}
