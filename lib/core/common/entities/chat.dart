import 'message.dart';

class Chat {
  final String id;
  final String senderId;
  final String receiverId;
  final String? propertyId;
  final Message? lastMessage;
  final DateTime? lastMessageTimestamp;
  final DateTime createdAt;
  final DateTime updatedAt;

  // Populated sender info
  final String? senderName;
  final String? senderEmail;
  final String? senderPhone;

  // Populated receiver info
  final String? receiverName;
  final String? receiverEmail;
  final String? receiverPhone;

  // Populated property info
  final String? propertyName;
  final String? propertyAddressLine1;
  final String? propertyVillageOrCity;

  const Chat({
    required this.id,
    required this.senderId,
    required this.receiverId,
    this.propertyId,
    this.lastMessage,
    this.lastMessageTimestamp,
    required this.createdAt,
    required this.updatedAt,
    this.senderName,
    this.senderEmail,
    this.senderPhone,
    this.receiverName,
    this.receiverEmail,
    this.receiverPhone,
    this.propertyName,
    this.propertyAddressLine1,
    this.propertyVillageOrCity,
  });

  factory Chat.fromJson(Map<String, dynamic> json) {
    return Chat(
      id: json['_id'],
      senderId: json['sender'] is Map ? json['sender']['_id'] : json['sender'],
      receiverId:
          json['receiver'] is Map ? json['receiver']['_id'] : json['receiver'],
      propertyId:
          json['property'] is Map ? json['property']['_id'] : json['property'],
      lastMessage: json['lastMessage'] != null
          ? Message.fromJson(json['lastMessage'])
          : null,
      lastMessageTimestamp: json['lastMessageTimestamp'] != null
          ? DateTime.parse(json['lastMessageTimestamp'])
          : null,
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),

      // Populated sender fields
      senderName: json['sender'] is Map ? json['sender']['name'] : null,
      senderEmail: json['sender'] is Map ? json['sender']['email'] : null,
      senderPhone: json['sender'] is Map ? json['sender']['phone'] : null,

      // Populated receiver fields
      receiverName: json['receiver'] is Map ? json['receiver']['name'] : null,
      receiverEmail: json['receiver'] is Map ? json['receiver']['email'] : null,
      receiverPhone: json['receiver'] is Map ? json['receiver']['phone'] : null,

      // Populated property fields
      propertyName:
          json['property'] is Map ? json['property']['propertyName'] : null,
      propertyAddressLine1: json['property'] is Map
          ? json['property']['propertyAddressLine1']
          : null,
      propertyVillageOrCity: json['property'] is Map
          ? json['property']['propertyVillageOrCity']
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'senderId': senderId,
      'receiverId': receiverId,
      'propertyId': propertyId,
      'lastMessage': lastMessage?.toJson(),
      'lastMessageTimestamp': lastMessageTimestamp?.toIso8601String(),
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  Chat copyWith({
    String? id,
    String? senderId,
    String? receiverId,
    String? propertyId,
    Message? lastMessage,
    DateTime? lastMessageTimestamp,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? senderName,
    String? senderEmail,
    String? senderPhone,
    String? receiverName,
    String? receiverEmail,
    String? receiverPhone,
    String? propertyName,
    String? propertyAddressLine1,
    String? propertyVillageOrCity,
  }) {
    return Chat(
      id: id ?? this.id,
      senderId: senderId ?? this.senderId,
      receiverId: receiverId ?? this.receiverId,
      propertyId: propertyId ?? this.propertyId,
      lastMessage: lastMessage ?? this.lastMessage,
      lastMessageTimestamp: lastMessageTimestamp ?? this.lastMessageTimestamp,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      senderName: senderName ?? this.senderName,
      senderEmail: senderEmail ?? this.senderEmail,
      senderPhone: senderPhone ?? this.senderPhone,
      receiverName: receiverName ?? this.receiverName,
      receiverEmail: receiverEmail ?? this.receiverEmail,
      receiverPhone: receiverPhone ?? this.receiverPhone,
      propertyName: propertyName ?? this.propertyName,
      propertyAddressLine1: propertyAddressLine1 ?? this.propertyAddressLine1,
      propertyVillageOrCity:
          propertyVillageOrCity ?? this.propertyVillageOrCity,
    );
  }
}
