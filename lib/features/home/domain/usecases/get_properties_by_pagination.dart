import 'package:fpdart/fpdart.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecase/usecase.dart';

import '../../data/models/paginated_property_response.dart';
import '../../data/models/property_filter.dart';
import '../repository/home_repository.dart';

class GetPropertiesByPagination
    implements
        Usecase<PaginatedPropertyResponse, GetPropertiesByPaginationParams> {
  final HomeRepository homeRepository;

  const GetPropertiesByPagination({
    required this.homeRepository,
  });

  @override
  Future<Either<Failure, PaginatedPropertyResponse>> call(
      GetPropertiesByPaginationParams params) async {
    return await homeRepository.getPropertiesByPagination(
      page: params.page,
      limit: params.limit,
      filter: params.filter,
      token: params.token,
    );
  }
}

class GetPropertiesByPaginationParams {
  final int page;
  final int limit;
  final PropertyFilter filter;
  final String token;

  const GetPropertiesByPaginationParams({
    required this.page,
    required this.limit,
    required this.filter,
    required this.token,
  });
}
