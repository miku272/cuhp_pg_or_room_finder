import 'package:fpdart/fpdart.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecase/usecase.dart';

import '../../data/models/get_saved_items_response_model.dart';
import '../repository/properties_saved_repository.dart';

class GetSavedItems
    implements Usecase<GetSavedItemsResponseModel, GetSavedItemsParams> {
  final PropertiesSavedRepository propertiesSavedRepository;

  const GetSavedItems({
    required this.propertiesSavedRepository,
  });

  @override
  Future<Either<Failure, GetSavedItemsResponseModel>> call(
    GetSavedItemsParams params,
  ) async {
    return await propertiesSavedRepository.getSavedItems(
      page: params.page,
      limit: params.limit,
      token: params.token,
    );
  }
}

class GetSavedItemsParams {
  final int page;
  final int limit;
  final String token;

  GetSavedItemsParams({
    required this.page,
    required this.limit,
    required this.token,
  });
}
