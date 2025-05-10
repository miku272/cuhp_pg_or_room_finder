part of 'chat_bloc.dart';

enum ChatStatus {
  initial,
  loading,
  loadingChats,
  success, // General success
  chatsLoaded,
  failure,
}

@immutable
final class ChatState {
  final ChatStatus status;
  final List<Chat> chats;
  final String? errorMessage;
  final int? errorStatus;
  final Chat? newlyInitializedChat;
  final Chat? newlyFetchedChat;
  final Message? newlySentMessage;
  final Map<String, String>
      typingUserIdByChatId; // Key: ChatID, Value: UserID of typer
  final Map<String, dynamic>? readReceiptData;

  const ChatState({
    this.status = ChatStatus.initial,
    this.chats = const [],
    this.errorMessage,
    this.errorStatus,
    this.newlyInitializedChat,
    this.newlyFetchedChat,
    this.newlySentMessage,
    this.typingUserIdByChatId = const {},
    this.readReceiptData,
  });

  ChatState copyWith({
    ChatStatus? status,
    List<Chat>? chats,
    String? errorMessage,
    int? errorStatus,
    Chat? newlyInitializedChat,
    Chat? newlyFetchedChat,
    Message? newlySentMessage,
    Map<String, String>? typingUserIdByChatId,
    Map<String, dynamic>? readReceiptData,
    bool clearError = false,
    bool clearNewlyInitializedChat = false,
    bool clearNewlyFetchedChat = false,
    bool clearNewlySentMessage = false,
    bool clearReadReceiptData = false,
  }) {
    return ChatState(
      status: status ?? this.status,
      chats: chats ?? this.chats,
      errorMessage: clearError ? null : errorMessage ?? this.errorMessage,
      errorStatus: clearError ? null : errorStatus ?? this.errorStatus,
      newlyInitializedChat: clearNewlyInitializedChat
          ? null
          : newlyInitializedChat ?? this.newlyInitializedChat,
      newlyFetchedChat: clearNewlyFetchedChat
          ? null
          : newlyFetchedChat ?? this.newlyFetchedChat,
      newlySentMessage: clearNewlySentMessage
          ? null
          : newlySentMessage ?? this.newlySentMessage,
      typingUserIdByChatId: typingUserIdByChatId ?? this.typingUserIdByChatId,
      readReceiptData:
          clearReadReceiptData ? null : readReceiptData ?? this.readReceiptData,
    );
  }
}

final class ChatInitial extends ChatState {
  const ChatInitial({
    super.status = ChatStatus.initial,
    super.chats = const [],
    super.errorMessage,
    super.errorStatus,
    super.newlyInitializedChat,
    super.newlyFetchedChat,
    super.newlySentMessage,
    super.typingUserIdByChatId = const {},
    super.readReceiptData,
  });
}
