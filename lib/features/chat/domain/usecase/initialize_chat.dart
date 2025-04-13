import 'package:fpdart/fpdart.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecase/usecase.dart';

import '../../data/models/chat.dart';
import '../repository/chat_remote_repository.dart';

class InitializeChat implements Usecase<Chat, InitializeChatParams> {
  final ChatRemoteRepository chatRemoteRepository;

  InitializeChat({required this.chatRemoteRepository});

  @override
  Future<Either<Failure, Chat>> call(InitializeChatParams params) async {
    return await chatRemoteRepository.initializeChat(
      propertyId: params.propertyId,
      token: params.token,
    );
  }
}

class InitializeChatParams {
  final String propertyId;
  final String token;

  InitializeChatParams({required this.propertyId, required this.token});
}
