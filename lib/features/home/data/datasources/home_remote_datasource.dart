import 'dart:io';

import 'package:dio/dio.dart';

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
}
