import 'package:fpdart/fpdart.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecase/usecase.dart';

import '../../data/models/recent_property_reviews_response.dart';
import '../repository/property_details_repository.dart';

class GetRecentPropertyReviews
    implements
        Usecase<RecentPropertyReviewsResponse, GetRecentPropertyReviewsParams> {
  final PropertyDetailsRepository propertyDetailsRepository;

  GetRecentPropertyReviews({required this.propertyDetailsRepository});

  @override
  Future<Either<Failure, RecentPropertyReviewsResponse>> call(
    GetRecentPropertyReviewsParams params,
  ) async {
    return await propertyDetailsRepository.getRecentPropertyReviews(
      propertyId: params.propertyId,
      limit: params.limit,
      token: params.token,
    );
  }
}

class GetRecentPropertyReviewsParams {
  final String propertyId;
  final int limit;
  final String token;

  GetRecentPropertyReviewsParams({
    required this.propertyId,
    required this.limit,
    required this.token,
  });
}
