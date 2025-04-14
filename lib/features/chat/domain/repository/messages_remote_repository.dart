import 'package:fpdart/fpdart.dart';

import '../../../../core/error/failures.dart';

import '../../data/models/message_response.dart';

abstract interface class MessagesRemoteRepository {
  Future<Either<Failure, MessageResponse>> getMessages({
    required String chatId,
    required int page,
    required int limit,
    required String token,
  });
}
