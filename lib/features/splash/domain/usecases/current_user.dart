import 'package:fpdart/fpdart.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/common/entities/user.dart';
import '../../../../core/usecase/usecase.dart';

import '../repository/splash_repository.dart';

class CurrentUser implements Usecase<User?, CurrentUserParams> {
  final SplashRepository splashRepository;

  CurrentUser({required this.splashRepository});

  @override
  Future<Either<Failure, User?>> call(CurrentUserParams params) async {
    return await splashRepository.getCurrentUser(params.token, params.id);
  }
}

class CurrentUserParams {
  String? id;
  String? token;

  CurrentUserParams({this.id, this.token});
}
