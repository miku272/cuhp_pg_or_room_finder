import 'package:fpdart/fpdart.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecase/usecase.dart';
import '../../../../core/common/entities/chat.dart';
import '../repository/chat_remote_repository.dart';

class GetChatById implements Usecase<Chat, GetChatByIdParams> {
  final ChatRemoteRepository chatRemoteRepository;

  GetChatById({required this.chatRemoteRepository});

  @override
  Future<Either<Failure, Chat>> call(GetChatByIdParams params) async {
    return await chatRemoteRepository.getChatById(
      chatId: params.chatId,
      token: params.token,
    );
  }
}

class GetChatByIdParams {
  final String chatId;
  final String token;

  GetChatByIdParams({
    required this.chatId,
    required this.token,
  });
}
