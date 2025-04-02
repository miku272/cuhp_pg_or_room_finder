import 'package:fpdart/fpdart.dart';

import '../../../../core/common/entities/property.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecase/usecase.dart';
import '../repository/property_details_repository.dart';

class GetPropertyDetails
    implements Usecase<Property, GetPropertyDetailsParams> {
  final PropertyDetailsRepository propertyDetailsRepository;

  GetPropertyDetails({required this.propertyDetailsRepository});

  @override
  Future<Either<Failure, Property>> call(
    GetPropertyDetailsParams params,
  ) async {
    return await propertyDetailsRepository.getPropertyDetails(
      propertyId: params.propertyId,
      token: params.token,
    );
  }
}

class GetPropertyDetailsParams {
  final String propertyId;
  final String token;

  GetPropertyDetailsParams({
    required this.propertyId,
    required this.token,
  });
}
