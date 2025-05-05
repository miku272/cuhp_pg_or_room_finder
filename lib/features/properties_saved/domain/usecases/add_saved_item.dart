import 'package:fpdart/fpdart.dart';

import '../../../../core/common/entities/saved_item.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecase/usecase.dart';

import '../repository/properties_saved_repository.dart';

class AddSavedItem implements Usecase<SavedItem, AddSavedItemParams> {
  final PropertiesSavedRepository propertiesSavedRepository;

  const AddSavedItem({
    required this.propertiesSavedRepository,
  });

  @override
  Future<Either<Failure, SavedItem>> call(AddSavedItemParams params) async {
    return await propertiesSavedRepository.addSavedItem(
      propertyId: params.propertyId,
      token: params.token,
    );
  }
}

class AddSavedItemParams {
  final String propertyId;
  final String token;

  AddSavedItemParams({
    required this.propertyId,
    required this.token,
  });
}
