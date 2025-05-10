part of 'messages_bloc.dart';

@immutable
sealed class MessagesState {
  // final bool isSocketConnected; // REMOVED - Get from AppSocketCubit
  final Map<String, ChatMessagesData> chatData;
  final Map<String, bool>
      typingStatus; // Key: ChatID, Value: isTyping (true/false)
  final Map<String, Map<String, dynamic>>
      readReceipts; // Key: ChatID, Value: Raw receipt data
  // final String? socketErrorMessage; // REMOVED - Get from AppSocketCubit

  const MessagesState({
    // this.isSocketConnected = false, // REMOVED
    this.chatData = const {},
    this.typingStatus = const {},
    this.readReceipts = const {},
    // this.socketErrorMessage, // REMOVED
  });

  // Base copyWith - concrete states should override if they have specific fields
  MessagesState copyWith({
    // bool? isSocketConnected, // REMOVED
    Map<String, ChatMessagesData>? chatData,
    Map<String, bool>? typingStatus,
    Map<String, Map<String, dynamic>>? readReceipts,
    // String? socketErrorMessage, // REMOVED
    // bool clearSocketError = false, // REMOVED
  }) {
    // This base copyWith might not be directly used if all states are concrete,
    // but serves as a template. Return a default state or handle appropriately.
    // Returning a concrete state is generally better.
    return MessagesConcreteState(
      chatData: chatData ?? this.chatData,
      typingStatus: typingStatus ?? this.typingStatus,
      readReceipts: readReceipts ?? this.readReceipts,
    );
  }
}

// Concrete state class to allow copyWith and hold common data
final class MessagesConcreteState extends MessagesState {
  const MessagesConcreteState({
    super.chatData,
    super.typingStatus,
    super.readReceipts,
  });

  @override
  MessagesConcreteState copyWith({
    Map<String, ChatMessagesData>? chatData,
    Map<String, bool>? typingStatus,
    Map<String, Map<String, dynamic>>? readReceipts,
  }) {
    return MessagesConcreteState(
      chatData: chatData ?? this.chatData,
      typingStatus: typingStatus ?? this.typingStatus,
      readReceipts: readReceipts ?? this.readReceipts,
    );
  }
}

final class MessagesInitial extends MessagesState {
  const MessagesInitial({
    super.chatData = const {},
    super.typingStatus = const {},
    super.readReceipts = const {},
  });
}

// Loading state specifically for API calls
final class MessagesLoadingAPI extends MessagesState {
  final String loadingChatId; // Indicate which chat is loading
  const MessagesLoadingAPI({
    required this.loadingChatId,
    required super.chatData,
    required super.typingStatus,
    required super.readReceipts,
  });
}

// Success state specifically for API calls
final class GetMessagesViaAPISuccess extends MessagesState {
  const GetMessagesViaAPISuccess({
    required super.chatData,
    required super.typingStatus,
    required super.readReceipts,
  });
}

// Failure state specifically for API calls
final class GetMessagesViaAPIFailure extends MessagesState {
  final int? status;
  final String message;
  final String failedChatId;
  final int failedPage; // Keep track of the page that failed

  const GetMessagesViaAPIFailure({
    required this.status,
    required this.message,
    required this.failedChatId,
    required this.failedPage,
    required super.chatData, // Keep existing data
    required super.typingStatus,
    required super.readReceipts,
  });
}

// State indicating a general update or socket-related success (optional)
// Could be merged with MessagesConcreteState if no specific indication is needed
final class MessagesUpdated extends MessagesState {
  const MessagesUpdated({
    required super.chatData,
    required super.typingStatus,
    required super.readReceipts,
  });
}

// General failure state (could be used for non-API errors if needed, though AppSocketCubit handles socket errors)
// Might be removable if API failures are handled specifically and socket errors are observed elsewhere.
// final class MessagesFailure extends MessagesState {
//   final int? status; // Optional status code
//   final String message;

//   const MessagesFailure({
//     required this.message,
//     this.status,
//     required super.chatData,
//     required super.typingStatus,
//     required super.readReceipts,
//   });
// }
