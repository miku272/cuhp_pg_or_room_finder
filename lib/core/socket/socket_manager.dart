import 'package:flutter/foundation.dart';

import './socket_client.dart';
import './socket_event_handler.dart';

/// A singleton manager that orchestrates socket connections and event handling.
///
/// This class serves as the main entry point for all socket-related operations,
/// providing a unified interface to manage both the socket client and event handler.
/// It ensures proper initialization order and lifecycle management.
///
/// Key responsibilities:
/// - Coordinating socket client initialization
/// - Managing event handler lifecycle
/// - Providing a single access point for socket operations
/// - Ensuring proper cleanup and disposal
///
/// Example usage:
/// ```dart
/// final socketManager = SocketManager();
/// await socketManager.initialize('wss://api.example.com');
///
/// // Listen to messages
/// socketManager.eventHandler.messageStream.listen((data) {
///   // Handle incoming messages
/// });
///
/// // Send a message
/// socketManager.client.sendMessage(
///   chatId: 'chat123',
///   content: 'Hello!',
///   type: 'text'
/// );
/// ```
class SocketManager {
  /// Singleton instance for the SocketManager
  static final SocketManager _instance = SocketManager._internal();

  /// Factory constructor that returns the singleton instance
  factory SocketManager() => _instance;

  /// The socket client responsible for the actual WebSocket connection
  late SocketClient _socketClient;

  /// The event handler that processes incoming socket events
  late SocketEventHandler _socketEventHandler;

  /// Flag to track if the manager has been initialized
  bool _isInitialized = false;

  /// Private constructor for singleton pattern
  SocketManager._internal() {
    // Initialize the socket client
    _socketClient = SocketClient();
    // Initialize the event handler with the socket client dependency
    _socketEventHandler = SocketEventHandler(socketClient: _socketClient);
  }

  /// Initializes the socket manager by setting up the socket client.
  ///
  /// This method must be called before using any socket functionality.
  /// It ensures the socket client is properly configured and connected.
  ///
  /// [baseUrl] The WebSocket server URL to connect to
  ///
  /// Returns a [Future] that completes when initialization is finished
  /// Throws any exceptions that occur during socket client initialization
  Future<void> initialize(String baseUrl) async {
    // Prevent multiple initialization attempts
    if (_isInitialized) {
      return;
    }

    try {
      // Initialize the underlying socket client with the provided URL
      await _socketClient.initializeSocket(baseUrl);

      // Mark as initialized only after successful setup
      _isInitialized = true;
    } catch (error) {
      debugPrint('Error initializing socket manager: $error');

      // Re-throw the error to let the caller handle it
      rethrow;
    }
  }

  /// Provides access to the socket event handler for listening to socket events.
  ///
  /// Returns the [SocketEventHandler] instance that manages incoming events
  SocketEventHandler get eventHandler => _socketEventHandler;

  /// Provides access to the socket client for direct socket operations.
  ///
  /// Returns the [SocketClient] instance for emitting events and managing connection
  SocketClient get client => _socketClient;

  /// Checks if the socket is currently connected to the server.
  ///
  /// Returns true if connected, false otherwise
  bool get isConnected => _socketClient.isConnected;

  /// Disconnects from the socket server and resets initialization state.
  ///
  /// This method gracefully closes the connection and marks the manager as uninitialized
  void disconnect() {
    _socketClient.disconnect();
    _isInitialized = false;
  }

  /// Disposes of all resources used by the socket manager.
  ///
  /// This method should be called when the socket manager is no longer needed.
  /// It properly cleans up both the event handler and socket client.
  void dispose() {
    // Dispose event handler first to stop listening to events
    _socketEventHandler.dispose();
    // Then dispose the socket client to close the connection
    _socketClient.dispose();
    // Reset initialization state
    _isInitialized = false;
  }
}
