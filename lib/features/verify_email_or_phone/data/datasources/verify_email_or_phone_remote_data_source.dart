import 'dart:io';

import 'package:dio/dio.dart';

import '../../../../core/error/exception.dart';

abstract interface class VerifyEmailOrPhoneRemoteDataSource {
  Future<void> sendEmailOtp(String id, String token);

  Future<void> sendPhoneOtp(String id, String token);

  Future<bool> verifyEmailOtp(String id, String token, String otp);

  Future<bool> verifyPhoneOtp(String id, String token, String otp);
}

class VerifyEmailOrPhoneRemoteDataSourceImpl
    implements VerifyEmailOrPhoneRemoteDataSource {
  final Dio dio;

  VerifyEmailOrPhoneRemoteDataSourceImpl({required this.dio});

  @override
  Future<void> sendEmailOtp(String id, String token) async {
    try {
      final res = await dio.post('/send-email-otp',
          options: Options(headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $token',
          }),
          data: {
            '_id': id,
          });

      final decodedBody = res.data;
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

  @override
  Future<void> sendPhoneOtp(String id, String token) async {
    // TODO: implement sendPhoneOtp
    throw UnimplementedError();
  }

  @override
  Future<bool> verifyEmailOtp(String id, String token, String otp) async {
    try {
      final res = await dio.post('/verify-email-otp',
          options: Options(headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $token',
          }),
          data: {
            '_id': id,
            'emailOtp': otp,
          });

      final decodedBody = res.data;

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

  @override
  Future<bool> verifyPhoneOtp(String id, String token, String otp) async {
    // TODO: implement verifyPhoneOtp
    throw UnimplementedError();
  }
}
