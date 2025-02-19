import 'package:fpdart/fpdart.dart';

import '../../../../core/common/entities/property.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecase/usecase.dart';

import '../../data/models/property_form_data.dart';

import '../repository/property_listing_repository.dart';

class AddPropertyListing
    implements Usecase<Property, AddPropertyListingParams> {
  final PropertyListingRepository propertyListingRepository;

  const AddPropertyListing({required this.propertyListingRepository});

  @override
  Future<Either<Failure, Property>> call(
      AddPropertyListingParams params) async {
    return await propertyListingRepository.addPropertyListing(
      propertyFormData: params.propertyFormData,
      token: params.token,
      userId: params.userId,
      username: params.username,
    );
  }
}

class AddPropertyListingParams {
  final PropertyFormData propertyFormData;
  final String token;
  final String userId;
  final String username;

  const AddPropertyListingParams({
    required this.propertyFormData,
    required this.token,
    required this.userId,
    required this.username,
  });
}
