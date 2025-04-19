import 'dart:async';

import '../../../../core/common/entities/chat.dart';
import '../../../../core/common/entities/message.dart';
import '../../domain/repository/chat_socket_repository.dart';
import '../datasources/chat_socket_datasource.dart';

class ChatSocketRepositoryImpl implements ChatSocketRepository {
  final ChatSocketDataSource _chatSocketDataSource;

  ChatSocketRepositoryImpl({
    required ChatSocketDataSource chatSocketDataSource,
  }) : _chatSocketDataSource = chatSocketDataSource;

  @override
  Future<void> connectSocket() async {
    await _chatSocketDataSource.connectSocket();
  }

  @override
  void disconnectSocket() {
    _chatSocketDataSource.disconnectSocket();
  }

  @override
  void joinChat(String chatId) {
    _chatSocketDataSource.joinChat(chatId);
  }

  @override
  void sendMessage({
    required String chatId,
    required String content,
    required String type,
  }) {
    _chatSocketDataSource.sendMessage(
      chatId: chatId,
      content: content,
      type: type,
    );
  }

  @override
  void sendTypingIndicator(String chatId) {
    _chatSocketDataSource.sendTypingIndicator(chatId);
  }

  @override
  void markMessagesAsRead(String chatId) {
    _chatSocketDataSource.markMessagesAsRead(chatId);
  }

  @override
  Stream<(Chat, Message)> get messageStream =>
      _chatSocketDataSource.messageStream;

  @override
  Stream<Map<String, dynamic>> get typingStream =>
      _chatSocketDataSource.typingStream;

  @override
  Stream<Map<String, dynamic>> get readReceiptStream =>
      _chatSocketDataSource.readReceiptStream;

  @override
  Stream<String> get errorStream => _chatSocketDataSource.errorStream;

  @override
  Stream<bool> get connectionStream => _chatSocketDataSource.connectionStream;

  @override
  bool get isConnected => _chatSocketDataSource.isConnected;
}
