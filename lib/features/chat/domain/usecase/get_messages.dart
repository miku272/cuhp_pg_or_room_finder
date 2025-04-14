import 'package:fpdart/fpdart.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecase/usecase.dart';

import '../../data/models/message_response.dart';
import '../repository/messages_remote_repository.dart';

class GetMessages implements Usecase<MessageResponse, GetMessagesParam> {
  final MessagesRemoteRepository messagesRemoteRepository;

  GetMessages({required this.messagesRemoteRepository});

  @override
  Future<Either<Failure, MessageResponse>> call(GetMessagesParam params) async {
    return await messagesRemoteRepository.getMessages(
      chatId: params.chatId,
      page: params.page,
      limit: params.limit,
      token: params.token,
    );
  }
}

class GetMessagesParam {
  final String chatId;
  final int page;
  final int limit;
  final String token;

  const GetMessagesParam({
    required this.chatId,
    required this.page,
    required this.limit,
    required this.token,
  });
}
