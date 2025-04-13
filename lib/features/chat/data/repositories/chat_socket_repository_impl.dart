import 'dart:async';

import '../models/chat.dart';
import '../models/message.dart';

import '../../../../core/socket/socket_manager.dart';
import '../../domain/repository/chat_socket_repository.dart';

class ChatSocketRepositoryImpl implements ChatSocketRepository {
  final SocketManager _socketManager;
  final String _baseUrl;

  ChatSocketRepositoryImpl({
    SocketManager? socketManager,
    required String baseUrl,
  })  : _socketManager = socketManager ?? SocketManager(),
        _baseUrl = baseUrl;

  @override
  Future<void> connectSocket() async {
    await _socketManager.initialize(_baseUrl);
  }

  @override
  void disconnectSocket() {
    _socketManager.disconnect();
  }

  @override
  void joinChat(String chatId) {
    _socketManager.client.joinChat(chatId);
  }

  @override
  void sendMessage({
    required String chatId,
    required String content,
    required String type,
  }) {
    _socketManager.client.sendMessage(
      chatId: chatId,
      content: content,
      type: type,
    );
  }

  @override
  void sendTypingIndicator(String chatId) {
    _socketManager.client.sendTypingIndicator(chatId);
  }

  @override
  void markMessagesAsRead(String chatId) {
    _socketManager.client.markMessageAsRead(chatId);
  }

  @override
  Stream<(Chat, Message)> get messageStream =>
      _socketManager.eventHandler.messageStream;

  @override
  Stream<Map<String, dynamic>> get typingStream =>
      _socketManager.eventHandler.typingStream;

  @override
  Stream<Map<String, dynamic>> get readReceiptStream =>
      _socketManager.eventHandler.readReceiptStream;

  @override
  Stream<String> get errorStream => _socketManager.eventHandler.errorStream;

  @override
  Stream<bool> get connectionStream => _socketManager.client.connectionStream;

  @override
  bool get isConnected => _socketManager.isConnected;
}
