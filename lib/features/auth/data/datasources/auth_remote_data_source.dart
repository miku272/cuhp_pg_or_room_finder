import 'dart:io';

import 'package:dio/dio.dart';

import '../../../../core/error/exception.dart';

import '../models/user_model.dart';

abstract interface class AuthRemoteDataSource {
  Future<UserModel> signupWithEmailAndPassword(
    String name,
    String email,
    String password,
  );

  Future<UserModel> loginWithEmailAndPassword(
    String email,
    String password,
  );

  Future<UserModel?> getCurrentUser(String? token, String? id);
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final Dio dio;

  AuthRemoteDataSourceImpl({required this.dio});

  @override
  Future<UserModel?> getCurrentUser(String? token, String? id) async {
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

      final decodedBody = res.data;

      final UserModel user = UserModel(
        id: decodedBody['data']['user']['_id'],
        name: decodedBody['data']['user']['name'],
        email: decodedBody['data']['user']['email'],
        phone: decodedBody['data']['user']['phone'],
        isEmailVerified: decodedBody['data']['user']['isEmailVerified'],
        isPhoneVerified: decodedBody['data']['user']['isPhoneVerified'],
        jwtToken: '',
        expiresIn: '',
        createdAt: decodedBody['data']['user']['createdAt'],
        updatedAt: decodedBody['data']['user']['updatedAt'],
      );

      return user;
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

      rethrow;
    } catch (error) {
      rethrow;
    }
  }

  @override
  Future<UserModel> loginWithEmailAndPassword(
    String email,
    String password,
  ) async {
    try {
      final res = await dio.post('/auth/login-using-email-and-password',
          options: Options(headers: {
            'Content-Type': 'application/json',
          }),
          data: {
            'email': email,
            'password': password,
          });

      final decodedBody = res.data;

      final UserModel user = UserModel(
        id: decodedBody['data']['user']['_id'],
        name: decodedBody['data']['user']['name'],
        email: decodedBody['data']['user']['email'],
        phone: decodedBody['data']['user']['phone'],
        isEmailVerified: decodedBody['data']['user']['isEmailVerified'],
        isPhoneVerified: decodedBody['data']['user']['isPhoneVerified'],
        property: List<String>.from(decodedBody['data']['user']['property']),
        jwtToken: decodedBody['data']['tokenData']['token'],
        expiresIn: decodedBody['data']['tokenData']['expiresIn'],
        createdAt: decodedBody['data']['user']['createdAt'],
        updatedAt: decodedBody['data']['user']['updatedAt'],
      );

      return user;
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
  Future<UserModel> signupWithEmailAndPassword(
    String name,
    String email,
    String password,
  ) async {
    try {
      final res = await dio.post('/auth/signup-using-email-and-password',
          options: Options(headers: {
            'Content-Type': 'application/json',
          }),
          data: {
            'name': name,
            'email': email,
            'password': password,
          });

      final decodedBody = res.data;

      final UserModel user = UserModel(
        id: decodedBody['data']['user']['_id'],
        name: decodedBody['data']['user']['name'],
        email: decodedBody['data']['user']['email'],
        phone: decodedBody['data']['user']['phone'],
        isEmailVerified: decodedBody['data']['user']['isEmailVerified'],
        isPhoneVerified: decodedBody['data']['user']['isPhoneVerified'],
        jwtToken: decodedBody['data']['tokenData']['token'],
        expiresIn: decodedBody['data']['tokenData']['expiresIn'],
        property: List<String>.from(decodedBody['data']['user']['property']),
        createdAt: decodedBody['data']['user']['createdAt'],
        updatedAt: decodedBody['data']['user']['updatedAt'],
      );

      return user;
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
