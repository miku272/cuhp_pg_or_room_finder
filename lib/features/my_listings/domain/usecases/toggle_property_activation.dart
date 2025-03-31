import 'package:cuhp_pg_or_room_finder/core/error/failures.dart';

import 'package:fpdart/fpdart.dart';

import '../../../../core/common/entities/property.dart';
import '../../../../core/usecase/usecase.dart';
import '../repository/my_listings_repository.dart';

class TogglePropertyActivation
    implements Usecase<Property, TogglePropertyActivationParams> {
  final MyListingsRepository myListingsRepository;

  TogglePropertyActivation({required this.myListingsRepository});

  @override
  Future<Either<Failure, Property>> call(
    TogglePropertyActivationParams params,
  ) async {
    return await myListingsRepository.togglePropertyActivation(
      params.propertyId,
      params.token,
    );
  }
}

class TogglePropertyActivationParams {
  final String propertyId;
  final String token;

  TogglePropertyActivationParams({
    required this.propertyId,
    required this.token,
  });
}
