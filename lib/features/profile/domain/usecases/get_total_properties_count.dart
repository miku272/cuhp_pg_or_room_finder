import 'package:fpdart/fpdart.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecase/usecase.dart';

import '../repository/profile_repository.dart';

class GetTotalPropertiesCount
    implements Usecase<int, GetTotalPropertiesCountParams> {
  final ProfileRepository profileRepository;

  const GetTotalPropertiesCount({required this.profileRepository});

  @override
  Future<Either<Failure, int>> call(
      GetTotalPropertiesCountParams params) async {
    return await profileRepository.getTotalPropertiesCount(params.token);
  }
}

class GetTotalPropertiesCountParams {
  final String token;

  const GetTotalPropertiesCountParams({required this.token});
}
