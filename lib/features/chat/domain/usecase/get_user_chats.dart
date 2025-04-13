import 'package:fpdart/fpdart.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecase/usecase.dart';
import '../../data/models/chat.dart';
import '../repository/chat_remote_repository.dart';

class GetUserChats implements Usecase<List<Chat>, GetUserChatsParams> {
  final ChatRemoteRepository chatRemoteRepository;

  GetUserChats({required this.chatRemoteRepository});

  @override
  Future<Either<Failure, List<Chat>>> call(GetUserChatsParams params) async {
    return await chatRemoteRepository.getUserChats(token: params.token);
  }
}

class GetUserChatsParams {
  final String token;

  GetUserChatsParams({required this.token});
}
