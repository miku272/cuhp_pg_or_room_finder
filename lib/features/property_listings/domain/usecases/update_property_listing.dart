import 'dart:io';

import 'package:fpdart/fpdart.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecase/usecase.dart';
import '../../data/models/property_form_data.dart';
import '../../data/models/property_listing_model.dart';
import '../repository/property_listing_repository.dart';

class UpdatePropertyListing
    implements Usecase<PropertyListingModel, UpdatePropertyListingParams> {
  final PropertyListingRepository propertyListingRepository;

  const UpdatePropertyListing({required this.propertyListingRepository});

  @override
  Future<Either<Failure, PropertyListingModel>> call(
      UpdatePropertyListingParams params) async {
    return await propertyListingRepository.updatePropertyListing(
      propertyId: params.propertyId,
      propertyFormData: params.propertyFormData,
      images: params.images,
      imagesToDelete: params.imagesToDelete,
      token: params.token,
      username: params.username,
    );
  }
}

class UpdatePropertyListingParams {
  final String propertyId;
  final PropertyFormData propertyFormData;
  final List<File> images;
  final List<String> imagesToDelete;
  final String token;
  final String username;

  const UpdatePropertyListingParams({
    required this.propertyId,
    required this.propertyFormData,
    required this.images,
    required this.imagesToDelete,
    required this.token,
    required this.username,
  });
}
