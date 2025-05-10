import 'package:fpdart/fpdart.dart';

import '../../../../core/common/entities/saved_item.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecase/usecase.dart';

import '../repository/home_repository.dart';

class HomeAddSavedItem implements Usecase<SavedItem, HomeAddSavedItemParams> {
  final HomeRepository homeRepository;

  const HomeAddSavedItem({
    required this.homeRepository,
  });

  @override
  Future<Either<Failure, SavedItem>> call(HomeAddSavedItemParams params) async {
    return await homeRepository.addSavedItem(
      propertyId: params.propertyId,
      token: params.token,
    );
  }
}

class HomeAddSavedItemParams {
  final String propertyId;
  final String token;

  HomeAddSavedItemParams({
    required this.propertyId,
    required this.token,
  });
}
