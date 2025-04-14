import 'package:fpdart/fpdart.dart';

import '../../../../core/error/exception.dart';
import '../../../../core/error/failures.dart';

import '../../domain/repository/messages_remote_repository.dart';
import '../datasources/messages_remote_datasource.dart';

import '../models/message_response.dart';

class MessagesRemoteRepositoryImpl implements MessagesRemoteRepository {
  final MessagesRemoteDatasource messagesRemoteDatasource;

  MessagesRemoteRepositoryImpl({
    required this.messagesRemoteDatasource,
  });

  @override
  Future<Either<Failure, MessageResponse>> getMessages({
    required String chatId,
    required int page,
    required int limit,
    required String token,
  }) async {
    try {
      final MessageResponse messageResponse =
          await messagesRemoteDatasource.getMessages(
        chatId,
        page,
        limit,
        token,
      );

      return right(messageResponse);
    } on ServerException catch (error) {
      return left(Failure(status: error.status, message: error.message));
    } on UserException catch (error) {
      return left(Failure(status: error.status, message: error.message));
    } catch (error) {
      return left(Failure(message: error.toString()));
    }
  }
}
