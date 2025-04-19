import '../../../../core/common/entities/chat.dart';
import '../../../../core/common/entities/message.dart';

abstract interface class MessagesSocketRepository {
  Future<void> connect();
  void disconnect();
  void joinChat(String chatId);
  void sendMessage({
    required String chatId,
    required String content,
    required String type,
  });
  void sendTypingIndicator(String chatId);
  void markMessagesAsRead(String chatId);

  Stream<(Chat, Message)> get messageStream;
  Stream<Map<String, dynamic>> get typingStream;
  Stream<Map<String, dynamic>> get readReceiptStream;
  Stream<String> get errorStream;
  Stream<bool> get connectionStream;
  bool get isConnected;
}
