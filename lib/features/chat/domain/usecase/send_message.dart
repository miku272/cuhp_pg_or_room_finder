import 'package:fpdart/fpdart.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecase/usecase.dart';
import '../../../../core/common/entities/chat.dart';
import '../../../../core/common/entities/message.dart';
import '../repository/chat_remote_repository.dart';

class SendMessage implements Usecase<(Chat, Message), SendMessageParams> {
  final ChatRemoteRepository chatRemoteRepository;

  SendMessage({required this.chatRemoteRepository});

  @override
  Future<Either<Failure, (Chat, Message)>> call(
    SendMessageParams params,
  ) async {
    return await chatRemoteRepository.sendMessage(
      content: params.content,
      type: params.type,
      chatId: params.chatId,
      token: params.token,
    );
  }
}

class SendMessageParams {
  final String content;
  final MessageType type;
  final String chatId;
  final String token;

  SendMessageParams({
    required this.content,
    required this.type,
    required this.chatId,
    required this.token,
  });
}
