import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../core/common/entities/message.dart';
import '../../../../core/common/entities/chat.dart';
import '../../../../core/common/entities/user.dart';

class MessagesScreen extends StatefulWidget {
  final String chatId;
  final Chat? chatData;

  const MessagesScreen({
    required this.chatId,
    this.chatData,
    super.key,
  });

  @override
  State<MessagesScreen> createState() => _MessagesScreenState();
}

class _MessagesScreenState extends State<MessagesScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  bool _isAttachmentMenuOpen = false;
  bool _isTyping = false;

  // Dummy user for demonstration
  final User _currentUser = User(
    id: '123',
    name: 'Current User',
    email: 'user@example.com',
    phone: '1234567890',
    jwtToken: '',
    expiresIn: DateTime.now().add(const Duration(days: 1)).toIso8601String(),
    isEmailVerified: false,
    isPhoneVerified: false,
    createdAt: DateTime.now().toIso8601String(),
    updatedAt: DateTime.now().toIso8601String(),
    property: const <String>[],
  );

  // Dummy messages for demonstration
  final List<Message> _messages = [
    Message(
      id: '1',
      chatId: 'chat123',
      senderId: '456',
      senderName: 'Property Owner',
      content:
          'Hello! I saw you were interested in my property. Is it still available?',
      type: MessageType.text,
      isRead: true,
      createdAt: DateTime.now().subtract(const Duration(days: 1, hours: 3)),
    ),
    Message(
      id: '2',
      chatId: 'chat123',
      senderId: '123',
      senderName: 'Current User',
      content:
          'Yes, I\'m interested in renting it. Could you tell me more about the utilities included?',
      type: MessageType.text,
      isRead: true,
      createdAt: DateTime.now()
          .subtract(const Duration(days: 1, hours: 2, minutes: 45)),
    ),
    Message(
      id: '3',
      chatId: 'chat123',
      senderId: '456',
      senderName: 'Property Owner',
      content:
          'Sure! Water and electricity are included in the rent. Internet is available but costs extra. The room also comes with basic furniture.',
      type: MessageType.text,
      isRead: true,
      createdAt: DateTime.now()
          .subtract(const Duration(days: 1, hours: 2, minutes: 30)),
    ),
    Message(
      id: '4',
      chatId: 'chat123',
      senderId: '456',
      senderName: 'Property Owner',
      content: 'Here are some more photos of the room',
      type: MessageType.text,
      isRead: true,
      createdAt: DateTime.now().subtract(const Duration(hours: 1)),
    ),
    Message(
      id: '5',
      chatId: 'chat123',
      senderId: '456',
      senderName: 'Property Owner',
      content: 'https://picsum.photos/400/300',
      type: MessageType.image,
      isRead: false,
      createdAt: DateTime.now().subtract(const Duration(minutes: 59)),
    ),
    Message(
      id: '6',
      chatId: 'chat123',
      senderId: '123',
      senderName: 'Current User',
      content: 'That looks great! When can I come to see it in person?',
      type: MessageType.text,
      isRead: false,
      createdAt: DateTime.now().subtract(const Duration(minutes: 30)),
    ),
  ];

  String _getRecipientName() {
    final chat = widget.chatData;
    if (chat == null) return 'Chat';

    if (_currentUser.id == chat.senderId) {
      return chat.receiverName ?? 'User';
    } else {
      return chat.senderName ?? 'User';
    }
  }

  String _getPropertyInfo() {
    final chat = widget.chatData;
    if (chat == null || chat.propertyName == null) return '';
    return chat.propertyName!;
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        titleSpacing: 0,
        elevation: 1,
        title: Row(
          children: [
            Hero(
              tag: 'avatar_${widget.chatId}',
              child: CircleAvatar(
                radius: 20,
                backgroundColor: theme.colorScheme.primary,
                child: Text(
                  _getRecipientName().substring(0, 1).toUpperCase(),
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _getRecipientName(),
                    style: const TextStyle(fontSize: 16),
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (_getPropertyInfo().isNotEmpty)
                    Text(
                      _getPropertyInfo(),
                      style: TextStyle(
                        fontSize: 12,
                        color: theme.colorScheme.onSurface.withValues(
                          alpha: 0.7,
                        ),
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.info_outline),
            onPressed: () {
              // Show property details or chat info
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: GestureDetector(
              onTap: () => FocusScope.of(context).unfocus(),
              child: _messages.isEmpty
                  ? _buildEmptyChat(theme)
                  : _buildMessagesList(theme),
            ),
          ),
          _buildDivider(),
          _buildAttachmentMenu(theme),
          _buildMessageInput(theme),
        ],
      ),
    );
  }

  Widget _buildEmptyChat(ThemeData theme) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.chat_bubble_outline,
            size: 80,
            color: theme.colorScheme.primary.withValues(alpha: 0.5),
          ),
          const SizedBox(height: 16),
          Text(
            'No messages yet',
            style: theme.textTheme.titleLarge,
          ),
          const SizedBox(height: 8),
          Text(
            'Start a conversation now',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMessagesList(ThemeData theme) {
    return ListView.builder(
      controller: _scrollController,
      reverse: false,
      padding: const EdgeInsets.all(16),
      itemCount: _messages.length,
      itemBuilder: (context, index) {
        final message = _messages[index];
        final isCurrentUser = message.senderId == _currentUser.id;
        final showDate = index == 0 ||
            !_isSameDay(
              _messages[index - 1].createdAt,
              message.createdAt,
            );

        return Column(
          children: [
            if (showDate) _buildDateSeparator(message.createdAt, theme),
            _buildMessageItem(message, isCurrentUser, theme),
          ],
        );
      },
    );
  }

  Widget _buildDateSeparator(DateTime date, ThemeData theme) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 16),
      child: Row(
        children: [
          Expanded(child: Divider(color: theme.dividerColor)),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Text(
              _formatDateSeparator(date),
              style: TextStyle(
                fontSize: 12,
                color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(child: Divider(color: theme.dividerColor)),
        ],
      ),
    );
  }

  Widget _buildMessageItem(
      Message message, bool isCurrentUser, ThemeData theme) {
    return Align(
      alignment: isCurrentUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.75,
        ),
        margin: const EdgeInsets.symmetric(vertical: 4),
        child: Column(
          crossAxisAlignment:
              isCurrentUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          children: [
            _buildMessageContent(message, isCurrentUser, theme),
            const SizedBox(height: 2),
            _buildMessageTimestamp(message, isCurrentUser, theme),
          ],
        ),
      ),
    );
  }

  Widget _buildMessageContent(
      Message message, bool isCurrentUser, ThemeData theme) {
    final borderRadius = BorderRadius.only(
      topLeft: const Radius.circular(18),
      topRight: const Radius.circular(18),
      bottomLeft:
          isCurrentUser ? const Radius.circular(18) : const Radius.circular(4),
      bottomRight:
          isCurrentUser ? const Radius.circular(4) : const Radius.circular(18),
    );

    switch (message.type) {
      case MessageType.image:
        return ClipRRect(
          borderRadius: borderRadius,
          child: Stack(
            children: [
              Container(
                width: double.infinity,
                constraints: BoxConstraints(
                  maxHeight: MediaQuery.of(context).size.height * 0.3,
                ),
                color: isCurrentUser
                    ? theme.colorScheme.primary.withValues(alpha: 0.1)
                    : theme.colorScheme.surface,
                child: Image.network(
                  message.content,
                  fit: BoxFit.cover,
                  loadingBuilder: (context, child, loadingProgress) {
                    if (loadingProgress == null) return child;
                    return SizedBox(
                      height: 200,
                      child: Center(
                        child: CircularProgressIndicator(
                          value: loadingProgress.expectedTotalBytes != null
                              ? loadingProgress.cumulativeBytesLoaded /
                                  loadingProgress.expectedTotalBytes!
                              : null,
                        ),
                      ),
                    );
                  },
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      height: 200,
                      color: theme.colorScheme.errorContainer,
                      child: Center(
                        child: Icon(
                          Icons.broken_image,
                          color: theme.colorScheme.onErrorContainer,
                          size: 40,
                        ),
                      ),
                    );
                  },
                ),
              ),
              Positioned(
                bottom: 8,
                right: 8,
                child: Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.6),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Icon(
                    Icons.photo,
                    color: Colors.white,
                    size: 16,
                  ),
                ),
              ),
            ],
          ),
        );

      case MessageType.text:
      default:
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          decoration: BoxDecoration(
            color: isCurrentUser
                ? theme.colorScheme.primary
                : theme.colorScheme.surfaceContainerHighest,
            borderRadius: borderRadius,
          ),
          child: Text(
            message.content,
            style: TextStyle(
              fontSize: 16,
              color: isCurrentUser
                  ? theme.colorScheme.onPrimary
                  : theme.colorScheme.onSurface,
            ),
          ),
        );
    }
  }

  Widget _buildMessageTimestamp(
      Message message, bool isCurrentUser, ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, right: 4),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            _formatMessageTime(message.createdAt),
            style: TextStyle(
              fontSize: 11,
              color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
            ),
          ),
          const SizedBox(width: 4),
          if (isCurrentUser)
            Icon(
              message.isRead ? Icons.done_all : Icons.done,
              size: 14,
              color: message.isRead
                  ? theme.colorScheme.primary
                  : theme.colorScheme.onSurface.withValues(alpha: 0.5),
            ),
        ],
      ),
    );
  }

  Widget _buildDivider() {
    return const Divider(height: 1);
  }

  Widget _buildAttachmentMenu(ThemeData theme) {
    if (!_isAttachmentMenuOpen) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      color: theme.colorScheme.surface,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildAttachmentOption(
            icon: Icons.photo,
            color: Colors.blue,
            label: 'Photo',
            onTap: () {
              // Photo attachment logic
              setState(() => _isAttachmentMenuOpen = false);
            },
          ),
          _buildAttachmentOption(
            icon: Icons.camera_alt,
            color: Colors.purple,
            label: 'Camera',
            onTap: () {
              // Camera attachment logic
              setState(() => _isAttachmentMenuOpen = false);
            },
          ),
          _buildAttachmentOption(
            icon: Icons.videocam,
            color: Colors.red,
            label: 'Video',
            onTap: () {
              // Video attachment logic
              setState(() => _isAttachmentMenuOpen = false);
            },
          ),
          _buildAttachmentOption(
            icon: Icons.insert_drive_file,
            color: Colors.orange,
            label: 'Document',
            onTap: () {
              // Document attachment logic
              setState(() => _isAttachmentMenuOpen = false);
            },
          ),
          _buildAttachmentOption(
            icon: Icons.location_on,
            color: Colors.green,
            label: 'Location',
            onTap: () {
              // Location attachment logic
              setState(() => _isAttachmentMenuOpen = false);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildAttachmentOption({
    required IconData icon,
    required Color color,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(50),
              border: Border.all(color: color.withValues(alpha: 0.2)),
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(fontSize: 12, color: color),
          ),
        ],
      ),
    );
  }

  Widget _buildMessageInput(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      color: theme.scaffoldBackgroundColor,
      child: Row(
        children: [
          IconButton(
            icon: Icon(
              _isAttachmentMenuOpen ? Icons.close : Icons.attach_file,
              color: theme.colorScheme.primary,
            ),
            onPressed: () {
              setState(() => _isAttachmentMenuOpen = !_isAttachmentMenuOpen);
            },
          ),
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: theme.colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(24),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _messageController,
                      decoration: InputDecoration(
                        hintText: 'Message',
                        hintStyle: TextStyle(color: theme.hintColor),
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 10,
                        ),
                      ),
                      minLines: 1,
                      maxLines: 5,
                      onChanged: (value) {
                        setState(() {
                          _isTyping = value.trim().isNotEmpty;
                        });
                      },
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.emoji_emotions_outlined),
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                    onPressed: () {
                      // Open emoji picker
                    },
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 8),
          CircleAvatar(
            radius: 24,
            backgroundColor: theme.colorScheme.primary,
            child: IconButton(
              icon: Icon(
                _isTyping ? Icons.send : Icons.mic,
                color: theme.colorScheme.onPrimary,
              ),
              onPressed: _isTyping
                  ? () {
                      // Send message logic
                      final text = _messageController.text.trim();
                      if (text.isEmpty) return;

                      // Clear the input field
                      _messageController.clear();
                      setState(() {
                        _isTyping = false;
                      });

                      // In a real app, you would send this message to your backend
                      print('Message sent: $text');
                    }
                  : () {
                      // Voice message logic
                    },
            ),
          ),
        ],
      ),
    );
  }

  String _formatMessageTime(DateTime time) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final messageDate = DateTime(time.year, time.month, time.day);

    if (messageDate == today) {
      // Today, just show the time
      return DateFormat('HH:mm').format(time);
    } else if (messageDate == today.subtract(const Duration(days: 1))) {
      // Yesterday
      return 'Yesterday, ${DateFormat('HH:mm').format(time)}';
    } else {
      // Another day
      return DateFormat('MMM d, HH:mm').format(time);
    }
  }

  String _formatDateSeparator(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final messageDate = DateTime(date.year, date.month, date.day);

    if (messageDate == today) {
      return 'Today';
    } else if (messageDate == yesterday) {
      return 'Yesterday';
    } else if (now.difference(date).inDays < 7) {
      // Within the last week
      return DateFormat('EEEE').format(date); // Day name
    } else {
      // Older than a week
      return DateFormat('MMMM d, y').format(date);
    }
  }

  bool _isSameDay(DateTime date1, DateTime date2) {
    return date1.year == date2.year &&
        date1.month == date2.month &&
        date1.day == date2.day;
  }
}
