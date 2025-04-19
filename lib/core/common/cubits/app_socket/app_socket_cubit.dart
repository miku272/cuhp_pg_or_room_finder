import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../socket/socket_manager.dart';

part 'app_socket_state.dart';

class AppSocketCubit extends Cubit<AppSocketState> {
  final SocketManager _socketManager;

  StreamSubscription? _connectionSubscription;
  StreamSubscription? _errorSubscription;

  AppSocketCubit({required SocketManager socketManager})
      : _socketManager = socketManager,
        super(AppSocketInitial()) {
    _listenToSocketChanges();
  }

  Stream<dynamic> get messageStream =>
      _socketManager.eventHandler.messageStream;
  Stream<Map<String, dynamic>> get typingStream =>
      _socketManager.eventHandler.typingStream;
  Stream<Map<String, dynamic>> get readReceiptStream =>
      _socketManager.eventHandler.readReceiptStream;

  bool get isConnected => state is AppSocketConnected;

  void _listenToSocketChanges() {
    _connectionSubscription?.cancel();
    _errorSubscription?.cancel();

    // Listen to connection changes from the SocketClient via SocketManager
    _connectionSubscription = _socketManager.client.connectionStream.listen(
      (isConnected) {
        if (isConnected) {
          emit(AppSocketConnected());
          debugPrint("AppSocketCubit: Socket Connected");
        } else {
          // Check if the current state is not already an error or initial
          if (state is AppSocketConnected || state is AppSocketConnecting) {
            emit(const AppSocketDisconnected(reason: 'Lost connection'));
            debugPrint("AppSocketCubit: Socket Disconnected");
          }
        }
      },
      onError: (error) {
        // Handle potential errors on the connection stream itself
        emit(AppSocketError('Connection Stream Error: $error'));
        debugPrint("AppSocketCubit: Connection Stream Error: $error");
      },
    );

    // Listen to application-level errors from the EventHandler via SocketManager
    _errorSubscription = _socketManager.eventHandler.errorStream.listen(
      (errorMessage) {
        emit(AppSocketError(errorMessage));
        debugPrint("AppSocketCubit: Socket Error Received: $errorMessage");
      },
      onError: (error) {
        // Handle potential errors on the error stream itself
        emit(AppSocketError('Error Stream Error: $error'));
        debugPrint("AppSocketCubit: Error Stream Error: $error");
      },
    );
  }

  Future<void> connectSocket(String baseUrl) async {
    // Prevent multiple connection attempts if already connected or connecting
    if (state is AppSocketConnected || state is AppSocketConnecting) {
      debugPrint("AppSocketCubit: Already connected or connecting.");
      return;
    }
    emit(AppSocketConnecting());
    debugPrint("AppSocketCubit: Attempting to connect...");
    try {
      // The actual connection and state update (Connected/Error)
      // will be handled by the listeners setup in _listenToSocketChanges
      await _socketManager.initialize(baseUrl);
    } catch (e) {
      // If initialize throws an error before listeners catch it
      final errorMessage = 'Socket Connection Failed: $e';
      emit(AppSocketError(errorMessage));
      debugPrint("AppSocketCubit: $errorMessage");
      // Ensuring state reflects disconnection if initialization fails badly
      if (state is! AppSocketDisconnected && state is! AppSocketError) {
        emit(const AppSocketDisconnected(reason: 'Initialization failed'));
      }
    }
  }

  void disconnectSocket() {
    debugPrint("AppSocketCubit: Disconnecting socket...");
    _socketManager.disconnect();
    emit(const AppSocketDisconnected(reason: 'User disconnected'));
    debugPrint("AppSocketCubit: Socket disconnected by user.");
  }

  // --- Methods to send data (delegate to manager/repository) ---
  // These might not be strictly needed in the Cubit if Blocs directly
  // use the SocketManager/Repository, but can be useful centralization points.

  void joinChat(String chatId) {
    if (isConnected) {
      _socketManager.client.joinChat(chatId);
    } else {
      debugPrint("AppSocketCubit: Cannot join chat - Socket not connected.");
    }
  }

  void sendMessage(
      {required String chatId, required String content, required String type}) {
    if (isConnected) {
      _socketManager.client.sendMessage(
        chatId: chatId,
        content: content,
        type: type,
      );
    } else {
      debugPrint("AppSocketCubit: Cannot send message - Socket not connected.");
    }
  }

  void sendTypingIndicator(String chatId) {
    if (isConnected) {
      _socketManager.client.sendTypingIndicator(chatId);
    } else {
      debugPrint("AppSocketCubit: Cannot send typing - Socket not connected.");
    }
  }

  void markMessagesAsRead(String chatId) {
    if (isConnected) {
      _socketManager.client.markMessageAsRead(chatId);
    } else {
      debugPrint("AppSocketCubit: Cannot mark read - Socket not connected.");
    }
  }

  @override
  Future<void> close() {
    debugPrint("AppSocketCubit: Closing and cancelling listeners.");
    _connectionSubscription?.cancel();
    _errorSubscription?.cancel();
    // Optionally disconnect if the cubit closing means the app is closing
    // _socketManager.disconnect();
    return super.close();
  }
}
