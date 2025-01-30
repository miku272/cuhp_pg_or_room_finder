import 'package:fpdart/fpdart.dart';

import '../../../../core/common/entities/user.dart';
import '../../../../core/usecase/usecase.dart';
import '../../../../core/error/failures.dart';

import '../repository/auth_repository.dart';

class CurrentUser implements Usecase<User, NoParams> {
  final AuthRepository authRepository;

  CurrentUser({required this.authRepository});

  @override
  Future<Either<Failure, User>> call(NoParams params) async {
    return await authRepository.getCurrentUser();
  }
}
