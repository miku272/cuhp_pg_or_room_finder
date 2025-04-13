import 'package:flutter/foundation.dart';

import './socket_client.dart';
import './socket_event_handler.dart';

class SocketManager {
  static final SocketManager _instance = SocketManager._internal();
  factory SocketManager() => _instance;

  late SocketClient _socketClient;
  late SocketEventHandler _socketEventHandler;
  bool _isInitialized = false;

  SocketManager._internal() {
    _socketClient = SocketClient();
    _socketEventHandler = SocketEventHandler(socketClient: _socketClient);
  }

  Future<void> initialize(String baseUrl) async {
    if (_isInitialized) {
      return;
    }

    try {
      await _socketClient.initializeSocket(baseUrl);

      _isInitialized = true;
    } catch (error) {
      debugPrint('Error initializing socket manager: $error');

      rethrow;
    }
  }

  SocketEventHandler get eventHandler => _socketEventHandler;

  SocketClient get client => _socketClient;

  bool get isConnected => _socketClient.isConnected;

  void disconnect() {
    _socketClient.disconnect();
    _isInitialized = false;
  }

  void dispose() {
    _socketEventHandler.dispose();
    _socketClient.dispose();
    _isInitialized = false;
  }
}
