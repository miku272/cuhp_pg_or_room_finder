import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../../core/common/entities/user.dart';

import '../../../../core/common/entities/chat.dart';
import '../../../../core/common/entities/message.dart';

class ChatListItem extends StatelessWidget {
  final Chat chat;
  final User currentuser;
  final bool isTyping;

  const ChatListItem({
    required this.chat,
    required this.currentuser,
    this.isTyping = false,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final bool isCurrentUserLastSender =
        chat.lastMessage?.senderId != currentuser.id;
    final bool isUnread =
        isCurrentUserLastSender && !(chat.lastMessage?.isRead ?? true);

    final String chatWithUserId =
        (chat.senderId == currentuser.id ? chat.receiverId : chat.senderId);

    return Card(
      elevation: 0,
      margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 10),
      color: isUnread
          ? theme.colorScheme.primary.withValues(alpha: 0.08)
          : theme.cardColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: InkWell(
        onTap: () {
          context.push(
            '/chat/messages/${chat.id}',
            extra: chat,
          );
        },
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Avatar with online indicator
              Stack(
                children: <Widget>[
                  Hero(
                    tag: 'avatar_$chatWithUserId',
                    child: CircleAvatar(
                      radius: 28,
                      backgroundColor: _getAvatarColor(chatWithUserId, theme),
                      backgroundImage: _getAvatarImage(chatWithUserId),
                      child: _getAvatarImage(chatWithUserId) == null
                          ? Text(
                              _getInitials(chatWithUserId, chat),
                              style: const TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            )
                          : null,
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 16),
              // Chat details
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        // Receiver name
                        Expanded(
                          child: Text(
                            _getDisplayName(chatWithUserId, chat),
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight:
                                  isUnread ? FontWeight.bold : FontWeight.w600,
                              color: theme.textTheme.bodyLarge?.color,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 4),

                        if (chat.lastMessageTimestamp != null)
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: isUnread
                                  ? theme.colorScheme.primary
                                      .withValues(alpha: 0.2)
                                  : theme.disabledColor.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Text(
                              _formatTime(chat.lastMessageTimestamp),
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: isUnread
                                    ? FontWeight.bold
                                    : FontWeight.normal,
                                color: isUnread
                                    ? theme.colorScheme.primary
                                    : theme.textTheme.bodyLarge?.color
                                        ?.withValues(alpha: 0.6),
                              ),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    // Property name if available
                    if (chat.propertyId != null)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 4),
                        child: Row(
                          children: [
                            Icon(
                              Icons.home_outlined,
                              size: 14,
                              color: theme.colorScheme.secondary,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              chat.propertyName ?? 'Unknown Property',
                              style: TextStyle(
                                fontSize: 13,
                                color: theme.colorScheme.secondary,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    // Last message or typing indicator
                    isTyping
                        ? Text(
                            'Typing...',
                            style: TextStyle(
                              fontSize: 14,
                              fontStyle: FontStyle.italic,
                              color: theme.colorScheme.primary,
                            ),
                          )
                        : Row(
                            children: <Widget>[
                              if (chat.lastMessage?.type != MessageType.text)
                                _buildMessageTypeIcon(
                                    chat.lastMessage?.type, theme),
                              Expanded(
                                child: Text(
                                  _getMessagePreview(chat.lastMessage),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    fontSize: 14,
                                    height: 1.3,
                                    color: isUnread
                                        ? theme.textTheme.bodyLarge?.color
                                        : theme.textTheme.bodyLarge?.color
                                            ?.withValues(alpha: 0.7),
                                    fontWeight: isUnread
                                        ? FontWeight.w500
                                        : FontWeight.normal,
                                  ),
                                ),
                              ),
                            ],
                          ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Get initials for avatar fallback
  String _getInitials(String name, Chat chat) {
    final displayName = _getDisplayName(name, chat);
    final nameWords = displayName.split(' ');
    if (nameWords.length > 1) {
      return nameWords[0][0].toUpperCase() + nameWords[1][0].toUpperCase();
    }
    return displayName.substring(0, min(displayName.length, 2)).toUpperCase();
  }

  int min(int a, int b) => a < b ? a : b;

  // Get avatar image if available (null means use initials)
  ImageProvider? _getAvatarImage(String userId) {
    // In a real app, you would fetch actual profile images
    // For demo purposes, we'll return null to use initials instead
    return null;
  }

  // Get avatar background color based on user id
  Color _getAvatarColor(String userId, ThemeData theme) {
    final colors = [
      theme.colorScheme.primary,
      Colors.purple,
      Colors.indigo,
      Colors.teal,
      Colors.orange.shade800,
    ];

    return colors[userId.hashCode % colors.length];
  }

  Widget _buildMessageTypeIcon(MessageType? type, ThemeData theme) {
    IconData iconData;
    Color iconColor;

    switch (type) {
      case MessageType.image:
        iconData = Icons.photo;
        iconColor = Colors.blue.shade700;
        break;
      case MessageType.video:
        iconData = Icons.videocam;
        iconColor = Colors.red.shade700;
        break;
      case MessageType.audio:
        iconData = Icons.mic;
        iconColor = Colors.orange.shade700;
        break;
      case MessageType.file:
        iconData = Icons.attach_file;
        iconColor = Colors.purple.shade700;
        break;
      default:
        return const SizedBox.shrink();
    }

    return Container(
      padding: const EdgeInsets.only(right: 8),
      child: Icon(
        iconData,
        size: 18,
        color: iconColor,
      ),
    );
  }

  String _getMessagePreview(Message? message) {
    if (message == null) return 'No messages yet';

    switch (message.type) {
      case MessageType.text:
        return message.content;
      case MessageType.image:
        return '📷 Photo';
      case MessageType.video:
        return '🎥 Video';
      case MessageType.audio:
        return '🎤 Voice message';
      case MessageType.file:
        return '📎 File attachment';
    }
  }

  String _getDisplayName(String userId, Chat chat) {
    if (userId == chat.receiverId &&
        chat.receiverName != null &&
        chat.receiverName!.isNotEmpty) {
      return chat.receiverName!;
    } else if (userId == chat.senderId &&
        chat.senderName != null &&
        chat.senderName!.isNotEmpty) {
      return chat.senderName!;
    }
    // Fallback if names are not in the chat object
    return userId; // Or fetch user details if needed
  }

  String _formatTime(DateTime? dateTime) {
    if (dateTime == null) return '';

    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inDays > 7) {
      // Show full date for messages older than a week
      return DateFormat('dd MMM').format(dateTime);
    } else if (difference.inDays > 0) {
      // Show day of week for messages in the past week
      return DateFormat('E').format(dateTime);
    } else if (difference.inHours > 0) {
      // Show hours for messages from today
      return '${difference.inHours}h ago';
    } else if (difference.inMinutes > 0) {
      // Show minutes for recent messages
      return '${difference.inMinutes}m ago';
    } else {
      // Show 'Just now' for very recent messages
      return 'Just now';
    }
  }
}
