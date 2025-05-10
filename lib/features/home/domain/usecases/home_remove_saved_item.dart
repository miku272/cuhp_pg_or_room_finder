import 'package:fpdart/fpdart.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecase/usecase.dart';

import '../repository/home_repository.dart';

class HomeRemoveSavedItem implements Usecase<bool, HomeRemoveSavedItemParams> {
  final HomeRepository homeRepository;

  const HomeRemoveSavedItem({
    required this.homeRepository,
  });

  @override
  Future<Either<Failure, bool>> call(HomeRemoveSavedItemParams params) async {
    return await homeRepository.removeSavedItem(
      propertyId: params.propertyId,
      token: params.token,
    );
  }
}

class HomeRemoveSavedItemParams {
  final String propertyId;
  final String token;

  HomeRemoveSavedItemParams({
    required this.propertyId,
    required this.token,
  });
}
