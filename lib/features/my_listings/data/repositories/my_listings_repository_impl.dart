import 'package:fpdart/fpdart.dart';

import '../../../../core/common/entities/property.dart';
import '../../../../core/error/exception.dart';
import '../../../../core/error/failures.dart';

import '../../domain/repository/my_listings_repository.dart';
import '../datasources/my_listings_remote_data_source.dart';

class MyListingsRepositoryImpl implements MyListingsRepository {
  final MyListingsRemoteDataSource myListingsRemoteDataSource;

  const MyListingsRepositoryImpl({
    required this.myListingsRemoteDataSource,
  });

  @override
  Future<Either<Failure, List<Property>>> getPropertiesById({
    required List<String> propertyIds,
    required String token,
  }) async {
    try {
      final List<Property> properties =
          await myListingsRemoteDataSource.getPropertiesById(
        propertyIds,
        token,
      );

      return right(properties);
    } on ServerException catch (error) {
      return left(Failure(status: error.status, message: error.message));
    } on UserException catch (error) {
      return left(Failure(status: error.status, message: error.message));
    } catch (error) {
      return left(Failure(message: error.toString()));
    }
  }

  @override
  Future<Either<Failure, Property>> togglePropertyActivation(
    String propertyId,
    String token,
  ) async {
    try {
      final Property property =
          await myListingsRemoteDataSource.togglePropertyActivation(
        propertyId,
        token,
      );

      return right(property);
    } on ServerException catch (error) {
      return left(Failure(status: error.status, message: error.message));
    } on UserException catch (error) {
      return left(Failure(status: error.status, message: error.message));
    } catch (error) {
      return left(Failure(message: error.toString()));
    }
  }
}
