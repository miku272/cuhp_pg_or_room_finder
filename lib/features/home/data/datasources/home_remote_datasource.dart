import 'dart:io';

import 'package:dio/dio.dart';

import '../../../../core/common/entities/saved_item.dart';
import '../../../../core/error/exception.dart';

import '../models/paginated_property_response.dart';
import '../models/property_filter.dart';

abstract interface class HomeRemoteDatasource {
  Future<PaginatedPropertyResponse> getPropertiesByPagination(
    int page,
    int limit,
    PropertyFilter filter,
    String token,
  );
  Future<SavedItem> addSavedItem(String propertyId, String token);
  Future<bool> removeSavedItem(String propertyId, String token);
}

class HomeRemoteDatasourceImpl implements HomeRemoteDatasource {
  final Dio dio;

  HomeRemoteDatasourceImpl({required this.dio});

  @override
  Future<PaginatedPropertyResponse> getPropertiesByPagination(
    int page,
    int limit,
    PropertyFilter filter,
    String token,
  ) async {
    final Map<String, dynamic> queryParams = filter.toQueryParameters();
    queryParams['page'] = page.toString();
    queryParams['limit'] = limit.toString();

    try {
      final res = await dio.get(
        '/properties',
        queryParameters: queryParams,
        options: Options(
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $token',
          },
        ),
      );

      final decodedBody = res.data;

      return PaginatedPropertyResponse(
        results: decodedBody['results'] as int,
        pagination: Pagination.fromJson(
          decodedBody['pagination'] as Map<String, dynamic>,
        ),
        data: Data.fromJson(
          decodedBody['data'] as Map<String, dynamic>,
        ),
      );
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
  Future<bool> removeSavedItem(String propertyId, String token) async {
    try {
      await dio.delete(
        '/saved/remove-saved-by-property-id/$propertyId',
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
