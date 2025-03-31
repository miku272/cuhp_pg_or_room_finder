import 'dart:developer';

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

      log(
        'verify email or phone remote error in send email otp: ',
        error: decodedBody,
      );
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

      log(
        'verify email or phone remote error in verify email otp: ',
        error: decodedBody,
      );

      return true;
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

  @override
  Future<bool> verifyPhoneOtp(String id, String token, String otp) async {
    // TODO: implement verifyPhoneOtp
    throw UnimplementedError();
  }
}
