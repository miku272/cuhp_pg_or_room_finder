import '../../../../core/common/entities/chat.dart';
import '../../../../core/common/entities/message.dart';

class MessageResponse {
  final int resultsLength;
  final int currentPage;
  final int totalPages;
  final int totalMessages;
  final Chat chat;
  final List<Message> messages;

  MessageResponse({
    required this.resultsLength,
    required this.currentPage,
    required this.totalPages,
    required this.totalMessages,
    required this.chat,
    required this.messages,
  });

  factory MessageResponse.fromJson(Map<String, dynamic> json) {
    final data = json['data'] as Map<String, dynamic>;
    final messagesList = (data['messages'] as List)
        .map((messageJson) =>
            Message.fromJson(messageJson as Map<String, dynamic>))
        .toList();

    return MessageResponse(
      resultsLength: json['resultsLength'] as int,
      currentPage: json['currentPage'] as int,
      totalPages: json['totalPages'] as int,
      totalMessages: json['totalMessages'] as int,
      chat: Chat.fromJson(data['chat'] as Map<String, dynamic>),
      messages: messagesList,
    );
  }

  MessageResponse copyWith({
    int? resultsLength,
    int? currentPage,
    int? totalPages,
    int? totalMessages,
    Chat? chat,
    List<Message>? messages,
  }) {
    return MessageResponse(
      resultsLength: resultsLength ?? this.resultsLength,
      currentPage: currentPage ?? this.currentPage,
      totalPages: totalPages ?? this.totalPages,
      totalMessages: totalMessages ?? this.totalMessages,
      chat: chat ?? this.chat,
      messages: messages ?? this.messages,
    );
  }
}
