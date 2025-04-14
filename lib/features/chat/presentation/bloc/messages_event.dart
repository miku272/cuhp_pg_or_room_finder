part of 'messages_bloc.dart';

@immutable
sealed class MessagesEvent {}

final class GetMessagesViaAPIEvent extends MessagesEvent {
  final String chatId;
  final int page;
  final int limit;
  final String token;

  GetMessagesViaAPIEvent({
    required this.chatId,
    required this.page,
    required this.limit,
    required this.token,
  });
}
