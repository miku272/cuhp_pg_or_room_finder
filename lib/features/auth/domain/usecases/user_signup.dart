import 'package:fpdart/fpdart.dart';

import '../../../../core/common/entities/user.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecase/usecase.dart';

import '../repository/auth_repository.dart';

class UserSignup implements Usecase<User, UserSignupParams> {
  final AuthRepository authRepository;

  UserSignup({required this.authRepository});

  @override
  Future<Either<Failure, User>> call(UserSignupParams params) async {
    return await authRepository.signupWithEmailAndPassword(
      name: params.name,
      email: params.email,
      password: params.password,
    );
  }
}

class UserSignupParams {
  final String name;
  final String email;
  final String password;

  UserSignupParams({
    required this.name,
    required this.email,
    required this.password,
  });
}
