import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:socket_io_client/socket_io_client.dart' as io;

import '../../init_dependencies.dart';
import '../error/exception.dart';
import '../utils/sf_handler.dart';

/// A singleton WebSocket client that manages real-time communication with the server.
///
/// This class handles the core socket.io connection, authentication, and provides
/// methods for chat-related operations like sending messages, joining chats,
/// and managing typing indicators.
///
/// The client automatically handles:
/// - JWT token authentication
/// - Connection state management
/// - Event emission and listening
/// - Automatic reconnection (via socket.io)
///
/// Example usage:
/// ```dart
/// final client = SocketClient();
/// await client.initializeSocket('https://api.example.com');
/// client.joinChat('chat123');
/// client.sendMessage(chatId: 'chat123', content: 'Hello!', type: 'text');
/// ```
class SocketClient {
  /// Private constructor for singleton pattern
  static final SocketClient _instance = SocketClient._internal();

  /// Factory constructor that returns the singleton instance
  factory SocketClient() => _instance;
  SocketClient._internal();

  /// The underlying socket.io client instance
  io.Socket? _socket;

  /// Handler for secure storage operations (token management)
  final _sfHandler = serviceLocator<SFHandler>();

  /// Stream controller for broadcasting connection state changes
  final _connectivityStreamController = StreamController<bool>.broadcast();

  /// Stream that emits connection state changes (true = connected, false = disconnected)
  Stream<bool> get connectionStream => _connectivityStreamController.stream;

  /// Returns true if the socket is currently connected to the server
  bool get isConnected => _socket?.connected ?? false;

  /// Initializes the socket connection with the provided base URL.
  ///
  /// This method sets up the socket.io client with JWT authentication,
  /// configures connection options, and establishes the connection.
  ///
  /// [baseUrl] The WebSocket server URL to connect to
  ///
  /// Throws [UserException] if authentication token is not found
  Future<void> initializeSocket(String baseUrl) async {
    // Prevent multiple initialization attempts
    if (_socket != null) {
      return;
    }

    try {
      // Retrieve JWT token from secure storage for authentication
      final token = _sfHandler.getToken();

      if (token == null) {
        throw UserException(
          status: 401,
          message: 'Authentication error: Token not found',
        );
      }

      // Configure socket.io client with authentication and connection options
      _socket = io.io(
        baseUrl,
        io.OptionBuilder()
            .setTransports(['websocket']) // Use WebSocket transport only
            .enableAutoConnect() // Automatically connect when created
            .enableForceNew() // Force a new connection
            .setExtraHeaders({'Authorization': 'Bearer $token'}) // HTTP headers
            .setAuth({'token': token}) // Socket.io auth data
            .build(),
      );

      // Set up connection event listeners
      _setupSocketListeners();
      // Initiate the connection
      _socket?.connect();
    } catch (error) {
      // Notify listeners of connection failure
      _connectivityStreamController.add(false);
    }
  }

  /// Sets up event listeners for socket connection state changes.
  ///
  /// Monitors various socket events and updates the connectivity stream accordingly.
  /// This helps other parts of the app react to connection changes.
  void _setupSocketListeners() {
    // Listen for successful connection
    _socket?.onConnect((data) {
      debugPrint('Socket connected');
      _connectivityStreamController.add(true);
    });

    // Listen for connection errors (auth failures, network issues, etc.)
    _socket?.onConnectError((data) {
      debugPrint('Socket connection error: $data');
      _connectivityStreamController.add(false);
    });

    // Listen for disconnection events
    _socket?.onDisconnect((data) {
      debugPrint('Socket disconnected');
      _connectivityStreamController.add(false);
    });

    // Listen for general socket errors
    _socket?.onError((data) {
      debugPrint('Socket error: $data');
      _connectivityStreamController.add(false);
    });
  }

  /// Emits an event to the server with optional data.
  ///
  /// [event] The event name to emit
  /// [data] Optional data to send with the event
  void emit(String event, dynamic data) {
    // Check connection status before emitting
    if (!isConnected) {
      debugPrint('Socket not connected. Cannot emit event: $event');
      return;
    }

    _socket?.emit(event, data);
  }

  /// Registers a listener for server events.
  ///
  /// [event] The event name to listen for
  /// [callback] Function to call when the event is received
  void on(String event, Function(dynamic) callback) {
    // Check connection status before setting up listener
    if (!isConnected) {
      debugPrint('Socket not connected. Cannot listen to event: $event');
      return;
    }

    _socket?.on(event, callback);
  }

  /// Joins a specific chat room.
  ///
  /// [chatId] The unique identifier of the chat to join
  void joinChat(String chatId) {
    emit('join_chat', chatId);
  }

  /// Sends a message to a specific chat.
  ///
  /// [chatId] The chat identifier where the message should be sent
  /// [content] The message content/text
  /// [type] The type of message (e.g., 'text', 'image', 'file')
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

  /// Sends a typing indicator to show other users that this user is typing.
  ///
  /// [chatId] The chat identifier where typing is occurring
  void sendTypingIndicator(String chatId) {
    emit('typing', chatId);
  }

  /// Marks messages in a chat as read.
  ///
  /// [chatId] The chat identifier where messages should be marked as read
  void markMessageAsRead(String chatId) {
    emit('mark_read', chatId);
  }

  /// Disconnects from the socket server.
  ///
  /// This method gracefully closes the connection and nullifies the socket instance.
  void disconnect() {
    _socket?.disconnect();
    _socket = null;
  }

  /// Disposes of all resources used by the socket client.
  ///
  /// This method should be called when the socket client is no longer needed.
  /// It closes the socket connection and all stream controllers.
  void dispose() {
    _socket?.dispose();
    _socket = null;

    // Close the connectivity stream controller to prevent memory leaks
    _connectivityStreamController.close();
  }
}
