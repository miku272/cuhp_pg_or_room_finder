part of 'chat_bloc.dart';

@immutable
sealed class ChatEvent {}

// --- Remote/REST Events ---

final class ChatFetchUserChats extends ChatEvent {
  final String token;
  ChatFetchUserChats({required this.token});
}

final class ChatFetchChatById extends ChatEvent {
  final String chatId;
  final String token;
  ChatFetchChatById({required this.chatId, required this.token});
}

final class ChatInitializeChat extends ChatEvent {
  final String propertyId;
  final String token;
  ChatInitializeChat({required this.propertyId, required this.token});
}

// Renamed from ChatRemoteSendMessage to avoid conflict with socket send
final class ChatSendMessageViaApi extends ChatEvent {
  final String content;
  final MessageType type;
  final String chatId;
  final String token;
  ChatSendMessageViaApi({
    required this.content,
    required this.type,
    required this.chatId,
    required this.token,
  });
}

// --- Socket Events ---

final class ChatConnectSocket extends ChatEvent {}

final class ChatDisconnectSocket extends ChatEvent {}

final class ChatJoinRoom extends ChatEvent {
  final String chatId;
  ChatJoinRoom({required this.chatId});
}

// Renamed from ChatSocketSendMessage
final class ChatSendMessageViaSocket extends ChatEvent {
  final String chatId;
  final String content;
  final String type; // Assuming type is string for socket emission
  ChatSendMessageViaSocket({
    required this.chatId,
    required this.content,
    required this.type,
  });
}

final class ChatSendTypingIndicator extends ChatEvent {
  final String chatId;
  ChatSendTypingIndicator({required this.chatId});
}

final class ChatMarkMessagesAsRead extends ChatEvent {
  final String chatId;
  ChatMarkMessagesAsRead({required this.chatId});
}

// --- Internal Bloc Events (from Socket Listeners) ---

final class _ChatMessageReceived extends ChatEvent {
  final (Chat, Message) chatMessageTuple;
  _ChatMessageReceived({required this.chatMessageTuple});
}

final class _ChatTypingReceived extends ChatEvent {
  final Map<String, dynamic> data;
  _ChatTypingReceived({required this.data});
}

final class _ChatReadReceiptReceived extends ChatEvent {
  final Map<String, dynamic> data; // { chatId: string, userId: string }
  _ChatReadReceiptReceived({required this.data});
}

final class _ChatErrorReceived extends ChatEvent {
  final String message;
  _ChatErrorReceived({required this.message});
}

final class _ChatConnectionChanged extends ChatEvent {
  final bool isConnected;
  _ChatConnectionChanged({required this.isConnected});
}
