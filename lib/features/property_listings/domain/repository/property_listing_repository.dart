import 'package:fpdart/fpdart.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/common/entities/property.dart';

import '../../data/models/property_form_data.dart';

abstract interface class PropertyListingRepository {
  Future<Either<Failure, Property>> addPropertyListing({
    required PropertyFormData propertyFormData,
    required String token,
    required String userId,
    required String username,
  });
}
