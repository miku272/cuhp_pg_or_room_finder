import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

// Core imports
import '../../../../core/common/cubits/app_socket/app_socket_cubit.dart';
import '../../../../core/common/cubits/app_user/app_user_cubit.dart';
import '../../../../core/common/entities/user.dart';
import '../../../../core/common/entities/chat.dart';
import '../../../../core/common/entities/message.dart';
import '../../../../core/socket/socket_manager.dart';

// Domain imports
import '../../domain/usecase/get_chat_by_id.dart';
import '../../domain/usecase/get_user_chats.dart';
import '../../domain/usecase/initialize_chat.dart';
import '../../domain/usecase/send_message.dart'; // Assuming this is API send

part 'chat_event.dart';
part 'chat_state.dart';

class ChatBloc extends Bloc<ChatEvent, ChatState> {
  // UseCases (Remote)
  final GetChatById _getChatById;
  final GetUserChats _getUserChats;
  final InitializeChat _initializeChat;
  final SendMessage _sendMessage; // API Send

  // Core Components
  final SocketManager _socketManager;
  final AppUserCubit _appUserCubit;
  final AppSocketCubit _appSocketCubit;

  // Stream Subscriptions to AppSocketCubit streams
  StreamSubscription? _messageSubscription;
  StreamSubscription? _typingSubscription;
  StreamSubscription? _readReceiptSubscription;

  // ADDED: Timer map to manage typing indicators timeout
  final Map<String, Timer> _typingTimers = {};

  ChatBloc({
    required GetChatById getChatById,
    required GetUserChats getUserChats,
    required InitializeChat initializeChat,
    required SendMessage sendMessage, // API Send
    required SocketManager socketManager,
    required AppUserCubit appUserCubit,
    required AppSocketCubit appSocketCubit,
  })  : _getChatById = getChatById,
        _getUserChats = getUserChats,
        _initializeChat = initializeChat,
        _sendMessage = sendMessage,
        _socketManager = socketManager,
        _appUserCubit = appUserCubit,
        _appSocketCubit = appSocketCubit,
        super(const ChatState()) {
    on<ChatResetEvent>((event, emit) {
      emit(const ChatInitial());
    });

    // Initial state doesn't need isSocketConnected
    // Register event handlers
    on<ChatFetchUserChats>(_onFetchUserChats);
    on<ChatFetchChatById>(_onFetchChatById);
    on<ChatInitializeChat>(_onInitializeChat);
    on<ChatSendMessageViaApi>(_onSendMessageViaApi); // API Send

    // Socket Action Handlers (Emit events via SocketManager)
    on<ChatJoinRoom>(_onJoinRoom);
    on<ChatSendMessageViaSocket>(_onSendMessageViaSocket); // Socket Send
    on<ChatSendTypingIndicator>(_onSendTypingIndicator);
    on<ChatMarkMessagesAsRead>(_onMarkMessagesAsRead);

    // Internal handlers for messages received via AppSocketCubit streams
    on<_ChatMessageReceived>(_onChatMessageReceived);
    on<_ChatTypingReceived>(_onChatTypingReceived);
    on<_ChatReadReceiptReceived>(_onChatReadReceiptReceived);
    // ADDED: Handler for typing timeout
    on<_ChatTypingTimedOut>(_onChatTypingTimedOut);

    // Start listening to AppSocketCubit streams
    _listenToSocketEvents();
  }

  // --- Helper Methods ---

  List<Chat> _sortChats(List<Chat> chats) {
    chats.sort((a, b) {
      final timeA = a.lastMessageTimestamp ?? a.createdAt;
      final timeB = b.lastMessageTimestamp ?? b.createdAt;
      return timeB.compareTo(timeA); // Descending order
    });
    return chats;
  }

  void _listenToSocketEvents() {
    _cancelListeners(); // Ensure no duplicates

    _messageSubscription = _appSocketCubit.messageStream.listen(
      (chatMessageTuple) {
        // Ensure the data is the expected tuple type
        if (chatMessageTuple is (Chat, Message)) {
          add(_ChatMessageReceived(chatMessageTuple: chatMessageTuple));
        } else {
          debugPrint(
              "ChatBloc: Received unexpected message data type: ${chatMessageTuple.runtimeType}");
        }
      },
      onError: (error) {
        // Errors are handled by AppSocketCubit's state, but log if needed
        debugPrint("ChatBloc: Error on message stream: $error");
      },
    );

    _typingSubscription = _appSocketCubit.typingStream.listen(
      (data) {
        // Assuming data is Map<String, dynamic> based on server event
        add(_ChatTypingReceived(data: data));
      },
      onError: (error) {
        debugPrint("ChatBloc: Error on typing stream: $error");
      },
    );

    _readReceiptSubscription = _appSocketCubit.readReceiptStream.listen(
      (data) {
        // Assuming data is Map<String, dynamic>
        add(_ChatReadReceiptReceived(data: data));
      },
      onError: (error) {
        debugPrint("ChatBloc: Error on read receipt stream: $error");
      },
    );
    debugPrint("ChatBloc: Subscribed to AppSocketCubit streams.");
  }

  void _cancelListeners() {
    _messageSubscription?.cancel();
    _typingSubscription?.cancel();
    _readReceiptSubscription?.cancel();
    _messageSubscription = null;
    _typingSubscription = null;
    _readReceiptSubscription = null;
    debugPrint("ChatBloc: Unsubscribed from AppSocketCubit streams.");
  }

  User? get _currentUser => _appUserCubit.user;
  bool get _isConnected =>
      _appSocketCubit.isConnected; // Check connection via Cubit

  // --- Event Handlers ---

  // REST API Handlers (Remain largely the same)
  Future<void> _onFetchUserChats(
    ChatFetchUserChats event,
    Emitter<ChatState> emit,
  ) async {
    emit(state.copyWith(status: ChatStatus.loadingChats));
    final res = await _getUserChats(GetUserChatsParams(token: event.token));
    res.fold(
      (failure) => emit(state.copyWith(
        status: ChatStatus.failure,
        errorMessage: failure.message,
        errorStatus: failure.status,
      )),
      (fetchedChats) {
        emit(state.copyWith(
          status: ChatStatus.chatsLoaded,
          chats: _sortChats(List<Chat>.from(fetchedChats)),
          clearError: true,
        ));
        // After fetching chats, join their rooms if connected
        if (_isConnected) {
          for (final chat in fetchedChats) {
            add(ChatJoinRoom(chatId: chat.id));
          }
        }
      },
    );
  }

  Future<void> _onFetchChatById(
    ChatFetchChatById event,
    Emitter<ChatState> emit,
  ) async {
    emit(state.copyWith(status: ChatStatus.loading));
    final res = await _getChatById(
      GetChatByIdParams(chatId: event.chatId, token: event.token),
    );
    res.fold(
      (failure) => emit(state.copyWith(
        status: ChatStatus.failure,
        errorMessage: failure.message,
        errorStatus: failure.status,
      )),
      (chat) {
        final index = state.chats.indexWhere((c) => c.id == chat.id);
        List<Chat> updatedChats;
        if (index != -1) {
          updatedChats = List<Chat>.from(state.chats);
          updatedChats[index] = chat;
        } else {
          updatedChats = [...state.chats, chat];
        }
        emit(state.copyWith(
          status: ChatStatus.success,
          chats: _sortChats(updatedChats),
          newlyFetchedChat: chat,
          clearError: true,
        ));
      },
    );
  }

  Future<void> _onInitializeChat(
    ChatInitializeChat event,
    Emitter<ChatState> emit,
  ) async {
    emit(state.copyWith(status: ChatStatus.loading));
    final res = await _initializeChat(InitializeChatParams(
      propertyId: event.propertyId,
      token: event.token,
    ));
    res.fold(
        (failure) => emit(state.copyWith(
              status: ChatStatus.failure,
              errorMessage: failure.message,
              errorStatus: failure.status,
            )), (chat) {
      emit(state.copyWith(
        status: ChatStatus.success,
        newlyInitializedChat: chat,
        clearError: true,
      ));
      // Join the room for the newly initialized chat if connected
      if (_isConnected) {
        add(ChatJoinRoom(chatId: chat.id));
      }
    });
  }

  Future<void> _onSendMessageViaApi(
    ChatSendMessageViaApi event,
    Emitter<ChatState> emit,
  ) async {
    // Optional: Emit a temporary loading state for the specific chat if needed
    final res = await _sendMessage(SendMessageParams(
      content: event.content,
      type: event.type,
      chatId: event.chatId,
      token: event.token,
    ));

    res.fold(
      (failure) => emit(state.copyWith(
        status: ChatStatus.failure,
        errorMessage: failure.message,
        errorStatus: failure.status,
      )),
      (result) {
        final updatedChat = result.$1;
        final sentMessage = result.$2;

        // Update the chat list in the state
        final index = state.chats.indexWhere((c) => c.id == updatedChat.id);
        List<Chat> updatedChats;
        if (index != -1) {
          updatedChats = List<Chat>.from(state.chats);
          updatedChats[index] = updatedChat;
        } else {
          updatedChats = [...state.chats, updatedChat];
        }

        // Emit the state update *before* sending via socket
        emit(state.copyWith(
          status: ChatStatus.chatsLoaded,
          chats: _sortChats(updatedChats),
          newlySentMessage: sentMessage,
          clearError: true,
        ));

        // Send via socket *after* successful API call and state update
        // No need to dispatch ChatSendMessageViaSocket event here,
        // the message should arrive via the _ChatMessageReceived listener
        // if the backend broadcasts it correctly after the API call.
        // If the backend *doesn't* broadcast after API send, you might
        // need to manually add the message here or adjust the backend.
        // For now, assume backend broadcasts.
      },
    );
  }

  // Socket Action Handlers (Use SocketManager)
  void _onJoinRoom(ChatJoinRoom event, Emitter<ChatState> emit) {
    if (_isConnected) {
      _socketManager.client.joinChat(event.chatId);
      debugPrint("ChatBloc: Sent join_chat for ${event.chatId}");
    } else {
      debugPrint(
          "ChatBloc: Cannot join room ${event.chatId} - Socket disconnected");
      // Optionally emit a state indicating failure to join if needed
    }
  }

  void _onSendMessageViaSocket(
    ChatSendMessageViaSocket event,
    Emitter<ChatState> emit,
  ) {
    if (_isConnected) {
      _socketManager.client.sendMessage(
        chatId: event.chatId,
        content: event.content,
        type: event.type,
      );
      debugPrint("ChatBloc: Sent send_message for ${event.chatId}");
      // Optimistic UI update might happen here if needed,
      // but rely on _ChatMessageReceived for confirmation.
    } else {
      debugPrint(
          "ChatBloc: Cannot send message ${event.chatId} - Socket disconnected");
      emit(state.copyWith(
          status: ChatStatus.failure,
          errorMessage: "Cannot send message: disconnected"));
    }
  }

  void _onSendTypingIndicator(
    ChatSendTypingIndicator event,
    Emitter<ChatState> emit,
  ) {
    if (_isConnected) {
      _socketManager.client.sendTypingIndicator(event.chatId);
      debugPrint("ChatBloc: Sent typing indicator for ${event.chatId}");
    } else {
      debugPrint(
          "ChatBloc: Cannot send typing indicator ${event.chatId} - Socket disconnected");
    }
  }

  void _onMarkMessagesAsRead(
    ChatMarkMessagesAsRead event,
    Emitter<ChatState> emit,
  ) {
    if (_isConnected) {
      _socketManager.client.markMessageAsRead(event.chatId);
      debugPrint("ChatBloc: Sent mark_read for ${event.chatId}");

      // Optimistically update the state locally (can be refined based on _ChatReadReceiptReceived)
      final index = state.chats.indexWhere((c) => c.id == event.chatId);
      if (index != -1 && state.chats[index].lastMessage != null) {
        final currentChat = state.chats[index];
        // Check if the last message was not from the current user and was unread
        if (currentChat.lastMessage!.senderId != _currentUser?.id &&
            !currentChat.lastMessage!.isRead) {
          final readMessage = currentChat.lastMessage!.copyWith(isRead: true);
          // Create an updated chat with the modified last message
          // Ensure other properties like unread count are handled if necessary
          final updatedChat = currentChat.copyWith(
            lastMessage: readMessage,
            // You might need to adjust unreadCount here if you track it
            // unreadCount: 0
          );
          final updatedChats = List<Chat>.from(state.chats);
          updatedChats[index] = updatedChat;

          emit(state.copyWith(
            status: ChatStatus.chatsLoaded,
            chats: updatedChats, // Keep sorting order
          ));
        }
      }
    } else {
      debugPrint(
          "ChatBloc: Cannot mark messages as read ${event.chatId} - Socket disconnected");
      emit(state.copyWith(
          status: ChatStatus.failure,
          errorMessage: "Cannot mark read: disconnected"));
    }
  }

  // Socket Listener Event Handlers (Internal - Triggered by _listenToSocketEvents)
  void _onChatMessageReceived(
    _ChatMessageReceived event,
    Emitter<ChatState> emit,
  ) {
    final (receivedChat, receivedMessage) = event.chatMessageTuple;
    final chatId = receivedChat.id;
    debugPrint("ChatBloc: Received message via stream for chat $chatId");

    final index = state.chats.indexWhere((chat) => chat.id == chatId);
    List<Chat> updatedChats;

    if (index != -1) {
      updatedChats = List<Chat>.from(state.chats);
      updatedChats[index] = receivedChat; // Use the updated chat from the event
    } else {
      // Add the new chat if it wasn't in the list
      updatedChats = [receivedChat, ...state.chats];
    }

    final sortedChats = _sortChats(updatedChats);

    // ADDED: Clear typing indicator for this chat if the sender was typing
    final newTypingStatus =
        Map<String, String>.from(state.typingUserIdByChatId);
    bool typingStatusChanged = false;
    if (newTypingStatus[chatId] == receivedMessage.senderId) {
      newTypingStatus.remove(chatId);
      _typingTimers[chatId]?.cancel();
      _typingTimers.remove(chatId);
      typingStatusChanged = true;
    }

    emit(state.copyWith(
      status: ChatStatus.chatsLoaded,
      chats: sortedChats,
      typingUserIdByChatId:
          typingStatusChanged ? newTypingStatus : state.typingUserIdByChatId,
      clearError: true,
      clearNewlyInitializedChat: true,
      clearNewlyFetchedChat: true,
      clearNewlySentMessage: true,
      // clearTypingData: true, // No longer needed
      clearReadReceiptData: true,
    ));
  }

  void _onChatTypingReceived(
    _ChatTypingReceived event,
    Emitter<ChatState> emit,
  ) {
    final data = event.data;
    final chatId = data['chatId'] as String?;
    final userId = data['userId'] as String?;
    // final isTyping = data['isTyping'] as bool? ?? true; // Assuming default is true

    if (chatId == null || userId == null) {
      debugPrint("ChatBloc: Received invalid typing data: $data");
      return;
    }

    // Ignore typing indicator from the current user
    if (userId == _currentUser?.id) {
      return;
    }

    debugPrint("ChatBloc: Received typing for chat $chatId from user $userId");

    // Update typing status
    final newTypingStatus =
        Map<String, String>.from(state.typingUserIdByChatId);
    newTypingStatus[chatId] = userId;

    // Cancel any existing timer for this chat ID
    _typingTimers[chatId]?.cancel();

    // Start a new timer to dispatch the timeout event
    _typingTimers[chatId] = Timer(const Duration(seconds: 3), () {
      // Check if the BLoC is closed before adding an event
      if (isClosed) return;
      // Timer fired, add an event to handle the timeout
      add(_ChatTypingTimedOut(chatId: chatId));
      // Remove the timer reference *after* adding the event
      _typingTimers.remove(chatId);
    });

    // Emit the state update immediately showing the user is typing
    emit(state.copyWith(typingUserIdByChatId: newTypingStatus));
  }

  // ADDED: Handler for typing timeout
  void _onChatTypingTimedOut(
    _ChatTypingTimedOut event,
    Emitter<ChatState> emit,
  ) {
    final chatId = event.chatId;
    // Check if the status still has an entry for this chat before resetting
    if (state.typingUserIdByChatId.containsKey(chatId)) {
      debugPrint("ChatBloc: Handling typing timeout for chat $chatId");
      final resetTypingStatus =
          Map<String, String>.from(state.typingUserIdByChatId);
      resetTypingStatus.remove(chatId); // Remove the entry
      emit(state.copyWith(typingUserIdByChatId: resetTypingStatus));
    } else {
      debugPrint(
          "ChatBloc: Typing timeout for chat $chatId ignored (already cleared).");
    }
  }

  void _onChatReadReceiptReceived(
    _ChatReadReceiptReceived event,
    Emitter<ChatState> emit,
  ) {
    final data = event.data;
    final chatId = data['chatId'] as String?;
    final receivedChat = data['chat'] != null
        ? Chat.fromJson(data['chat'])
        : null; // Expect updated chat in event
    debugPrint("ChatBloc: Received read receipt via stream for chat $chatId");

    if (chatId == null || receivedChat == null) {
      debugPrint("ChatBloc: Invalid read receipt data received.");
      return;
    }

    final index = state.chats.indexWhere((c) => c.id == chatId);
    if (index != -1) {
      final updatedChats = List<Chat>.from(state.chats);
      updatedChats[index] = receivedChat; // Use the updated chat from the event

      final sortedChats = _sortChats(updatedChats); // Re-sort if needed

      emit(state.copyWith(
        chats: sortedChats,
        readReceiptData: data,
        clearReadReceiptData: false,
        status: ChatStatus.chatsLoaded,
      ));
    } else {
      // Chat not found, maybe just store the receipt data if useful
      emit(state.copyWith(
        readReceiptData: data,
        clearReadReceiptData: false,
      ));
    }
  }

  @override
  Future<void> close() {
    debugPrint("ChatBloc: Closing, cancelling listeners and timers.");
    _cancelListeners(); // Unsubscribe from AppSocketCubit streams
    // ADDED: Cancel all active typing timers
    for (final timer in _typingTimers.values) {
      timer.cancel();
    }
    _typingTimers.clear();
    return super.close();
  }
}
