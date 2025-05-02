import 'package:fpdart/fpdart.dart';

import '../../../../core/common/entities/chat.dart';
import '../../../../core/common/entities/property.dart';
import '../../../../core/common/entities/review.dart';
import '../../../../core/error/failures.dart';
import '../../data/models/recent_property_reviews_response.dart';

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

  Future<Either<Failure, Review>> getCurrentUserReview({
    required String propertyId,
    required String userId,
    required String token,
  });

  Future<Either<Failure, RecentPropertyReviewsResponse>>
      getRecentPropertyReviews({
    required String propertyId,
    required int limit,
    required String token,
  });

  Future<Either<Failure, Chat>> initializeChat({
    required String propertyId,
    required String token,
  });
}
