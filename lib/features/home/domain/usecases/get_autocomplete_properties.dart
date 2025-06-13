import 'package:fpdart/fpdart.dart';

import '../../../../core/common/entities/property.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecase/usecase.dart';

import '../repository/home_repository.dart';

class GetAutocompleteProperties
    implements Usecase<List<Property>, GetAutocompletePropertiesParams> {
  final HomeRepository homeRepository;

  GetAutocompleteProperties({
    required this.homeRepository,
  });

  @override
  Future<Either<Failure, List<Property>>> call(
    GetAutocompletePropertiesParams params,
  ) async {
    return await homeRepository.getAutocompleteProperties(
      term: params.term,
      token: params.token,
    );
  }
}

class GetAutocompletePropertiesParams {
  final String term;
  final String token;

  GetAutocompletePropertiesParams({
    required this.term,
    required this.token,
  });
}
