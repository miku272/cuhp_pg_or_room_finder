import 'package:fpdart/fpdart.dart';

import '../../../../core/common/entities/user.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecase/usecase.dart';

import '../repository/profile_repository.dart';

class GetCurrentUser implements Usecase<User, GetCurrentUserParams> {
  final ProfileRepository profileRepository;

  GetCurrentUser({required this.profileRepository});

  @override
  Future<Either<Failure, User>> call(GetCurrentUserParams params) async {
    return await profileRepository.getCurrentUser(params.token);
  }
}

class GetCurrentUserParams {
  final String token;

  GetCurrentUserParams({required this.token});
}
