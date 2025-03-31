import 'dart:io';

import 'package:fpdart/fpdart.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/error/exception.dart';

import '../models/property_form_data.dart';

import '../../domain/repository/property_listing_repository.dart';

import '../datasources/property_listing_remote_datasource.dart';
import '../models/property_listing_model.dart';

class PropertyListingRepositoryImpl implements PropertyListingRepository {
  final PropertyListingRemoteDataSource propertyListingRemoteDataSource;

  const PropertyListingRepositoryImpl({
    required this.propertyListingRemoteDataSource,
  });

  @override
  Future<Either<Failure, PropertyListingModel>> addPropertyListing({
    required PropertyFormData propertyFormData,
    required List<File> images,
    required String token,
    required String userId,
    required String username,
  }) async {
    return _getProperty(
      () async => await propertyListingRemoteDataSource.addPropertyListing(
        propertyFormData,
        images,
        token,
        userId,
        username,
      ),
    );
  }

  @override
  Future<Either<Failure, PropertyListingModel>> updatePropertyListing({
    required String propertyId,
    required PropertyFormData propertyFormData,
    required List<File> images,
    required List<String> imagesToDelete,
    required String token,
    required String username,
  }) async {
    return _getProperty(
      () async => await propertyListingRemoteDataSource.updatePropertyListing(
        propertyId,
        propertyFormData,
        images,
        imagesToDelete,
        token,
        username,
      ),
    );
  }

  Future<Either<Failure, PropertyListingModel>> _getProperty(
    Future<PropertyListingModel> Function() fn,
  ) async {
    try {
      final PropertyListingModel property = await fn();

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
