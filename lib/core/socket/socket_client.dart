import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:socket_io_client/socket_io_client.dart' as io;

import '../../init_dependencies.dart';
import '../error/exception.dart';
import '../utils/sf_handler.dart';

class SocketClient {
  static final SocketClient _instance = SocketClient._internal();
  factory SocketClient() => _instance;
  SocketClient._internal();

  io.Socket? _socket;
  final _sfHandler = serviceLocator<SFHandler>();

  final _connectivityStreamController = StreamController<bool>.broadcast();
  Stream<bool> get connectionStream => _connectivityStreamController.stream;

  bool get isConnected => _socket?.connected ?? false;

  Future<void> initializeSocket(String baseUrl) async {
    if (_socket != null) {
      return;
    }

    try {
      final token = _sfHandler.getToken();

      if (token == null) {
        throw UserException(
          status: 401,
          message: 'Authentication error: Token not found',
        );
      }

      _socket = io.io(
        baseUrl,
        io.OptionBuilder()
            .setTransports(['websocket'])
            .enableAutoConnect()
            .enableForceNew()
            .setExtraHeaders({'Authorization': 'Bearer $token'})
            .setAuth({'token': token})
            .build(),
      );

      _setupSocketListeners();
      _socket?.connect();
    } catch (error) {
      _connectivityStreamController.add(false);
    }
  }

  void _setupSocketListeners() {
    _socket?.onConnect((data) {
      debugPrint('Socket connected');
      _connectivityStreamController.add(true);
    });

    _socket?.onConnectError((data) {
      debugPrint('Socket connection error: $data');
      _connectivityStreamController.add(false);
    });

    _socket?.onDisconnect((data) {
      debugPrint('Socket disconnected');
      _connectivityStreamController.add(false);
    });

    _socket?.onError((data) {
      debugPrint('Socket error: $data');
      _connectivityStreamController.add(false);
    });

    _socket?.onAny((event, data) {
      debugPrint('🔵 Socket received event: $event with data: $data');
    });
  }

  void emit(String event, dynamic data) {
    if (!isConnected) {
      debugPrint('Socket not connected. Cannot emit event: $event');
      return;
    }

    _socket?.emit(event, data);
  }

  void on(String event, Function(dynamic) callback) {
    if (!isConnected) {
      debugPrint('Socket not connected. Cannot listen to event: $event');
      return;
    }

    _socket?.on(event, callback);
  }

  void joinChat(String chatId) {
    emit('join_chat', chatId);
  }

  void sendMessage({
    required String chatId,
    required String content,
    required String type,
  }) {
    emit(
      'send_message',
      {
        'chatId': chatId,
        'content': content,
        'type': type,
      },
    );
  }

  void sendTypingIndicator(String chatId) {
    emit('typing', chatId);
  }

  void markMessageAsRead(String chatId) {
    emit('mark_read', chatId);
  }

  void disconnect() {
    _socket?.disconnect();
    _socket = null;
  }

  void dispose() {
    _socket?.dispose();
    _socket = null;

    _connectivityStreamController.close();
  }
}
