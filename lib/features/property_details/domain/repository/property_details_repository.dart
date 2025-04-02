import 'package:fpdart/fpdart.dart';

import '../../../../core/common/entities/property.dart';
import '../../../../core/error/failures.dart';

abstract interface class PropertyDetailsRepository {
  Future<Either<Failure, Property>> getPropertyDetails({
    required String propertyId,
    required String token,
  });
}
