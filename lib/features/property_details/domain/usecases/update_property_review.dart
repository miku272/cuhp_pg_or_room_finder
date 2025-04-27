import 'package:fpdart/fpdart.dart';

import '../../../../core/common/entities/review.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecase/usecase.dart';

import '../repository/property_details_repository.dart';

class UpdatePropertyReview
    implements Usecase<Review, UpdatePropertyReviewParams> {
  final PropertyDetailsRepository propertyDetailsRepository;

  const UpdatePropertyReview({
    required this.propertyDetailsRepository,
  });

  @override
  Future<Either<Failure, Review>> call(
      UpdatePropertyReviewParams params) async {
    return await propertyDetailsRepository.updatePropertyReview(
      reviewId: params.reviewId,
      rating: params.rating,
      review: params.review,
      isAnonymous: params.isAnonymous,
      token: params.token,
    );
  }
}

class UpdatePropertyReviewParams {
  final String reviewId;
  final int rating;
  final String? review;
  final bool isAnonymous;
  final String token;

  const UpdatePropertyReviewParams({
    required this.reviewId,
    required this.rating,
    this.review,
    required this.isAnonymous,
    required this.token,
  });
}
