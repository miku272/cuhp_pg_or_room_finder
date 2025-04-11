import 'dart:io';

import 'package:dio/dio.dart';

import '../../../../core/common/entities/user.dart';
import '../../../../core/error/exception.dart';

abstract interface class ProfileRemoteDatasource {
  Future<User> getCurrentUser(String token);
}

class ProfileRemoteDatasourceImpl implements ProfileRemoteDatasource {
  final Dio dio;

  const ProfileRemoteDatasourceImpl({required this.dio});

  @override
  Future<User> getCurrentUser(String token) async {
    try {
      final res = await dio.post(
        '/auth/token-auth',
        options: Options(headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        }),
      );

      final decodedBody = res.data;

      final User user = User(
        id: decodedBody['data']['user']['_id'],
        name: decodedBody['data']['user']['name'],
        email: decodedBody['data']['user']['email'],
        phone: decodedBody['data']['user']['phone'],
        isEmailVerified: decodedBody['data']['user']['isEmailVerified'],
        isPhoneVerified: decodedBody['data']['user']['isPhoneVerified'],
        jwtToken: '',
        expiresIn: '',
        property: List<String>.from(decodedBody['data']['user']['property']),
        createdAt: decodedBody['data']['user']['createdAt'],
        updatedAt: decodedBody['data']['user']['updatedAt'],
      );

      return user;
    } on DioException catch (error) {
      if (error.type == DioExceptionType.connectionTimeout ||
          error.type == DioExceptionType.receiveTimeout) {
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
            message: errors.data['message'],
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
