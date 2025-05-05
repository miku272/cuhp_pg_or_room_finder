import 'package:fpdart/fpdart.dart';

import '../../../../core/common/entities/saved_item.dart';
import '../../../../core/error/exception.dart';
import '../../../../core/error/failures.dart';

import '../models/get_saved_items_response_model.dart';

import '../../domain/repository/properties_saved_repository.dart';
import '../datasources/properties_saved_remote_datasource.dart';

class PropertiesSavedRepositoryImpl implements PropertiesSavedRepository {
  final PropertiesSavedRemoteDatasource propertiesSavedRemoteDatasource;

  const PropertiesSavedRepositoryImpl({
    required this.propertiesSavedRemoteDatasource,
  });

  @override
  Future<Either<Failure, SavedItem>> addSavedItem({
    required String propertyId,
    required String token,
  }) async {
    try {
      final SavedItem savedItem =
          await propertiesSavedRemoteDatasource.addSavedItem(
        propertyId,
        token,
      );

      return right(savedItem);
    } on ServerException catch (error) {
      return left(Failure(status: error.status, message: error.message));
    } on UserException catch (error) {
      return left(Failure(status: error.status, message: error.message));
    } catch (error) {
      return left(Failure(message: error.toString()));
    }
  }

  @override
  Future<Either<Failure, GetSavedItemsResponseModel>> getSavedItems({
    required int page,
    required int limit,
    required String token,
  }) async {
    try {
      final GetSavedItemsResponseModel savedItemsResponseModel =
          await propertiesSavedRemoteDatasource.getSavedItems(
        page,
        limit,
        token,
      );

      return right(savedItemsResponseModel);
    } on ServerException catch (error) {
      return left(Failure(status: error.status, message: error.message));
    } on UserException catch (error) {
      return left(Failure(status: error.status, message: error.message));
    } catch (error) {
      return left(Failure(message: error.toString()));
    }
  }

  @override
  Future<Either<Failure, bool>> removeSavedItem({
    required String savedItemId,
    required String token,
  }) async {
    try {
      final bool isRemoved =
          await propertiesSavedRemoteDatasource.removeSavedItem(
        savedItemId,
        token,
      );

      return right(isRemoved);
    } on ServerException catch (error) {
      return left(Failure(status: error.status, message: error.message));
    } on UserException catch (error) {
      return left(Failure(status: error.status, message: error.message));
    } catch (error) {
      return left(Failure(message: error.toString()));
    }
  }
}
