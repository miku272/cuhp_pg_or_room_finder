part of 'chat_bloc.dart';

enum ChatStatus {
  initial,
  loading,
  loadingChats, // Specific loading for chat list
  success, // General success or socket connected
  chatsLoaded, // Specific success for chat list loaded/updated
  failure,
}

@immutable
final class ChatState {
  final ChatStatus status;
  final List<Chat> chats;
  final bool isSocketConnected;
  final String? errorMessage;
  final int? errorStatus;
  final Chat? newlyInitializedChat; // For InitializeChat result
  final Chat? newlyFetchedChat; // For GetChatById result
  final Message? newlySentMessage; // For SendMessage result
  final Map<String, dynamic>? typingData; // { chatId: string, userId: string }
  final Map<String, dynamic>?
      readReceiptData; // { chatId: string, userId: string }

  const ChatState({
    this.status = ChatStatus.initial,
    this.chats = const [],
    this.isSocketConnected = false,
    this.errorMessage,
    this.errorStatus,
    this.newlyInitializedChat,
    this.newlyFetchedChat,
    this.newlySentMessage,
    this.typingData,
    this.readReceiptData,
  });

  ChatState copyWith({
    ChatStatus? status,
    List<Chat>? chats,
    bool? isSocketConnected,
    String? errorMessage,
    int? errorStatus,
    Chat? newlyInitializedChat,
    Chat? newlyFetchedChat,
    Message? newlySentMessage,
    Map<String, dynamic>? typingData,
    Map<String, dynamic>? readReceiptData,
    bool clearError = false, // Helper to clear error message easily
    bool clearNewlyInitializedChat = false,
    bool clearNewlyFetchedChat = false,
    bool clearNewlySentMessage = false,
    bool clearTypingData = false,
    bool clearReadReceiptData = false,
  }) {
    return ChatState(
      status: status ?? this.status,
      chats: chats ?? this.chats,
      isSocketConnected: isSocketConnected ?? this.isSocketConnected,
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
      typingData: clearTypingData ? null : typingData ?? this.typingData,
      readReceiptData:
          clearReadReceiptData ? null : readReceiptData ?? this.readReceiptData,
    );
  }
}
