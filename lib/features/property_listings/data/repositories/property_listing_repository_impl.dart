import 'package:fpdart/fpdart.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/error/exception.dart';
import '../../../../core/common/entities/property.dart';

import '../models/property_form_data.dart';

import '../../domain/repository/property_listing_repository.dart';

import '../datasources/property_listing_remote_datasource.dart';

class PropertyListingRepositoryImpl implements PropertyListingRepository {
  final PropertyListingRemoteDataSource propertyListingRemoteDataSource;

  const PropertyListingRepositoryImpl({
    required this.propertyListingRemoteDataSource,
  });

  @override
  Future<Either<Failure, Property>> addPropertyListing(
      {required PropertyFormData propertyFormData,
      required String token,
      required String userId,
      required String username}) async {
    return _getProperty(
      () async => await propertyListingRemoteDataSource.addPropertyListing(
        propertyFormData,
        token,
        userId,
        username,
      ),
    );
  }

  Future<Either<Failure, Property>> _getProperty(
    Future<Property> Function() fn,
  ) async {
    try {
      final Property property = await fn();

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
