import 'package:fpdart/fpdart.dart';

import '../../../../core/common/entities/saved_item.dart';
import '../../../../core/error/failures.dart';

import '../../data/models/paginated_property_response.dart';
import '../../data/models/property_filter.dart';

abstract interface class HomeRepository {
  Future<Either<Failure, PaginatedPropertyResponse>> getPropertiesByPagination({
    required int page,
    required int limit,
    required PropertyFilter filter,
    required String token,
  });
  Future<Either<Failure, SavedItem>> addSavedItem({
    required String propertyId,
    required String token,
  });
  Future<Either<Failure, bool>> removeSavedItem({
    required String propertyId,
    required String token,
  });
}
