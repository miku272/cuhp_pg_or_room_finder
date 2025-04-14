import 'dart:async';

import 'package:flutter/foundation.dart';

import '../common/entities/chat.dart';
import '../common/entities/message.dart';

import './socket_client.dart';

class SocketEventHandler {
  final SocketClient _socketClient;
  StreamSubscription? _connectionSubscription;
  bool _areListenersAttached = false;

  SocketEventHandler({required SocketClient socketClient})
      : _socketClient = socketClient {
    _listenForConnectionChanges();
  }

  final _messageStreamController =
      StreamController<(Chat, Message)>.broadcast();
  final _typingStreamController =
      StreamController<Map<String, dynamic>>.broadcast();
  final _readReceiptStreamController =
      StreamController<Map<String, dynamic>>.broadcast();
  final _errorStreamController = StreamController<String>.broadcast();

  Stream<(Chat, Message)> get messageStream => _messageStreamController.stream;
  Stream<Map<String, dynamic>> get typingStream =>
      _typingStreamController.stream;
  Stream<Map<String, dynamic>> get readReceiptStream =>
      _readReceiptStreamController.stream;
  Stream<String> get errorStream => _errorStreamController.stream;

  void _listenForConnectionChanges() {
    _connectionSubscription?.cancel();
    _connectionSubscription =
        _socketClient.connectionStream.listen((isConnected) {
      if (isConnected && !_areListenersAttached) {
        _attachApplicationListeners();
        _areListenersAttached = true;
      } else if (!isConnected) {
        _areListenersAttached = false;
      }
    });
  }

  void _attachApplicationListeners() {
    _socketClient.on('receive_message', (data) {
      try {
        debugPrint('Received message: $data');
        if (data is Map<String, dynamic> &&
            data.containsKey('message') &&
            data.containsKey('chat')) {
          final updatedChat =
              Chat.fromJson(data['chat'] as Map<String, dynamic>);
          final updatedMessage =
              Message.fromJson(data['message'] as Map<String, dynamic>);
          if (!_messageStreamController.isClosed) {
            _messageStreamController.add((updatedChat, updatedMessage));
          }
        } else {
          debugPrint('SocketEventHandler: Invalid receive_message data format');
          if (!_errorStreamController.isClosed) {
            _errorStreamController.add('Invalid receive_message data format');
          }
        }
      } catch (e, s) {
        debugPrint('❌ Error processing received message: $e\n$s');
        if (!_errorStreamController.isClosed) {
          _errorStreamController.add('Error parsing received message: $e');
        }
      }
    });

    _socketClient.on('user_typing', (data) {
      try {
        debugPrint('User typing: $data');
        if (data is Map<String, dynamic> && !_typingStreamController.isClosed) {
          _typingStreamController.add(data);
        }
      } catch (e, s) {
        debugPrint('❌ Error processing typing indicator: $e\n$s');
        if (!_errorStreamController.isClosed) {
          _errorStreamController.add('Error parsing typing event: $e');
        }
      }
    });

    _socketClient.on('messages_read', (data) {
      try {
        debugPrint('Messages read: $data');
        if (data is Map<String, dynamic> &&
            !_readReceiptStreamController.isClosed) {
          _readReceiptStreamController.add(data);
        }
      } catch (e, s) {
        debugPrint('❌ Error processing read receipt: $e\n$s');
        if (!_errorStreamController.isClosed) {
          _errorStreamController.add('Error parsing read receipt event: $e');
        }
      }
    });
  }

  void dispose() {
    _connectionSubscription?.cancel();
    _messageStreamController.close();
    _typingStreamController.close();
    _readReceiptStreamController.close();
    _errorStreamController.close();
  }
}
