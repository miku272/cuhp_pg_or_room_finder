import '../../../../core/common/entities/chat.dart';
import '../../../../core/common/entities/message.dart';
import '../../domain/repository/messages_socket_repository.dart';
import '../datasources/messages_socket_datasource.dart';

class MessagesSocketRepositoryImpl implements MessagesSocketRepository {
  final MessagesSocketDatasource _messagesSocketDatasource;

  MessagesSocketRepositoryImpl({
    required MessagesSocketDatasource messagesSocketDatasource,
  }) : _messagesSocketDatasource = messagesSocketDatasource;

  @override
  Future<void> connect() async {
    await _messagesSocketDatasource.connectSocket();
  }

  @override
  void disconnect() {
    _messagesSocketDatasource.disconnectSocket();
  }

  @override
  void joinChat(String chatId) {
    _messagesSocketDatasource.joinChat(chatId);
  }

  @override
  void sendMessage({
    required String chatId,
    required String content,
    required String type,
  }) {
    _messagesSocketDatasource.sendMessage(
      chatId: chatId,
      content: content,
      type: type,
    );
  }

  @override
  void sendTypingIndicator(String chatId) {
    _messagesSocketDatasource.sendTypingIndicator(chatId);
  }

  @override
  void markMessagesAsRead(String chatId) {
    _messagesSocketDatasource.markMessagesAsRead(chatId);
  }

  @override
  Stream<(Chat, Message)> get messageStream =>
      _messagesSocketDatasource.messageStream;
  @override
  Stream<Map<String, dynamic>> get typingStream =>
      _messagesSocketDatasource.typingStream;
  @override
  Stream<Map<String, dynamic>> get readReceiptStream =>
      _messagesSocketDatasource.readReceiptStream;
  @override
  Stream<String> get errorStream => _messagesSocketDatasource.errorStream;
  @override
  Stream<bool> get connectionStream =>
      _messagesSocketDatasource.connectionStream;
  @override
  bool get isConnected => _messagesSocketDatasource.isConnected;
}
