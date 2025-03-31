import 'package:fpdart/fpdart.dart';

import '../../../../core/common/entities/property.dart';
import '../../../../core/error/failures.dart';

abstract interface class MyListingsRepository {
  Future<Either<Failure, List<Property>>> getPropertiesById({
    required List<String> propertyIds,
    required String token,
  });



  Future<Either<Failure, Property>> togglePropertyActivation(
    String propertyId,
    String token,
  );
}
