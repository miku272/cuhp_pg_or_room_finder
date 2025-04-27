import 'dart:io';

import 'package:dio/dio.dart';

import '../../../../core/error/exception.dart';

import '../../../../core/common/entities/chat.dart';
import '../../../../core/common/entities/message.dart';

abstract interface class ChatRemoteDatasource {
  Future<Chat> initializeChat(String propertyId, String token);
  Future<List<Chat>> getUserChats(String token);
  Future<Chat> getChatById(String chatId, String token);
  Future<(Chat, Message)> sendMessage(
    String content,
    MessageType type,
    String chatId,
    String token,
  );
}

class ChatRemoteDatasourceImpl implements ChatRemoteDatasource {
  final Dio dio;

  ChatRemoteDatasourceImpl({required this.dio});

  @override
  Future<Chat> initializeChat(String propertyId, String token) async {
    try {
      final res = await dio.post('/chat/initialize',
          options: Options(headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $token',
          }),
          data: {
            'propertyId': propertyId,
          });

      final decodedBody = res.data;

      final Chat chat = Chat.fromJson(decodedBody['data']);

      return chat;
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
  Future<Chat> getChatById(String chatId, String token) async {
    try {
      final res = await dio.get(
        '/chat/$chatId',
        options: Options(
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $token',
          },
        ),
      );

      final decodedBody = res.data;

      final Chat chat = Chat.fromJson(decodedBody['data']);

      return chat;
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
  Future<List<Chat>> getUserChats(String token) async {
    try {
      final res = await dio.get(
        '/chat/user-chats',
        options: Options(
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $token',
          },
        ),
      );

      final decodedBody = res.data;

      final List<Chat> chats = (decodedBody['data']['chats'] as List)
          .map((chat) => Chat.fromJson(chat))
          .toList();

      return chats;
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
  Future<(Chat, Message)> sendMessage(
    String content,
    MessageType type,
    String chatId,
    String token,
  ) async {
    try {
      final res = await dio.post(
        '/chat/send',
        options: Options(
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $token',
          },
        ),
        data: {
          'chatId': chatId,
          'content': content,
          'type': type.name,
        },
      );

      final decodedBody = res.data;

      final chat = Chat.fromJson(decodedBody['data']['chat']);
      final message = Message.fromJson(decodedBody['data']['newMessage']);

      return (chat, message);
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
