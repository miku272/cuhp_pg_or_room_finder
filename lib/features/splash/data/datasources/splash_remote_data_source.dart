import 'package:dio/dio.dart';

import '../../../../core/common/entities/user.dart';
import '../../../../core/error/exception.dart';

abstract interface class SplashRemoteDataSource {
  Future<User> getCurrentUser(String? token, String? id);
}

class SplashRemoteDataSourceImpl implements SplashRemoteDataSource {
  final Dio dio;

  SplashRemoteDataSourceImpl({
    required this.dio,
  });

  @override
  Future<User> getCurrentUser(String? token, String? id) async {
    if (token == null || token == '' || id == null || id == '') {
      throw UserException(
        status: 401,
        message: 'Unauthorized',
      );
    }

    try {
      final res = await dio.post('/auth/token-auth',
          options: Options(headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $token',
          }),
          data: {
            '_id': id,
          });

      if (res.statusCode.toString().startsWith('5')) {
        throw ServerException(
          status: res.statusCode,
          message: res.data['message'],
        );
      }

      if (res.statusCode.toString().startsWith('4')) {
        throw UserException(
          status: res.statusCode,
          message: res.data['message'],
        );
      }

      if (!res.statusCode.toString().startsWith('2')) {
        throw Exception('An error occurred');
      }

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

      rethrow;
    } catch (error) {
      rethrow;
    }
  }
}
