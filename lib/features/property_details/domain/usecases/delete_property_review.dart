import 'package:fpdart/fpdart.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecase/usecase.dart';

import '../repository/property_details_repository.dart';

class DeletePropertyReview
    implements Usecase<bool, DeletePropertyReviewParams> {
  final PropertyDetailsRepository propertyDetailsRepository;

  const DeletePropertyReview({
    required this.propertyDetailsRepository,
  });

  @override
  Future<Either<Failure, bool>> call(DeletePropertyReviewParams params) async {
    return await propertyDetailsRepository.deletePropertyReview(
      reviewId: params.reviewId,
      token: params.token,
    );
  }
}

class DeletePropertyReviewParams {
  final String reviewId;
  final String token;

  const DeletePropertyReviewParams({
    required this.reviewId,
    required this.token,
  });
}
