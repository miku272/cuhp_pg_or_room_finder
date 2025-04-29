import 'package:fpdart/fpdart.dart';

import '../../../../core/error/exception.dart';
import '../../../../core/error/failures.dart';

import '../models/property_filter.dart';
import '../models/paginated_property_response.dart';

import '../../domain/repository/home_repository.dart';
import '../datasources/home_remote_datasource.dart';

class HomeRepositoryImpl implements HomeRepository {
  final HomeRemoteDatasource homeRemoteDatasource;

  const HomeRepositoryImpl({
    required this.homeRemoteDatasource,
  });

  @override
  Future<Either<Failure, PaginatedPropertyResponse>> getPropertiesByPagination({
    required int page,
    required int limit,
    required PropertyFilter filter,
    required String token,
  }) async {
    try {
      final PaginatedPropertyResponse paginatedPropertyResponse =
          await homeRemoteDatasource.getPropertiesByPagination(
        page,
        limit,
        filter,
        token,
      );

      return right(paginatedPropertyResponse);
    } on ServerException catch (error) {
      return left(Failure(status: error.status, message: error.message));
    } on UserException catch (error) {
      return left(Failure(status: error.status, message: error.message));
    } catch (error) {
      return left(Failure(message: error.toString()));
    }
  }
}
