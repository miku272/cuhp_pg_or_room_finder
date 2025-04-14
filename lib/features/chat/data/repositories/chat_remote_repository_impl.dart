import 'package:fpdart/fpdart.dart';

import '../../../../core/error/exception.dart';
import '../../../../core/error/failures.dart';
import '../../domain/repository/chat_remote_repository.dart';
import '../datasources/chat_remote_datasource.dart';
import '../../../../core/common/entities/chat.dart';
import '../../../../core/common/entities/message.dart';

class ChatRemoteRepositoryImpl implements ChatRemoteRepository {
  final ChatRemoteDatasource chatRemoteDatasource;

  ChatRemoteRepositoryImpl({
    required this.chatRemoteDatasource,
  });

  @override
  Future<Either<Failure, Chat>> getChatById({
    required String chatId,
    required String token,
  }) async {
    try {
      final Chat chat = await chatRemoteDatasource.getChatById(chatId, token);

      return right(chat);
    } on ServerException catch (error) {
      return left(Failure(status: error.status, message: error.message));
    } on UserException catch (error) {
      return left(Failure(status: error.status, message: error.message));
    } catch (error) {
      return left(Failure(message: error.toString()));
    }
  }

  @override
  Future<Either<Failure, List<Chat>>> getUserChats({
    required String token,
  }) async {
    try {
      final List<Chat> chats = await chatRemoteDatasource.getUserChats(token);

      return right(chats);
    } on ServerException catch (error) {
      return left(Failure(status: error.status, message: error.message));
    } on UserException catch (error) {
      return left(Failure(status: error.status, message: error.message));
    } catch (error) {
      return left(Failure(message: error.toString()));
    }
  }

  @override
  Future<Either<Failure, Chat>> initializeChat({
    required String propertyId,
    required String token,
  }) async {
    try {
      final Chat chat = await chatRemoteDatasource.initializeChat(
        propertyId,
        token,
      );

      return right(chat);
    } on ServerException catch (error) {
      return left(Failure(status: error.status, message: error.message));
    } on UserException catch (error) {
      return left(Failure(status: error.status, message: error.message));
    } catch (error) {
      return left(Failure(message: error.toString()));
    }
  }

  @override
  Future<Either<Failure, (Chat, Message)>> sendMessage({
    required String content,
    required MessageType type,
    required String chatId,
    required String token,
  }) async {
    try {
      final (Chat, Message) chatAndMessage =
          await chatRemoteDatasource.sendMessage(
        content,
        type,
        chatId,
        token,
      );

      return right(chatAndMessage);
    } on ServerException catch (error) {
      return left(Failure(status: error.status, message: error.message));
    } on UserException catch (error) {
      return left(Failure(status: error.status, message: error.message));
    } catch (error) {
      return left(Failure(message: error.toString()));
    }
  }
}
