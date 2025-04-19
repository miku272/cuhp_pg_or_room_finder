part of 'messages_bloc.dart';

@immutable
sealed class MessagesEvent {}

// --- API Event ---
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

// --- Socket Action Events (Sent TO SocketManager) ---
final class JoinChatEvent extends MessagesEvent {
  final String chatId;
  JoinChatEvent({required this.chatId});
}

final class SendMessageViaSocketEvent extends MessagesEvent {
  final String chatId;
  final String content;
  final String type; // e.g., 'text', 'image'

  SendMessageViaSocketEvent({
    required this.chatId,
    required this.content,
    required this.type,
  });
}

final class SendTypingIndicatorEvent extends MessagesEvent {
  final String chatId;
  SendTypingIndicatorEvent({required this.chatId});
}

final class MarkMessagesAsReadEvent extends MessagesEvent {
  final String chatId;
  MarkMessagesAsReadEvent({required this.chatId});
}

// --- Internal Bloc Events (FROM AppSocketCubit Listeners) ---
final class _MessageReceived extends MessagesEvent {
  // Data type matches AppSocketCubit.messageStream
  final (Chat, Message) chatMessageTuple;
  _MessageReceived({required this.chatMessageTuple});
}

final class _TypingReceived extends MessagesEvent {
  // Data type matches AppSocketCubit.typingStream
  // Expecting { chatId: string, userId: string, isTyping: bool }
  final Map<String, dynamic> data;
  _TypingReceived({required this.data});
}

final class _TypingTimedOut extends MessagesEvent {
  final String chatId;
  _TypingTimedOut({required this.chatId});
}

final class _ReadReceiptReceived extends MessagesEvent {
  // Data type matches AppSocketCubit.readReceiptStream
  // Expecting { chatId: string, userId: string, readAt: string, chat: Chat } or similar
  final Map<String, dynamic> data;
  _ReadReceiptReceived({required this.data});
}
