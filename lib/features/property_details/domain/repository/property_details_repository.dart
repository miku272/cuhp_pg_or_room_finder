import 'package:fpdart/fpdart.dart';

import '../../../../core/common/entities/property.dart';
import '../../../../core/common/entities/review.dart';
import '../../../../core/error/failures.dart';

abstract interface class PropertyDetailsRepository {
  Future<Either<Failure, Property>> getPropertyDetails({
    required String propertyId,
    required String token,
  });
  Future<Either<Failure, Review>> addPropertyReview({
    required String propertyId,
    required int rating,
    String? review,
    required bool isAnonymous,
    required String token,
  });
  Future<Either<Failure, Review>> updatePropertyReview({
    required String reviewId,
    required int rating,
    required String? review,
    required bool isAnonymous,
    required String token,
  });

  Future<Either<Failure, bool>> deletePropertyReview({
    required String reviewId,
    required String token,
  });
}
