import 'package:fpdart/fpdart.dart';

import '../../../../core/common/entities/user.dart';
import '../../../../core/error/failures.dart';

import '../../data/models/properties_active_and_inactive_count_response.dart';

abstract class ProfileRepository {
  Future<Either<Failure, User>> getCurrentUser(String token);
  Future<Either<Failure, int>> getTotalPropertiesCount(String token);
  Future<Either<Failure, PropertiesActiveAndInactiveCountResponse>>
      getPropertiesActiveAndInactiveCount(String token);
}
