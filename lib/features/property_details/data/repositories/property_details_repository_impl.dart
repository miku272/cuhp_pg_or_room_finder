import 'package:fpdart/fpdart.dart';

import '../../../../core/common/entities/property.dart';
import '../../../../core/error/exception.dart';
import '../../../../core/error/failures.dart';
import '../../domain/repository/property_details_repository.dart';
import '../datasources/property_details_remote_datasource.dart';

class PropertyDetailsRepositoryImpl implements PropertyDetailsRepository {
  final PropertyDetailsRemoteDatasource propertyDetailsRemoteDatasource;

  const PropertyDetailsRepositoryImpl({
    required this.propertyDetailsRemoteDatasource,
  });

  @override
  Future<Either<Failure, Property>> getPropertyDetails({
    required String propertyId,
    required String token,
  }) async {
    try {
      final property = await propertyDetailsRemoteDatasource.getPropertyDetails(
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
