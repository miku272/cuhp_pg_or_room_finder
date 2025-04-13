import 'package:fpdart/fpdart.dart';

import '../../../../core/error/failures.dart';

import '../../data/models/chat.dart';
import '../../data/models/message.dart';

abstract interface class ChatRemoteRepository {
  Future<Either<Failure, Chat>> initializeChat({
    required String propertyId,
    required String token,
  });

  Future<Either<Failure, List<Chat>>> getUserChats({
    required String token,
  });

  Future<Either<Failure, Chat>> getChatById({
    required String chatId,
    required String token,
  });

  Future<Either<Failure, (Chat, Message)>> sendMessage({
    required String content,
    required MessageType type,
    required String chatId,
    required String token,
  });
}
