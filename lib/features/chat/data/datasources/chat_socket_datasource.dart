import 'dart:async';

import '../../../../core/common/entities/chat.dart';
import '../../../../core/common/entities/message.dart';

import '../../domain/repository/chat_socket_repository.dart';
import '../repositories/chat_socket_repository_impl.dart';

class ChatSocketDataSource {
  final ChatSocketRepository _repository;

  ChatSocketDataSource({
    ChatSocketRepository? repository,
    required String baseUrl,
  }) : _repository = repository ?? ChatSocketRepositoryImpl(baseUrl: baseUrl);

  Future<void> connect() async {
    await _repository.connectSocket();
  }

  void disconnect() {
    _repository.disconnectSocket();
  }

  void joinChat(String chatId) {
    _repository.joinChat(chatId);
  }

  void sendMessage({
    required String chatId,
    required String content,
    required String type,
  }) {
    _repository.sendMessage(
      chatId: chatId,
      content: content,
      type: type,
    );
  }

  void sendTypingIndicator(String chatId) {
    _repository.sendTypingIndicator(chatId);
  }

  void markMessagesAsRead(String chatId) {
    _repository.markMessagesAsRead(chatId);
  }

  Stream<(Chat, Message)> get messageStream => _repository.messageStream;
  Stream<Map<String, dynamic>> get typingStream => _repository.typingStream;
  Stream<Map<String, dynamic>> get readReceiptStream =>
      _repository.readReceiptStream;
  Stream<String> get errorStream => _repository.errorStream;
  Stream<bool> get connectionStream => _repository.connectionStream;
  bool get isConnected => _repository.isConnected;
}
