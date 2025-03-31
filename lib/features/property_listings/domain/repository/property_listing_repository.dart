import 'dart:io';

import 'package:fpdart/fpdart.dart';

import '../../../../core/error/failures.dart';

import '../../data/models/property_form_data.dart';
import '../../data/models/property_listing_model.dart';

abstract interface class PropertyListingRepository {
  Future<Either<Failure, PropertyListingModel>> addPropertyListing({
    required PropertyFormData propertyFormData,
    required List<File> images,
    required String token,
    required String userId,
    required String username,
  });

  Future<Either<Failure, PropertyListingModel>> updatePropertyListing({
    required String propertyId,
    required PropertyFormData propertyFormData,
    required List<File> images,
    required List<String> imagesToDelete,
    required String token,
    required String username,
  });
}
