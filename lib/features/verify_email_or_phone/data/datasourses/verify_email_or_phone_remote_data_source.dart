import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

import '../../../../core/constants/constants.dart';
import '../../../../core/error/exception.dart';

abstract interface class VerifyEmailOrPhoneRemoteDataSource {
  Future<void> sendEmailOtp(String id, String token);
  Future<void> sendPhoneOtp(String id, String token);

  Future<bool> verifyEmailOtp(String id, String token, String otp);
  Future<bool> verifyPhoneOtp(String id, String token, String otp);
}

class VerifyEmailOrPhoneRemoteDataSourceImpl
    implements VerifyEmailOrPhoneRemoteDataSource {
  @override
  Future<void> sendEmailOtp(String id, String token) async {
    try {
      final res = await http
          .post(
        Uri.parse('${Constants.backendUri}/send-email-otp'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          '_id': id,
        }),
      )
          .timeout(
        const Duration(seconds: 10),
        onTimeout: () {
          throw const SocketException('Connection timed out');
        },
      );

      final decodedBody = jsonDecode(res.body) as Map<String, dynamic>;

      if (res.statusCode.toString().startsWith('5')) {
        throw ServerException(
          status: res.statusCode,
          message: decodedBody['message'],
        );
      }

      if (res.statusCode.toString().startsWith('4')) {
        throw UserException(
          status: res.statusCode,
          message: decodedBody['message'],
        );
      }

      if (!res.statusCode.toString().startsWith('2')) {
        throw Exception('An error occurred');
      }

      print(decodedBody);
    } on SocketException {
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
      final res = await http
          .post(
        Uri.parse('${Constants.backendUri}/verify-email-otp'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          '_id': id,
          'emailOtp': otp,
        }),
      )
          .timeout(const Duration(seconds: 10), onTimeout: () {
        throw const SocketException('Connection timed out');
      });

      final decodedBody = jsonDecode(res.body) as Map<String, dynamic>;

      if (res.statusCode.toString().startsWith('5')) {
        throw ServerException(
          status: res.statusCode,
          message: decodedBody['message'],
        );
      }

      if (res.statusCode.toString().startsWith('4')) {
        throw UserException(
          status: res.statusCode,
          message: decodedBody['message'],
        );
      }

      if (!res.statusCode.toString().startsWith('2')) {
        throw Exception('An error occurred');
      }

      print(decodedBody);

      return true;
    } on SocketException {
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
