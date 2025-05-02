import 'package:fpdart/fpdart.dart';

import '../../../../core/common/entities/review.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecase/usecase.dart';

import '../repository/property_details_repository.dart';

class GetCurrentUserReview
    implements Usecase<Review, GetCurrentUserReviewParams> {
  final PropertyDetailsRepository propertyDetailsRepository;

  const GetCurrentUserReview({required this.propertyDetailsRepository});

  @override
  Future<Either<Failure, Review>> call(
      GetCurrentUserReviewParams params) async {
    return await propertyDetailsRepository.getCurrentUserReview(
      propertyId: params.propertyId,
      userId: params.userId,
      token: params.token,
    );
  }
}

class GetCurrentUserReviewParams {
  final String propertyId;
  final String userId;
  final String token;

  const GetCurrentUserReviewParams({
    required this.propertyId,
    required this.userId,
    required this.token,
  });
}
