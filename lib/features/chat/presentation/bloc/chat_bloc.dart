// filepath: lib/features/chat/presentation/bloc/chat_bloc.dart
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/common/cubits/app_user/app_user_cubit.dart';
import '../../../../core/common/entities/user.dart';
import '../../data/datasources/chat_socket_datasource.dart';
import '../../data/models/chat.dart';
import '../../data/models/message.dart';
import '../../domain/usecase/get_chat_by_id.dart';
import '../../domain/usecase/get_user_chats.dart';
import '../../domain/usecase/initialize_chat.dart';
import '../../domain/usecase/send_message.dart';

part 'chat_event.dart';
part 'chat_state.dart';

class ChatBloc extends Bloc<ChatEvent, ChatState> {
  // UseCases
  final GetChatById _getChatById;
  final GetUserChats _getUserChats;
  final InitializeChat _initializeChat;
  final SendMessage _sendMessage;

  // DataSource
  final ChatSocketDataSource _chatSocketDataSource;

  // Cubit
  final AppUserCubit _appUserCubit;

  // Stream Subscriptions
  StreamSubscription? _messageSubscription;
  StreamSubscription? _typingSubscription;
  StreamSubscription? _readReceiptSubscription;
  StreamSubscription? _errorSubscription;
  StreamSubscription? _connectionSubscription;

  ChatBloc({
    required GetChatById getChatById,
    required GetUserChats getUserChats,
    required InitializeChat initializeChat,
    required SendMessage sendMessage,
    required ChatSocketDataSource chatSocketDataSource,
    required AppUserCubit appUserCubit,
  })  : _getChatById = getChatById,
        _getUserChats = getUserChats,
        _initializeChat = initializeChat,
        _sendMessage = sendMessage,
        _chatSocketDataSource = chatSocketDataSource,
        _appUserCubit = appUserCubit,
        super(const ChatState()) {
    // Register event handlers
    on<ChatFetchUserChats>(_onFetchUserChats);
    on<ChatFetchChatById>(_onFetchChatById);
    on<ChatInitializeChat>(_onInitializeChat);
    on<ChatSendMessageViaApi>(_onSendMessageViaApi);

    on<ChatConnectSocket>(_onConnectSocket);
    on<ChatDisconnectSocket>(_onDisconnectSocket);
    on<ChatJoinRoom>(_onJoinRoom);
    on<ChatSendMessageViaSocket>(_onSendMessageViaSocket);
    on<ChatSendTypingIndicator>(_onSendTypingIndicator);
    on<ChatMarkMessagesAsRead>(_onMarkMessagesAsRead);

    on<_ChatMessageReceived>(_onChatMessageReceived);
    on<_ChatTypingReceived>(_onChatTypingReceived);
    on<_ChatReadReceiptReceived>(_onChatReadReceiptReceived);
    on<_ChatErrorReceived>(_onChatErrorReceived);
    on<_ChatConnectionChanged>(_onChatConnectionChanged);
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

  void _setupListeners() {
    // _cancelListeners(); // Ensure old listeners are cancelled first
    _messageSubscription =
        _chatSocketDataSource.messageStream.listen((chatMessageTuple) {
      add(_ChatMessageReceived(
        chatMessageTuple: chatMessageTuple,
      ));
    });
    _typingSubscription = _chatSocketDataSource.typingStream.listen((data) {
      add(_ChatTypingReceived(data: data));
    });
    _readReceiptSubscription =
        _chatSocketDataSource.readReceiptStream.listen((data) {
      add(_ChatReadReceiptReceived(data: data));
    });
    _errorSubscription = _chatSocketDataSource.errorStream.listen((error) {
      add(_ChatErrorReceived(message: error));
    });
    _connectionSubscription =
        _chatSocketDataSource.connectionStream.listen((isConnected) {
      add(_ChatConnectionChanged(isConnected: isConnected));
    });
  }

  void _cancelListeners() {
    _messageSubscription?.cancel();
    _typingSubscription?.cancel();
    _readReceiptSubscription?.cancel();
    _errorSubscription?.cancel();
    _connectionSubscription?.cancel();
    _messageSubscription = null;
    _typingSubscription = null;
    _readReceiptSubscription = null;
    _errorSubscription = null;
    _connectionSubscription = null;
  }

  User? get _currentUser => _appUserCubit.user;

  // --- Event Handlers ---

  // REST API Handlers
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
        // Renamed 'chats' to 'fetchedChats' for clarity
        // On refresh, completely replace the list with the newly fetched data
        emit(state.copyWith(
          status: ChatStatus.chatsLoaded,
          chats: _sortChats(List<Chat>.from(
              fetchedChats)), // Use the fetched list directly, ensure it's sorted
          clearError: true,
        ));
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
          status: ChatStatus.success, // Or chatsLoaded if preferred
          chats: _sortChats(updatedChats),
          newlyFetchedChat:
              chat, // Pass fetched chat for potential specific UI updates
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
      )),
      (chat) => emit(state.copyWith(
        status: ChatStatus.success,
        newlyInitializedChat: chat,
        clearError: true,
      )),
    );
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
        status: ChatStatus.failure, // Keep overall status as failure
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
          // Should ideally not happen if chat exists, but handle defensively
          updatedChats = [...state.chats, updatedChat];
        }

        // Send via socket *after* successful API call
        add(ChatSendMessageViaSocket(
          chatId: sentMessage.chatId,
          content: sentMessage.content,
          type: sentMessage.type
              .toString()
              .split('.')
              .last, // Convert enum to string
        ));

        emit(state.copyWith(
          status: ChatStatus.chatsLoaded, // Indicate list update
          chats: _sortChats(updatedChats),
          newlySentMessage: sentMessage, // Pass sent message
          clearError: true,
        ));
      },
    );
  }

  // Socket Action Handlers
  Future<void> _onConnectSocket(
    ChatConnectSocket event,
    Emitter<ChatState> emit,
  ) async {
    if (state.isSocketConnected) return; // Already connected
    emit(state.copyWith(status: ChatStatus.loading));
    try {
      await _chatSocketDataSource.connect();
      _setupListeners();
      // State change handled by _onChatConnectionChanged listener
    } catch (e) {
      emit(state.copyWith(
        status: ChatStatus.failure,
        errorMessage: "Socket connection failed: ${e.toString()}",
        isSocketConnected: false,
      ));
    }
  }

  void _onDisconnectSocket(
    ChatDisconnectSocket event,
    Emitter<ChatState> emit,
  ) {
    _cancelListeners();
    _chatSocketDataSource.disconnect();
    emit(state.copyWith(
        status: ChatStatus.initial, // Or keep success if preferred
        isSocketConnected: false));
  }

  void _onJoinRoom(ChatJoinRoom event, Emitter<ChatState> emit) {
    if (state.isSocketConnected) {
      _chatSocketDataSource.joinChat(event.chatId);
    }
  }

  void _onSendMessageViaSocket(
    ChatSendMessageViaSocket event,
    Emitter<ChatState> emit,
  ) {
    if (state.isSocketConnected) {
      _chatSocketDataSource.sendMessage(
        chatId: event.chatId,
        content: event.content,
        type: event.type,
      );
    }
  }

  void _onSendTypingIndicator(
    ChatSendTypingIndicator event,
    Emitter<ChatState> emit,
  ) {
    if (state.isSocketConnected) {
      _chatSocketDataSource.sendTypingIndicator(event.chatId);
    }
  }

  void _onMarkMessagesAsRead(
    ChatMarkMessagesAsRead event,
    Emitter<ChatState> emit,
  ) {
    if (state.isSocketConnected) {
      try {
        _chatSocketDataSource.markMessagesAsRead(event.chatId);

        // Optimistically update the state locally
        final index = state.chats.indexWhere((c) => c.id == event.chatId);
        if (index != -1 && state.chats[index].lastMessage != null) {
          // Only update if the last message exists and is not already read by the current user
          final currentChat = state.chats[index];
          if (currentChat.lastMessage!.senderId != _currentUser?.id &&
              !currentChat.lastMessage!.isRead) {
            final readMessage = currentChat.lastMessage!.copyWith(isRead: true);
            final updatedChat = currentChat.copyWith(lastMessage: readMessage);
            final updatedChats = List<Chat>.from(state.chats);
            updatedChats[index] = updatedChat;

            emit(state.copyWith(
              status: ChatStatus.chatsLoaded, // Indicate list update
              chats:
                  updatedChats, // No re-sorting needed for read status change
            ));
          }
        }
      } catch (e) {
        emit(state.copyWith(
          status: ChatStatus.failure, // Keep overall status
          errorMessage: "Failed to send mark read event: ${e.toString()}",
        ));
      }
    }
  }

  // Socket Listener Event Handlers (Internal)
  void _onChatMessageReceived(
    _ChatMessageReceived event,
    Emitter<ChatState> emit,
  ) {
    // Destructure the tuple
    final (receivedChat, receivedMessage) = event.chatMessageTuple;

    final index = state.chats.indexWhere((chat) => chat.id == receivedChat.id);
    List<Chat> updatedChats;

    if (index != -1) {
      // Replace the existing chat with the updated one from the socket event
      updatedChats = List<Chat>.from(state.chats);
      updatedChats[index] = receivedChat; // Use the received chat directly
    } else {
      // Add the new chat if it wasn't in the list (less common for updates)
      updatedChats = [receivedChat, ...state.chats];
    }

    // Sort the chats based on the latest timestamp
    final sortedChats = _sortChats(updatedChats);

    emit(state.copyWith(
      status: ChatStatus.chatsLoaded, // Indicate chats were updated
      chats: sortedChats,
      clearError: true,
      // Optionally clear other specific fields if needed
      clearNewlyInitializedChat: true,
      clearNewlyFetchedChat: true,
      clearNewlySentMessage: true,
      clearTypingData: true,
      clearReadReceiptData: true,
    ));
  }

  void _onChatTypingReceived(
    _ChatTypingReceived event,
    Emitter<ChatState> emit,
  ) {
    // Only update state if it's relevant (e.g., for the currently viewed chat)
    // Or store it for the ChatListScreen to potentially use later
    emit(state.copyWith(
        typingData: event.data, clearTypingData: false)); // Keep typing data
    // Consider adding a timer to clear typingData after a few seconds
  }

  void _onChatReadReceiptReceived(
    _ChatReadReceiptReceived event,
    Emitter<ChatState> emit,
  ) {
    final data = event.data;
    final chatId = data['chatId'] as String?;
    final userId = data['userId'] as String?; // User who read the message
    final receivedChat = data['chat'] != null
        ? Chat.fromJson(data['chat'])
        : null; // Get updated chat

    if (chatId == null || userId == null || receivedChat == null) return;

    final index = state.chats.indexWhere((c) => c.id == chatId);
    if (index != -1) {
      // Update the specific chat in the list with the one received in the event
      final updatedChats = List<Chat>.from(state.chats);
      updatedChats[index] = receivedChat; // Use the chat from the event data

      // Sort again if necessary, although read receipts might not change order
      final sortedChats = _sortChats(updatedChats);

      emit(state.copyWith(
        chats: sortedChats,
        readReceiptData: data, // Keep read receipt data
        clearReadReceiptData: false,
        status: ChatStatus.chatsLoaded, // Reflect update
      ));
    } else {
      // If chat not found, just update the read receipt data
      emit(state.copyWith(
        readReceiptData: data,
        clearReadReceiptData: false,
      ));
    }
  }

  void _onChatErrorReceived(
    _ChatErrorReceived event,
    Emitter<ChatState> emit,
  ) {
    emit(state.copyWith(
      status: ChatStatus.failure, // Set status to failure on socket error
      errorMessage: "Socket Error: ${event.message}",
      clearError: false, // Keep the error message
    ));
  }

  void _onChatConnectionChanged(
    _ChatConnectionChanged event,
    Emitter<ChatState> emit,
  ) {
    emit(state.copyWith(
      isSocketConnected: event.isConnected,
      // Set status based on connection, but avoid overriding loading/failure states unnecessarily
      status: event.isConnected ? ChatStatus.success : state.status,
      // Clear error if we just connected successfully
      clearError: event.isConnected,
    ));
    if (event.isConnected) {
      // Re-fetch chats or join rooms if needed upon reconnection
      // Example: Re-fetch user chats if the list might be stale
      if (_currentUser != null && _currentUser!.jwtToken.isNotEmpty) {
        add(ChatFetchUserChats(token: _currentUser!.jwtToken));
      }
    }
  }

  @override
  Future<void> close() {
    _cancelListeners();
    _chatSocketDataSource.disconnect(); // Ensure disconnection on bloc close
    return super.close();
  }
}
