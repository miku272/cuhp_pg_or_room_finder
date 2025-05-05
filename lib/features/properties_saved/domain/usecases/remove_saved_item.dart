import 'package:fpdart/fpdart.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecase/usecase.dart';

import '../repository/properties_saved_repository.dart';

class RemoveSavedItem implements Usecase<bool, RemoveSavedItemParams> {
  final PropertiesSavedRepository propertiesSavedRepository;

  const RemoveSavedItem({
    required this.propertiesSavedRepository,
  });

  @override
  Future<Either<Failure, bool>> call(RemoveSavedItemParams params) async {
    return await propertiesSavedRepository.removeSavedItem(
      savedItemId: params.savedItemId,
      token: params.token,
    );
  }
}

class RemoveSavedItemParams {
  final String savedItemId;
  final String token;

  RemoveSavedItemParams({
    required this.savedItemId,
    required this.token,
  });
}
