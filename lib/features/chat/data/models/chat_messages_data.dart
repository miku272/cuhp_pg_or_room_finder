import '../../../../core/common/entities/chat.dart';
import '../../../../core/common/entities/message.dart';

class ChatMessagesData {
  final List<Message> messages;
  final Chat chat;
  final int currentPage;
  final int totalPages;
  final int totalMessages;

  const ChatMessagesData({
    required this.messages,
    required this.chat,
    required this.currentPage,
    required this.totalPages,
    required this.totalMessages,
  });

  ChatMessagesData copyWith({
    List<Message>? messages,
    Chat? chat,
    int? currentPage,
    int? totalPages,
    int? totalMessages,
  }) {
    return ChatMessagesData(
      messages: messages ?? this.messages,
      chat: chat ?? this.chat,
      currentPage: currentPage ?? this.currentPage,
      totalPages: totalPages ?? this.totalPages,
      totalMessages: totalMessages ?? this.totalMessages,
    );
  }
}
