import 'dart:io';

import 'package:dio/dio.dart';

import '../../../../core/error/exception.dart';

import '../models/message_response.dart';

abstract interface class MessagesRemoteDatasource {
  Future<MessageResponse> getMessages(
    String chatId,
    int page,
    int limit,
    String token,
  );
}

class MessagesRemoteDatasourceImpl implements MessagesRemoteDatasource {
  final Dio dio;

  MessagesRemoteDatasourceImpl({required this.dio});

  @override
  Future<MessageResponse> getMessages(
    String chatId,
    int page,
    int limit,
    String token,
  ) async {
    try {
      final res = await dio.get(
        '/chat/messages/$chatId?page=$page&limit=$limit',
        options: Options(
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $token',
          },
        ),
      );

      final decodedBody = res.data;

      final messageResponse = MessageResponse.fromJson(decodedBody);

      return messageResponse;
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
