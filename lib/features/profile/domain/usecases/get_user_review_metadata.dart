import 'package:fpdart/fpdart.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecase/usecase.dart';

import '../../data/models/user_review_metadata_response.dart';
import '../repository/profile_repository.dart';

class GetUserReviewMetadata
    implements
        Usecase<UserReviewMetadataResponse, GetUserReviewMetadataParams> {
  final ProfileRepository profileRepository;

  const GetUserReviewMetadata({required this.profileRepository});

  @override
  Future<Either<Failure, UserReviewMetadataResponse>> call(
    GetUserReviewMetadataParams params,
  ) async {
    return await profileRepository.getUserReviewMetadata(params.token);
  }
}

class GetUserReviewMetadataParams {
  final String token;

  const GetUserReviewMetadataParams({required this.token});
}
