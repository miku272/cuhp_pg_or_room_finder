import 'package:fpdart/fpdart.dart';

import '../../../../core/common/entities/property.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecase/usecase.dart';

import '../repository/my_listings_repository.dart';

class GetPropertiesById
    implements Usecase<List<Property>, GetPropertiesByIdParams> {
  final MyListingsRepository myListingsRepository;

  const GetPropertiesById({required this.myListingsRepository});

  @override
  Future<Either<Failure, List<Property>>> call(
    GetPropertiesByIdParams params,
  ) async {
    return await myListingsRepository.getPropertiesById(
      propertyIds: params.propertyIds,
      token: params.token,
    );
  }
}

class GetPropertiesByIdParams {
  final List<String> propertyIds;
  final String token;

  const GetPropertiesByIdParams({
    required this.propertyIds,
    required this.token,
  });
}
