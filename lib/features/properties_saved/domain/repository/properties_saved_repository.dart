import 'package:fpdart/fpdart.dart';

import '../../../../core/common/entities/saved_item.dart';
import '../../../../core/error/failures.dart';
import '../../data/models/get_saved_items_response_model.dart';

abstract interface class PropertiesSavedRepository {
  Future<Either<Failure, SavedItem>> addSavedItem({
    required String propertyId,
    required String token,
  });
  Future<Either<Failure, bool>> removeSavedItem({
    required String savedItemId,
    required String token,
  });
  Future<Either<Failure, GetSavedItemsResponseModel>> getSavedItems({
    required int page,
    required int limit,
    required String token,
  });
}
