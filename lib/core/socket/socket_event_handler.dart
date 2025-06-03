import 'dart:async';

import 'package:flutter/foundation.dart';

import '../common/entities/chat.dart';
import '../common/entities/message.dart';

import './socket_client.dart';

/// Handles incoming WebSocket events and converts them to Flutter streams.
///
/// This class manages all incoming socket events from the server and processes
/// them into typed data streams that the UI can listen to. It automatically
/// manages event listener attachment based on connection state.
///
/// Key features:
/// - Converts raw socket events to typed streams
/// - Manages listener lifecycle based on connection state
/// - Provides separate streams for different event types
/// - Handles parsing errors gracefully
/// - Prevents memory leaks with proper stream management
///
/// Event streams available:
/// - [messageStream] - New chat messages received
/// - [typingStream] - User typing indicators
/// - [readReceiptStream] - Message read receipts
/// - [errorStream] - Parsing and processing errors
///
/// Example usage:
/// ```dart
/// final handler = SocketEventHandler(socketClient: socketClient);
///
/// // Listen to new messages
/// handler.messageStream.listen((data) {
///   final (chat, message) = data;
///   // Update UI with new message
/// });
///
/// // Listen to typing indicators
/// handler.typingStream.listen((data) {
///   // Show typing indicator in UI
/// });
/// ```
class SocketEventHandler {
  /// The socket client instance used for listening to events
  final SocketClient _socketClient;

  /// Subscription to monitor connection state changes
  StreamSubscription? _connectionSubscription;

  /// Flag to track if event listeners are currently attached
  bool _areListenersAttached = false;

  /// Constructor that sets up the handler with a socket client dependency
  SocketEventHandler({required SocketClient socketClient})
      : _socketClient = socketClient {
    // Start monitoring connection changes immediately
    _listenForConnectionChanges();
  }

  /// Stream controller for broadcasting incoming messages
  final _messageStreamController =
      StreamController<(Chat, Message)>.broadcast();

  /// Stream controller for broadcasting typing indicators
  final _typingStreamController =
      StreamController<Map<String, dynamic>>.broadcast();

  /// Stream controller for broadcasting read receipt events
  final _readReceiptStreamController =
      StreamController<Map<String, dynamic>>.broadcast();

  /// Stream controller for broadcasting error events
  final _errorStreamController = StreamController<String>.broadcast();

  /// Stream of incoming messages as (Chat, Message) tuples
  Stream<(Chat, Message)> get messageStream => _messageStreamController.stream;

  /// Stream of typing indicator events
  Stream<Map<String, dynamic>> get typingStream =>
      _typingStreamController.stream;

  /// Stream of message read receipt events
  Stream<Map<String, dynamic>> get readReceiptStream =>
      _readReceiptStreamController.stream;

  /// Stream of error events that occur during event processing
  Stream<String> get errorStream => _errorStreamController.stream;

  /// Monitors socket connection state and manages listener attachment.
  ///
  /// This method sets up a subscription to the socket's connection stream
  /// and automatically attaches/detaches event listeners based on connection state.
  void _listenForConnectionChanges() {
    // Cancel any existing subscription to prevent memory leaks
    _connectionSubscription?.cancel();
    _connectionSubscription =
        _socketClient.connectionStream.listen((isConnected) {
      // Attach listeners only when connected and not already attached
      if (isConnected && !_areListenersAttached) {
        _attachApplicationListeners();
        _areListenersAttached = true;
      } else if (!isConnected) {
        // Mark listeners as detached when disconnected
        _areListenersAttached = false;
      }
    });
  }

  /// Attaches event listeners for all application-specific socket events.
  ///
  /// This method sets up listeners for various socket events and processes
  /// the incoming data, converting it to appropriate stream events.
  void _attachApplicationListeners() {
    // Listen for incoming chat messages
    _socketClient.on('receive_message', (data) {
      try {
        debugPrint('Received message: $data');
        // Validate data structure before processing
        if (data is Map<String, dynamic> &&
            data.containsKey('message') &&
            data.containsKey('chat')) {
          // Parse the data into typed entities
          final updatedChat =
              Chat.fromJson(data['chat'] as Map<String, dynamic>);
          final updatedMessage =
              Message.fromJson(data['message'] as Map<String, dynamic>);
          // Emit to stream if not closed
          if (!_messageStreamController.isClosed) {
            _messageStreamController.add((updatedChat, updatedMessage));
          }
        } else {
          debugPrint('SocketEventHandler: Invalid receive_message data format');
          // Emit error for invalid data format
          if (!_errorStreamController.isClosed) {
            _errorStreamController.add('Invalid receive_message data format');
          }
        }
      } catch (e, s) {
        debugPrint('❌ Error processing received message: $e\n$s');
        // Emit parsing errors to error stream
        if (!_errorStreamController.isClosed) {
          _errorStreamController.add('Error parsing received message: $e');
        }
      }
    });

    // Listen for typing indicators from other users
    _socketClient.on('user_typing', (data) {
      try {
        debugPrint('User typing: $data');
        // Validate and emit typing data
        if (data is Map<String, dynamic> && !_typingStreamController.isClosed) {
          _typingStreamController.add(data);
        }
      } catch (e, s) {
        debugPrint('❌ Error processing typing indicator: $e\n$s');
        // Emit parsing errors to error stream
        if (!_errorStreamController.isClosed) {
          _errorStreamController.add('Error parsing typing event: $e');
        }
      }
    });

    // Listen for message read receipts
    _socketClient.on('messages_read', (data) {
      try {
        debugPrint('Messages read: $data');
        // Validate and emit read receipt data
        if (data is Map<String, dynamic> &&
            !_readReceiptStreamController.isClosed) {
          _readReceiptStreamController.add(data);
        }
      } catch (e, s) {
        debugPrint('❌ Error processing read receipt: $e\n$s');
        // Emit parsing errors to error stream
        if (!_errorStreamController.isClosed) {
          _errorStreamController.add('Error parsing read receipt event: $e');
        }
      }
    });
  }

  /// Disposes of all resources used by the event handler.
  ///
  /// This method should be called when the event handler is no longer needed.
  /// It cancels subscriptions and closes all stream controllers to prevent memory leaks.
  void dispose() {
    // Cancel connection monitoring subscription
    _connectionSubscription?.cancel();
    // Close all stream controllers to prevent memory leaks
    _messageStreamController.close();
    _typingStreamController.close();
    _readReceiptStreamController.close();
    _errorStreamController.close();
  }
}
