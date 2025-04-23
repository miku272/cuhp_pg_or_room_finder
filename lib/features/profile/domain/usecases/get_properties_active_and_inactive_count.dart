import 'package:fpdart/fpdart.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecase/usecase.dart';

import '../repository/profile_repository.dart';
import '../../data/models/properties_active_and_inactive_count_response.dart';

class GetPropertiesActiveAndInactiveCount
    implements
        Usecase<PropertiesActiveAndInactiveCountResponse,
            GetPropertiesActiveAndInactiveCountParams> {
  final ProfileRepository profileRepository;
  const GetPropertiesActiveAndInactiveCount({required this.profileRepository});

  @override
  Future<Either<Failure, PropertiesActiveAndInactiveCountResponse>> call(
      GetPropertiesActiveAndInactiveCountParams params) async {
    return await profileRepository
        .getPropertiesActiveAndInactiveCount(params.token);
  }
}

class GetPropertiesActiveAndInactiveCountParams {
  final String token;

  const GetPropertiesActiveAndInactiveCountParams({required this.token});
}
