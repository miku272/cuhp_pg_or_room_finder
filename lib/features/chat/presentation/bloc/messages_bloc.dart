import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

// Core imports
import '../../../../core/common/cubits/app_socket/app_socket_cubit.dart';
import '../../../../core/common/cubits/app_user/app_user_cubit.dart';
import '../../../../core/common/entities/chat.dart';
import '../../../../core/common/entities/message.dart';
import '../../../../core/common/entities/user.dart';
import '../../../../core/socket/socket_manager.dart';

// Data/Domain imports
import '../../data/models/chat_messages_data.dart';
import '../../data/models/message_response.dart';
import '../../domain/usecase/get_messages.dart'; // API UseCase

part 'messages_state.dart';
part 'messages_event.dart';

class MessagesBloc extends Bloc<MessagesEvent, MessagesState> {
  final GetMessages _getMessages; // API UseCase
  final AppUserCubit _appUserCubit;
  final SocketManager _socketManager; // For sending socket events
  final AppSocketCubit
      _appSocketCubit; // For listening to socket events & status

  // Stream Subscriptions to AppSocketCubit streams
  StreamSubscription? _messageSubscription;
  StreamSubscription? _typingSubscription;
  StreamSubscription? _readReceiptSubscription;
  // REMOVED: _errorSubscription, _connectionSubscription

  // Timer map to manage typing indicators timeout
  final Map<String, Timer> _typingTimers = {};

  MessagesBloc({
    required GetMessages getMessages,
    required AppUserCubit appUserCubit,
    required SocketManager socketManager,
    required AppSocketCubit appSocketCubit,
  })  : _getMessages = getMessages,
        _appUserCubit = appUserCubit,
        _socketManager = socketManager,
        _appSocketCubit = appSocketCubit,
        super(MessagesInitial()) {
    // Initial state doesn't need connection info

    // Register event handlers
    on<GetMessagesViaAPIEvent>(_onGetMessagesViaAPIEvent);

    // Socket Action Handlers (Emit events via SocketManager)
    on<JoinChatEvent>(_onJoinChat);
    on<SendMessageViaSocketEvent>(_onSendMessageViaSocket);
    on<SendTypingIndicatorEvent>(_onSendTypingIndicator);
    on<MarkMessagesAsReadEvent>(_onMarkMessagesAsRead);

    // Internal handlers for messages received via AppSocketCubit streams
    on<_MessageReceived>(_onMessageReceived);
    on<_TypingReceived>(_onTypingReceived);
    on<_ReadReceiptReceived>(_onReadReceiptReceived);
    on<_TypingTimedOut>(_onTypingTimedOut);

    // Start listening to AppSocketCubit streams
    _listenToSocketEvents();

    // REMOVED: ConnectSocketEvent handler
    // REMOVED: DisconnectSocketEvent handler
    // REMOVED: _ErrorReceived handler
    // REMOVED: _ConnectionChanged handler
  }

  void _listenToSocketEvents() {
    _cancelListeners(); // Ensure no duplicates

    _messageSubscription = _appSocketCubit.messageStream.listen(
      (chatMessageTuple) {
        // Ensure the data is the expected tuple type
        if (chatMessageTuple is (Chat, Message)) {
          add(_MessageReceived(chatMessageTuple: chatMessageTuple));
        } else {
          debugPrint(
              "MessagesBloc: Received unexpected message data type: ${chatMessageTuple.runtimeType}");
        }
      },
      onError: (error) {
        // Errors are handled by AppSocketCubit's state, but log if needed
        debugPrint("MessagesBloc: Error on message stream: $error");
      },
    );

    _typingSubscription = _appSocketCubit.typingStream.listen(
      (data) {
        // Assuming data is Map<String, dynamic> based on server event
        add(_TypingReceived(data: data));
      },
      onError: (error) {
        debugPrint("MessagesBloc: Error on typing stream: $error");
      },
    );

    _readReceiptSubscription = _appSocketCubit.readReceiptStream.listen(
      (data) {
        // Assuming data is Map<String, dynamic>
        add(_ReadReceiptReceived(data: data));
      },
      onError: (error) {
        debugPrint("MessagesBloc: Error on read receipt stream: $error");
      },
    );
    debugPrint("MessagesBloc: Subscribed to AppSocketCubit streams.");
  }

  void _cancelListeners() {
    _messageSubscription?.cancel();
    _typingSubscription?.cancel();
    _readReceiptSubscription?.cancel();
    _messageSubscription = null;
    _typingSubscription = null;
    _readReceiptSubscription = null;
    debugPrint("MessagesBloc: Unsubscribed from AppSocketCubit streams.");
  }

  User? get _currentUser => _appUserCubit.user;
  // Check connection status via AppSocketCubit
  bool get _isConnected => _appSocketCubit.isConnected;

  // --- API Event Handler ---
  Future<void> _onGetMessagesViaAPIEvent(
    GetMessagesViaAPIEvent event,
    Emitter<MessagesState> emit,
  ) async {
    // Emit loading state specific to the API call
    emit(MessagesLoadingAPI(
      loadingChatId: event.chatId,
      chatData: state.chatData,
      typingStatus: state.typingStatus,
      readReceipts: state.readReceipts,
    ));

    final res = await _getMessages(GetMessagesParam(
      chatId: event.chatId,
      page: event.page,
      limit: event.limit,
      token: event.token,
    ));

    res.fold(
      (failure) => emit(GetMessagesViaAPIFailure(
        status: failure.status,
        message: failure.message,
        failedChatId: event.chatId,
        failedPage: state.chatData[event.chatId]?.currentPage ??
            event.page, // Use event.page if data doesn't exist yet
        // Preserve existing state
        chatData: state.chatData,
        typingStatus: state.typingStatus,
        readReceipts: state.readReceipts,
      )),
      (MessageResponse messageResponse) {
        final currentChatData = state.chatData[event.chatId];
        final newMessages = messageResponse.messages;

        // Combine messages: Prepend old messages if loading page > 1
        final allMessages = (currentChatData != null && event.page > 1)
            ? [
                ...newMessages,
                ...currentChatData.messages
              ] // Prepend new (older) messages
            : newMessages;

        // Ensure uniqueness (optional, but good practice)
        final uniqueMessages = <Message>[];
        final uniqueIds = <String>{};
        for (final message in allMessages) {
          if (uniqueIds.add(message.id)) {
            uniqueMessages.add(message);
          }
        }

        // Sort messages by creation time (ascending for chat display)
        uniqueMessages.sort((a, b) => a.createdAt.compareTo(b.createdAt));

        final updatedChatData = ChatMessagesData(
          messages: uniqueMessages,
          chat: messageResponse.chat, // Use the chat info from the response
          currentPage: messageResponse.currentPage,
          totalPages: messageResponse.totalPages,
          totalMessages: messageResponse.totalMessages,
        );

        final newChatDataMap =
            Map<String, ChatMessagesData>.from(state.chatData);
        newChatDataMap[event.chatId] = updatedChatData;

        emit(GetMessagesViaAPISuccess(
          chatData: newChatDataMap,
          typingStatus: state.typingStatus,
          readReceipts: state.readReceipts,
        ));
      },
    );
  }

  // --- Socket Action Event Handlers (Use SocketManager) ---

  void _onJoinChat(JoinChatEvent event, Emitter<MessagesState> emit) {
    if (_isConnected) {
      debugPrint("MessagesBloc: Joining chat room ${event.chatId}");
      _socketManager.client.joinChat(event.chatId);
      // No state change needed here unless tracking joined rooms specifically in this bloc
    } else {
      debugPrint(
          "MessagesBloc: Cannot join chat ${event.chatId}, socket not connected.");
      // Error state is handled by AppSocketCubit, UI should react to that.
      // Avoid emitting redundant error states here.
    }
  }

  void _onSendMessageViaSocket(
    SendMessageViaSocketEvent event,
    Emitter<MessagesState> emit,
  ) {
    if (_isConnected) {
      debugPrint("MessagesBloc: Sending message via socket to ${event.chatId}");
      _socketManager.client.sendMessage(
        chatId: event.chatId,
        content: event.content,
        type: event.type,
      );
      // Optimistic UI update could happen here by adding a temporary message
      // to the state, but relying on the _MessageReceived event is more robust.
    } else {
      debugPrint(
          "MessagesBloc: Cannot send message to ${event.chatId}, socket not connected.");
      // Error state is handled by AppSocketCubit.
    }
  }

  void _onSendTypingIndicator(
    SendTypingIndicatorEvent event,
    Emitter<MessagesState> emit,
  ) {
    if (_isConnected) {
      debugPrint("MessagesBloc: Sending typing indicator for ${event.chatId}");
      _socketManager.client.sendTypingIndicator(event.chatId);
    } else {
      debugPrint(
          "MessagesBloc: Cannot send typing indicator for ${event.chatId}, socket not connected.");
      // Error state is handled by AppSocketCubit.
    }
  }

  void _onMarkMessagesAsRead(
    MarkMessagesAsReadEvent event,
    Emitter<MessagesState> emit,
  ) {
    if (_isConnected) {
      debugPrint("MessagesBloc: Marking messages as read for ${event.chatId}");
      _socketManager.client.markMessageAsRead(event.chatId);
      // State update will happen via _ReadReceiptReceived if the server confirms.
      // Optimistic update could happen here if desired.
    } else {
      debugPrint(
          "MessagesBloc: Cannot mark messages as read for ${event.chatId}, socket not connected.");
      // Error state is handled by AppSocketCubit.
    }
  }

  // --- Internal Socket Listener Event Handlers (Triggered by _listenToSocketEvents) ---

  void _onMessageReceived(
    _MessageReceived event,
    Emitter<MessagesState> emit,
  ) {
    final (receivedChat, receivedMessage) = event.chatMessageTuple;
    final chatId = receivedMessage.chatId; // Or receivedChat.id
    debugPrint(
        "MessagesBloc: Received message for chat $chatId via AppSocketCubit stream");

    final currentChatMessagesData = state.chatData[chatId];
    if (currentChatMessagesData == null) {
      debugPrint(
          "MessagesBloc: Received message for chat $chatId which is not currently loaded in this BLoC. Ignoring.");
      // If this screen should display messages for *any* chat the user is in,
      // you might need to fetch initial data or create a new entry.
      // For a typical message screen focused on one chat, this might be okay.
      return;
    }

    // Add the new message, ensuring uniqueness and order
    final existingMessages = currentChatMessagesData.messages;
    final messageExists =
        existingMessages.any((m) => m.id == receivedMessage.id);

    if (messageExists) {
      debugPrint(
          "MessagesBloc: Received duplicate message ${receivedMessage.id}. Ignoring.");
      return; // Avoid adding duplicates
    }

    final updatedMessages = [...existingMessages, receivedMessage];
    // Sort messages by creation time (ascending for chat display)
    updatedMessages.sort((a, b) => a.createdAt.compareTo(b.createdAt));

    // Use the receivedChat object to update chat details (like last message info)
    final updatedChatData = currentChatMessagesData.copyWith(
      messages: updatedMessages,
      chat: receivedChat,
      // Update pagination info if the receivedChat contains it, otherwise keep existing
      currentPage: currentChatMessagesData.currentPage,
      totalPages: currentChatMessagesData.totalPages,
      totalMessages: (currentChatMessagesData.totalMessages + 1),
    );

    final newChatDataMap = Map<String, ChatMessagesData>.from(state.chatData);
    newChatDataMap[chatId] = updatedChatData;

    // If the user who sent the message was previously marked as typing, clear it
    final newTypingStatus = Map<String, bool>.from(state.typingStatus);
    if (newTypingStatus[chatId] == true &&
        receivedMessage.senderId != _currentUser?.id) {
      newTypingStatus[chatId] = false;
      _typingTimers[chatId]
          ?.cancel(); // Cancel any existing timer for this chat
      _typingTimers.remove(chatId);
    }

    emit(MessagesUpdated(
      // Use a specific state or the concrete state
      chatData: newChatDataMap,
      typingStatus: newTypingStatus, // Pass updated typing status
      readReceipts: state.readReceipts,
    ));
  }

  void _onTypingReceived(
    _TypingReceived event,
    Emitter<MessagesState> emit,
  ) {
    final data = event.data;
    final chatId = data['chatId'] as String?;
    final userId = data['userId'] as String?;
    // final userName = data['userName'] as String?; // Available if needed

    if (chatId == null || userId == null) {
      debugPrint(
          "MessagesBloc: Received invalid typing data via AppSocketCubit stream: $data");
      return;
    }

    // Ignore typing indicator from the current user
    if (userId == _currentUser?.id) {
      return;
    }

    debugPrint(
        "MessagesBloc: Received typing indicator for chat $chatId from user $userId via AppSocketCubit stream");

    // Set typing status to true
    final newTypingStatus = Map<String, bool>.from(state.typingStatus);
    newTypingStatus[chatId] = true;

    // Cancel any existing timer for this chat ID
    _typingTimers[chatId]?.cancel();

    // Start a new timer to dispatch the timeout event
    _typingTimers[chatId] = Timer(const Duration(seconds: 3), () {
      // Check if the BLoC is closed before adding an event
      if (isClosed) return;

      // Timer fired, add an event to handle the timeout
      add(_TypingTimedOut(chatId: chatId));

      // Remove the timer reference *after* adding the event
      _typingTimers.remove(chatId);
    });

    // Emit the state update immediately showing the user is typing
    emit(state.copyWith(typingStatus: newTypingStatus));
  }

  void _onTypingTimedOut(
    _TypingTimedOut event,
    Emitter<MessagesState> emit,
  ) {
    final chatId = event.chatId;
    // Check if the status is still true before resetting
    // (it might have been cleared by a received message already)
    if (state.typingStatus[chatId] == true) {
      debugPrint("MessagesBloc: Handling typing timeout for chat $chatId");
      final resetTypingStatus = Map<String, bool>.from(state.typingStatus);
      resetTypingStatus[chatId] = false;
      emit(state.copyWith(typingStatus: resetTypingStatus));
    } else {
      debugPrint(
          "MessagesBloc: Typing timeout for chat $chatId ignored (already false).");
    }
  }

  void _onReadReceiptReceived(
    _ReadReceiptReceived event,
    Emitter<MessagesState> emit,
  ) {
    final data = event.data;
    final chatId = data['chatId'] as String?;
    final receivedChat = data['chat'] != null
        ? Chat.fromJson(data['chat'])
        : null; // Expect updated chat in event

    if (chatId == null) {
      debugPrint(
          "MessagesBloc: Received invalid read receipt data via AppSocketCubit stream: $data");
      return;
    }

    debugPrint(
        "MessagesBloc: Received read receipt for chat $chatId via AppSocketCubit stream");
    final currentChatMessagesData = state.chatData[chatId];
    if (currentChatMessagesData == null) {
      debugPrint(
          "MessagesBloc: Received read receipt for unknown chat $chatId.");
      return;
    }

    // Option 1: Use the chat object from the event if available and reliable
    List<Message> updatedMessages;
    ChatMessagesData updatedChatData;
    if (receivedChat != null && receivedChat.lastMessage != null) {
      // Assume the received chat object has the correct read status on its messages/lastMessage
      // Replace the messages list if the received chat contains the full, updated list (less common)
      // Or, more likely, update the existing messages based on the received chat's last message status
      updatedMessages = currentChatMessagesData.messages.map((message) {
        // Mark messages sent by the current user as read if they are older than or same as the new last message time
        if (message.senderId == _currentUser?.id &&
            !message.isRead &&
            !message.createdAt.isAfter(
                receivedChat.lastMessageTimestamp ?? message.createdAt)) {
          return message.copyWith(isRead: true);
        }
        return message;
      }).toList();
      updatedChatData = currentChatMessagesData.copyWith(
          messages: updatedMessages,
          chat: receivedChat // Update the chat details
          );
    } else {
      // Option 2: Fallback - Mark all messages sent by the current user as read (less precise)
      updatedMessages = currentChatMessagesData.messages.map((message) {
        if (message.senderId == _currentUser?.id && !message.isRead) {
          return message.copyWith(isRead: true);
        }
        return message;
      }).toList();
      updatedChatData =
          currentChatMessagesData.copyWith(messages: updatedMessages);
    }

    final newChatDataMap = Map<String, ChatMessagesData>.from(state.chatData);
    newChatDataMap[chatId] = updatedChatData;

    // Also store the raw receipt data if needed elsewhere
    final newReadReceipts =
        Map<String, Map<String, dynamic>>.from(state.readReceipts);
    newReadReceipts[chatId] = data;

    emit(MessagesUpdated(
      // Use a specific state or the concrete state
      chatData: newChatDataMap,
      typingStatus: state.typingStatus,
      readReceipts: newReadReceipts,
    ));
  }

  // REMOVED: _onErrorReceived
  // REMOVED: _onConnectionChanged

  @override
  Future<void> close() {
    debugPrint("MessagesBloc: Closing, cancelling listeners and timers.");
    _cancelListeners(); // Unsubscribe from AppSocketCubit streams
    // Cancel all active typing timers
    for (final timer in _typingTimers.values) {
      timer.cancel();
    }
    _typingTimers.clear();
    // No need to disconnect socket here, AppSocketCubit/SocketManager handles it
    return super.close();
  }
}
