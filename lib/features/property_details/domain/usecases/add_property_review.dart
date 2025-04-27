import 'package:fpdart/fpdart.dart';

import '../../../../core/common/entities/review.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecase/usecase.dart';

import '../repository/property_details_repository.dart';

class AddPropertyReview implements Usecase<Review, AddPropertyReviewParams> {
  final PropertyDetailsRepository propertyDetailsRepository;

  const AddPropertyReview({
    required this.propertyDetailsRepository,
  });

  @override
  Future<Either<Failure, Review>> call(AddPropertyReviewParams params) async {
    return await propertyDetailsRepository.addPropertyReview(
      propertyId: params.propertyId,
      rating: params.rating,
      review: params.review,
      isAnonymous: params.isAnonymous,
      token: params.token,
    );
  }
}

class AddPropertyReviewParams {
  final String propertyId;
  final int rating;
  final String? review;
  final bool isAnonymous;
  final String token;

  AddPropertyReviewParams({
    required this.propertyId,
    required this.rating,
    this.review,
    required this.isAnonymous,
    required this.token,
  });
}
