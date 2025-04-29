import 'package:fpdart/fpdart.dart';

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
}
