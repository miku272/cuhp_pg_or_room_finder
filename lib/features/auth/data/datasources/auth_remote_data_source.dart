import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

import '../../../../core/constants/constants.dart';
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
  @override
  Future<UserModel?> getCurrentUser(String? token, String? id) async {
    if (token == null || token == '' || id == null || id == '') {
      throw UserException(
        status: 401,
        message: 'Unauthorized',
      );
    }

    try {
      final res = await http
          .post(
        Uri.parse('${Constants.backendUri}/auth/token-auth'),
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
  Future<UserModel> loginWithEmailAndPassword(
    String email,
    String password,
  ) async {
    try {
      final res = await http
          .post(
        Uri.parse(
          '${Constants.backendUri}/auth/login-using-email-and-password',
        ),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'email': email,
          'password': password,
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

      final UserModel user = UserModel(
        id: decodedBody['data']['user']['_id'],
        name: decodedBody['data']['user']['name'],
        email: decodedBody['data']['user']['email'],
        phone: decodedBody['data']['user']['phone'],
        isEmailVerified: decodedBody['data']['user']['isEmailVerified'],
        isPhoneVerified: decodedBody['data']['user']['isPhoneVerified'],
        jwtToken: decodedBody['data']['tokenData']['token'],
        expiresIn: decodedBody['data']['tokenData']['expiresIn'],
        createdAt: decodedBody['data']['user']['createdAt'],
        updatedAt: decodedBody['data']['user']['updatedAt'],
      );

      return user;
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
  Future<UserModel> signupWithEmailAndPassword(
    String name,
    String email,
    String password,
  ) async {
    try {
      final res = await http
          .post(
        Uri.parse('${Constants.backendUri}/auth/signup'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'name': name,
          'email': email,
          'password': password,
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

      final UserModel user = UserModel(
        id: decodedBody['data']['user']['_id'],
        name: decodedBody['data']['user']['name'],
        email: decodedBody['data']['user']['email'],
        phone: decodedBody['data']['user']['phone'],
        isEmailVerified: decodedBody['data']['user']['isEmailVerified'],
        isPhoneVerified: decodedBody['data']['user']['isPhoneVerified'],
        jwtToken: decodedBody['data']['tokenData']['token'],
        expiresIn: decodedBody['data']['tokenData']['expiresIn'],
        createdAt: decodedBody['data']['user']['createdAt'],
        updatedAt: decodedBody['data']['user']['updatedAt'],
      );

      return user;
    } on SocketException {
      throw ServerException(
        status: 503,
        message: 'Unable to connect to the server',
      );
    } catch (error) {
      rethrow;
    }
  }
}
