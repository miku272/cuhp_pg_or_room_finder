import '../../../../core/common/entities/chat.dart';
import '../../../../core/common/entities/message.dart';
import '../../../../core/socket/socket_manager.dart';

abstract interface class MessagesSocketDatasource {
  Future<void> connectSocket();
  void disconnectSocket();
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

class MessagesSocketDatasourceImpl implements MessagesSocketDatasource {
  final SocketManager _socketManager;
  final String _baseUrl;

  MessagesSocketDatasourceImpl({
    required SocketManager socketManager,
    required String baseUrl,
  })  : _socketManager = socketManager,
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
