enum MessageType { text, image, video, audio, file }

class Message {
  final String id;
  final String chatId;
  final String senderId;
  final String content;
  final MessageType type;
  final bool isRead;
  final DateTime createdAt;
  final DateTime? updatedAt;

  // Populated sender fields
  final String? senderName;
  final String? senderEmail;
  final String? senderPhone;

  Message({
    required this.id,
    required this.chatId,
    required this.senderId,
    required this.content,
    required this.type,
    required this.isRead,
    required this.createdAt,
    this.updatedAt,
    this.senderName,
    this.senderEmail,
    this.senderPhone,
  });

  factory Message.fromJson(Map<String, dynamic> json) {
    return Message(
      id: json['_id'],
      chatId: json['chatId'],
      senderId: json['sender'] is Map ? json['sender']['_id'] : json['sender'],
      content: json['content'],
      type: _getMessageTypeFromString(json['type']),
      isRead: json['isRead'] ?? false,
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt:
          json['updatedAt'] != null ? DateTime.parse(json['updatedAt']) : null,

      // Populated sender fields
      senderName: json['sender'] is Map ? json['sender']['name'] : null,
      senderEmail: json['sender'] is Map ? json['sender']['email'] : null,
      senderPhone: json['sender'] is Map ? json['sender']['phone'] : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'chatId': chatId,
      'senderId': senderId,
      'content': content,
      'type': _getStringFromMessageType(type),
      'isRead': isRead,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }

  static MessageType _getMessageTypeFromString(String type) {
    switch (type) {
      case 'text':
        return MessageType.text;
      case 'image':
        return MessageType.image;
      case 'video':
        return MessageType.video;
      case 'audio':
        return MessageType.audio;
      case 'file':
        return MessageType.file;
      default:
        return MessageType.text;
    }
  }

  static String _getStringFromMessageType(MessageType type) {
    switch (type) {
      case MessageType.text:
        return 'text';
      case MessageType.image:
        return 'image';
      case MessageType.video:
        return 'video';
      case MessageType.audio:
        return 'audio';
      case MessageType.file:
        return 'file';
    }
  }

  Message copyWith({
    String? id,
    String? chatId,
    String? senderId,
    String? content,
    MessageType? type,
    bool? isRead,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? senderName,
    String? senderEmail,
    String? senderPhone,
  }) {
    return Message(
      id: id ?? this.id,
      chatId: chatId ?? this.chatId,
      senderId: senderId ?? this.senderId,
      content: content ?? this.content,
      type: type ?? this.type,
      isRead: isRead ?? this.isRead,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      senderName: senderName ?? this.senderName,
      senderEmail: senderEmail ?? this.senderEmail,
      senderPhone: senderPhone ?? this.senderPhone,
    );
  }
}
