import 'dart:io';

import 'package:fpdart/fpdart.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecase/usecase.dart';

import '../../data/models/property_form_data.dart';

import '../../data/models/property_listing_model.dart';
import '../repository/property_listing_repository.dart';

class AddPropertyListing
    implements Usecase<PropertyListingModel, AddPropertyListingParams> {
  final PropertyListingRepository propertyListingRepository;

  const AddPropertyListing({required this.propertyListingRepository});

  @override
  Future<Either<Failure, PropertyListingModel>> call(
      AddPropertyListingParams params) async {
    return await propertyListingRepository.addPropertyListing(
      propertyFormData: params.propertyFormData,
      images: params.images,
      token: params.token,
      userId: params.userId,
      username: params.username,
    );
  }
}

class AddPropertyListingParams {
  final PropertyFormData propertyFormData;
  final List<File> images;
  final String token;
  final String userId;
  final String username;

  const AddPropertyListingParams({
    required this.propertyFormData,
    required this.images,
    required this.token,
    required this.userId,
    required this.username,
  });
}
