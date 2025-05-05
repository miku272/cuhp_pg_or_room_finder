import 'dart:io';

import 'package:dio/dio.dart';

import '../../../../core/common/entities/saved_item.dart';
import '../../../../core/error/exception.dart';

import '../models/get_saved_items_response_model.dart';

abstract interface class PropertiesSavedRemoteDatasource {
  Future<SavedItem> addSavedItem(String propertyId, String token);
  Future<bool> removeSavedItem(String savedItemId, String token);
  Future<GetSavedItemsResponseModel> getSavedItems(
    int page,
    int limit,
    String token,
  );
}

class PropertiesSavedRemoteDatasourceImpl
    implements PropertiesSavedRemoteDatasource {
  final Dio dio;

  PropertiesSavedRemoteDatasourceImpl({required this.dio});

  @override
  Future<SavedItem> addSavedItem(String propertyId, String token) async {
    try {
      final res = await dio.post(
        '/saved/add-saved',
        options: Options(
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $token',
          },
        ),
        data: {
          'propertyId': propertyId,
        },
      );

      final decodedBody = res.data;

      final savedItem = SavedItem.fromJson(decodedBody['data']['saved']);

      return savedItem;
    } on DioException catch (error) {
      if (error.type == DioExceptionType.connectionTimeout ||
          error.type == DioExceptionType.receiveTimeout ||
          error.type == DioExceptionType.sendTimeout ||
          error.type == DioExceptionType.connectionError) {
        throw ServerException(
          status: 503,
          message: 'Unable to connect to the server',
        );
      }

      final errors = error.response;

      if (errors != null) {
        if (errors.statusCode.toString().startsWith('5')) {
          throw ServerException(
            status: errors.statusCode,
            message: errors.data['message'],
          );
        }

        if (errors.statusCode.toString().startsWith('4')) {
          throw UserException(
            status: errors.statusCode,
            message:
                errors.statusCode == 429 ? errors.data : errors.data['message'],
          );
        }

        if (!errors.statusCode.toString().startsWith('2')) {
          throw Exception('An error occurred');
        }
      }

      rethrow;
    } on SocketException catch (_) {
      throw ServerException(
        status: 503,
        message: 'Unable to connect to the server',
      );
    } catch (error) {
      rethrow;
    }
  }

  @override
  Future<GetSavedItemsResponseModel> getSavedItems(
    int page,
    int limit,
    String token,
  ) async {
    try {
      final res = await dio.get(
        '/get-saved-by-user?page=$page&limit=$limit',
        options: Options(
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $token',
          },
        ),
      );

      final decodedBody = res.data;

      final response = GetSavedItemsResponseModel.fromJson(decodedBody);

      return response;
    } on DioException catch (error) {
      if (error.type == DioExceptionType.connectionTimeout ||
          error.type == DioExceptionType.receiveTimeout ||
          error.type == DioExceptionType.sendTimeout ||
          error.type == DioExceptionType.connectionError) {
        throw ServerException(
          status: 503,
          message: 'Unable to connect to the server',
        );
      }

      final errors = error.response;

      if (errors != null) {
        if (errors.statusCode.toString().startsWith('5')) {
          throw ServerException(
            status: errors.statusCode,
            message: errors.data['message'],
          );
        }

        if (errors.statusCode.toString().startsWith('4')) {
          throw UserException(
            status: errors.statusCode,
            message:
                errors.statusCode == 429 ? errors.data : errors.data['message'],
          );
        }

        if (!errors.statusCode.toString().startsWith('2')) {
          throw Exception('An error occurred');
        }
      }

      rethrow;
    } on SocketException catch (_) {
      throw ServerException(
        status: 503,
        message: 'Unable to connect to the server',
      );
    } catch (error) {
      rethrow;
    }
  }

  @override
  Future<bool> removeSavedItem(String savedItemId, String token) async {
    try {
      await dio.delete(
        '/remove-saved/$savedItemId',
        options: Options(
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $token',
          },
        ),
      );

      return true;
    } on DioException catch (error) {
      if (error.type == DioExceptionType.connectionTimeout ||
          error.type == DioExceptionType.receiveTimeout ||
          error.type == DioExceptionType.sendTimeout ||
          error.type == DioExceptionType.connectionError) {
        throw ServerException(
          status: 503,
          message: 'Unable to connect to the server',
        );
      }

      final errors = error.response;

      if (errors != null) {
        if (errors.statusCode.toString().startsWith('5')) {
          throw ServerException(
            status: errors.statusCode,
            message: errors.data['message'],
          );
        }

        if (errors.statusCode.toString().startsWith('4')) {
          throw UserException(
            status: errors.statusCode,
            message:
                errors.statusCode == 429 ? errors.data : errors.data['message'],
          );
        }

        if (!errors.statusCode.toString().startsWith('2')) {
          throw Exception('An error occurred');
        }
      }

      rethrow;
    } on SocketException catch (_) {
      throw ServerException(
        status: 503,
        message: 'Unable to connect to the server',
      );
    } catch (error) {
      rethrow;
    }
  }
}
