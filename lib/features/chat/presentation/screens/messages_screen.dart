import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import '../../../../core/common/cubits/app_socket/app_socket_cubit.dart'; // Import AppSocketCubit
import '../../../../core/common/cubits/app_user/app_user_cubit.dart';
import '../../../../core/common/entities/message.dart';
import '../../../../core/common/entities/chat.dart';
import '../../../../core/common/entities/user.dart';
import '../bloc/messages_bloc.dart';
import '../../data/models/chat_messages_data.dart';

class MessagesScreen extends StatefulWidget {
  final String chatId;
  final Chat? chatData; // Initial chat data (optional)

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
  bool _isLoadingMore = false;
  bool _canLoadMore = true;
  Timer? _typingDebouncer;

  User? get _currentUser => context.read<AppUserCubit>().user;
  String? get _userToken => context.read<AppUserCubit>().user?.jwtToken;

  @override
  void initState() {
    super.initState();
    _fetchInitialMessages(); // Renamed for clarity
    _scrollController.addListener(_onScroll);
    _messageController.addListener(_onTextChanged);
  }

  void _fetchInitialMessages() {
    final messagesBloc = context.read<MessagesBloc>();
    final token = _userToken;

    if (token == null) {
      // Keep auth error handling
      ScaffoldMessenger.of(context)
        ..clearSnackBars()
        ..showSnackBar(const SnackBar(
          content: Text('Authentication error. Please log in again.'),
          duration: Duration(seconds: 3),
        ));
      return;
    }

    // No need to connect socket here (handled by AppSocketCubit)
    // messagesBloc.add(ConnectSocketEvent());

    // Join chat room (MessagesBloc handles if connected)
    messagesBloc.add(JoinChatEvent(chatId: widget.chatId));

    // Fetch initial messages via API
    messagesBloc.add(GetMessagesViaAPIEvent(
      chatId: widget.chatId,
      page: 1,
      limit: 30,
      token: token,
    ));

    // Mark messages as read (MessagesBloc handles if connected)
    messagesBloc.add(MarkMessagesAsReadEvent(chatId: widget.chatId));
  }

  void _onScroll() {
    if (_scrollController.position.pixels ==
            _scrollController.position.minScrollExtent &&
        !_isLoadingMore &&
        _canLoadMore) {
      _loadMoreMessages();
    }
  }

  void _loadMoreMessages() {
    final messagesBloc = context.read<MessagesBloc>();
    final token = _userToken;
    // Access state safely
    final currentState = messagesBloc.state;
    final currentChatData = currentState.chatData[widget.chatId];

    if (token == null || currentChatData == null) return;

    // Check pagination status from ChatMessagesData
    if (currentChatData.currentPage >= currentChatData.totalPages) {
      if (_canLoadMore) {
        // Prevent unnecessary setState calls
        setState(() {
          _canLoadMore = false;
        });
      }
      return;
    }

    if (!_isLoadingMore) {
      // Prevent multiple concurrent loads
      setState(() {
        _isLoadingMore = true;
      });

      messagesBloc.add(GetMessagesViaAPIEvent(
        chatId: widget.chatId,
        page: currentChatData.currentPage + 1,
        limit: 30,
        token: token,
      ));
    }
  }

  void _onTextChanged() {
    final messagesBloc = context.read<MessagesBloc>();
    // No need to check connection here, Bloc handles it

    if (_typingDebouncer?.isActive ?? false) _typingDebouncer!.cancel();
    _typingDebouncer = Timer(const Duration(milliseconds: 500), () {
      if (_messageController.text.isNotEmpty) {
        // Dispatch event, Bloc checks connection
        messagesBloc.add(SendTypingIndicatorEvent(chatId: widget.chatId));
      }
    });
  }

  void _sendMessage() {
    final messagesBloc = context.read<MessagesBloc>();
    final content = _messageController.text.trim();

    if (content.isNotEmpty) {
      // Dispatch event, Bloc checks connection
      messagesBloc.add(SendMessageViaSocketEvent(
        chatId: widget.chatId,
        content: content,
        type: MessageType.text.name,
      ));
      _messageController.clear();
      _scrollToBottom();
    }
    // No explicit connection check/error message here needed,
    // rely on AppSocketCubit listener for general connection errors if desired.
  }

  void _scrollToBottom({bool animate = true}) {
    // Keep existing implementation
    Future.delayed(const Duration(milliseconds: 100), () {
      if (_scrollController.hasClients) {
        final maxScroll = _scrollController.position.maxScrollExtent;
        if (animate) {
          _scrollController.animateTo(
            maxScroll,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOut,
          );
        } else {
          _scrollController.jumpTo(maxScroll);
        }
      }
    });
  }

  // --- Getters using Bloc State ---
  ChatMessagesData? _getChatMessagesData(MessagesState state) {
    return state.chatData[widget.chatId];
  }

  Chat? _getChatDetails(MessagesState state) {
    return _getChatMessagesData(state)?.chat ?? widget.chatData;
  }

  String _getRecipientName(MessagesState state) {
    // Keep existing implementation
    final chat = _getChatDetails(state);
    final currentUser = _currentUser;
    if (chat == null || currentUser == null) return 'Chat';
    if (currentUser.id == chat.senderId) {
      return chat.receiverName ?? 'User';
    } else {
      return chat.senderName ?? 'User';
    }
  }

  String _getPropertyInfo(MessagesState state) {
    // Keep existing implementation
    final chat = _getChatDetails(state);
    if (chat == null || chat.propertyName == null) return '';
    return '${chat.propertyName}${chat.propertyAddressLine1 != null ? ', ${chat.propertyAddressLine1}' : ''}${chat.propertyVillageOrCity != null ? ', ${chat.propertyVillageOrCity}' : ''}';
  }

  @override
  void dispose() {
    _messageController.removeListener(_onTextChanged);
    _messageController.dispose();
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    _typingDebouncer?.cancel();
    // No need to disconnect socket here
    // context.read<MessagesBloc>().add(DisconnectSocketEvent());
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final currentUserId = _currentUser?.id;

    return MultiBlocListener(
      listeners: [
        // Listener for MessagesBloc state changes (API results, message updates)
        BlocListener<MessagesBloc, MessagesState>(
          listener: (context, state) {
            // Handle API fetch results for pagination
            if (state is GetMessagesViaAPISuccess ||
                state is GetMessagesViaAPIFailure) {
              if (state is GetMessagesViaAPIFailure &&
                  state.failedChatId == widget.chatId) {
                ScaffoldMessenger.of(context)
                  ..clearSnackBars()
                  ..showSnackBar(SnackBar(
                    content:
                        Text('Failed to load older messages: ${state.message}'),
                    duration: const Duration(seconds: 3),
                  ));
              }
              // Reset loading state regardless of success/failure for this chat
              if (_isLoadingMore) {
                setState(() {
                  _isLoadingMore = false;
                });
              }
              // Update _canLoadMore based on the latest data
              final chatData = state.chatData[widget.chatId];
              if (chatData != null) {
                final canStillLoad = chatData.currentPage < chatData.totalPages;
                if (_canLoadMore != canStillLoad) {
                  setState(() {
                    _canLoadMore = canStillLoad;
                  });
                }
              }

              // Scroll to bottom only on initial load (page 1 success)
              if (state is GetMessagesViaAPISuccess &&
                  state.chatData[widget.chatId]?.currentPage == 1) {
                _scrollToBottom(animate: false);
              }
            }

            // Handle new message received (via MessagesUpdated or ConcreteState)
            // Check if the state contains data for the current chat
            final chatData = state.chatData[widget.chatId];
            if (chatData != null) {
              // Simple scroll logic: if near bottom, scroll down.
              if (_scrollController.hasClients &&
                  _scrollController.position.extentAfter < 200) {
                _scrollToBottom();
              }
              // Mark as read if the new message is not from the current user
              final lastMessage =
                  chatData.messages.isNotEmpty ? chatData.messages.last : null;
              if (lastMessage != null &&
                  lastMessage.senderId != currentUserId) {
                context
                    .read<MessagesBloc>()
                    .add(MarkMessagesAsReadEvent(chatId: widget.chatId));
              }
            }
          },
        ),
        // Listener for AppSocketCubit state changes (Connection status, global errors)
        BlocListener<AppSocketCubit, AppSocketState>(
          listener: (context, socketState) {
            if (socketState is AppSocketError) {
              ScaffoldMessenger.of(context)
                ..hideCurrentSnackBar()
                ..showSnackBar(SnackBar(
                  content: Text('Connection Error: ${socketState.message}'),
                  duration: const Duration(seconds: 3),
                  backgroundColor: Colors.red,
                ));
            } else if (socketState is AppSocketDisconnected) {
              ScaffoldMessenger.of(context)
                ..hideCurrentSnackBar()
                ..showSnackBar(SnackBar(
                  content: Text(
                      'Disconnected: ${socketState.reason ?? "Connection lost"}'),
                  duration: const Duration(seconds: 3),
                  backgroundColor: Colors.orange,
                ));
            } else if (socketState is AppSocketConnecting) {
              ScaffoldMessenger.of(context)
                ..hideCurrentSnackBar()
                ..showSnackBar(const SnackBar(
                  content: Text('Connecting...'),
                  duration: Duration(seconds: 1), // Short duration
                ));
            } else if (socketState is AppSocketConnected) {
              ScaffoldMessenger.of(context)
                ..hideCurrentSnackBar()
                ..showSnackBar(const SnackBar(
                  content: Text('Connected'),
                  duration: Duration(seconds: 2),
                  backgroundColor: Colors.green,
                ));
              // Re-join chat if connection was re-established
              context
                  .read<MessagesBloc>()
                  .add(JoinChatEvent(chatId: widget.chatId));
            }
          },
        ),
      ],
      child: BlocBuilder<MessagesBloc, MessagesState>(
        builder: (context, state) {
          final chatMessagesData = _getChatMessagesData(state);
          final messages = chatMessagesData?.messages ?? [];
          // Use the specific loading state for API calls
          final isLoadingInitial = state is MessagesLoadingAPI &&
              state.loadingChatId == widget.chatId &&
              messages.isEmpty;
          final recipientName = _getRecipientName(state);
          final propertyInfo = _getPropertyInfo(state);
          // Get typing status from the bloc state
          final isTyping = state.typingStatus[widget.chatId] ?? false;

          debugPrint(
            "MessagesScreen Build: ChatID=${widget.chatId}, TypingStatusMap=${state.typingStatus}, isTyping=$isTyping",
          );

          return Scaffold(
            appBar: AppBar(
              titleSpacing: 0,
              elevation: 1,
              title: Row(
                children: [
                  // Back button is implicitly added by Navigator
                  const SizedBox(width: 4), // Adjust spacing if needed
                  CircleAvatar(
                    // Placeholder/Actual image logic
                    backgroundColor: Colors.grey.shade300,
                    child: Text(
                        recipientName.isNotEmpty ? recipientName[0] : '?',
                        style: const TextStyle(fontWeight: FontWeight.bold)),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          recipientName,
                          style: const TextStyle(
                              fontSize: 16, fontWeight: FontWeight.bold),
                          overflow: TextOverflow.ellipsis,
                        ),
                        if (propertyInfo.isNotEmpty && !isTyping)
                          Text(
                            propertyInfo,
                            style:
                                TextStyle(fontSize: 12, color: theme.hintColor),
                            overflow: TextOverflow.ellipsis,
                          ),
                        // Display typing indicator here
                        if (isTyping)
                          Text(
                            'typing...',
                            style: TextStyle(
                              fontSize: 12,
                              fontStyle: FontStyle.italic,
                              color: theme.hintColor,
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
              actions: [
                // Optional: Connection status indicator using AppSocketCubit state
                BlocBuilder<AppSocketCubit, AppSocketState>(
                  builder: (context, socketState) {
                    IconData? icon;
                    Color color;
                    if (socketState is AppSocketConnected) {
                      icon = null;
                      color = Colors.green;
                    } else if (socketState is AppSocketConnecting) {
                      icon = Icons.wifi_off;
                      color = Colors.orange; // Or a spinning icon
                    } else {
                      // Disconnected or Error
                      icon = Icons.wifi_off;
                      color = Colors.red;
                    }
                    return Padding(
                      padding: const EdgeInsets.only(right: 8.0),
                      child: Icon(icon, color: color, size: 20),
                    );
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.more_vert),
                  onPressed: () {
                    // TODO: Implement more options menu
                  },
                ),
              ],
            ),
            body: Column(
              children: [
                // Show loading indicator at the top when loading more
                if (_isLoadingMore)
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 8.0),
                    child: Center(
                        child: SizedBox(
                            height: 24,
                            width: 24,
                            child: CircularProgressIndicator(strokeWidth: 2))),
                  ),
                Expanded(
                  child: isLoadingInitial
                      ? const Center(child: CircularProgressIndicator())
                      : messages.isEmpty
                          ? _buildEmptyChat(theme)
                          : _buildMessagesList(
                              theme, messages, currentUserId ?? ''),
                ),
                _buildDivider(),
                _buildAttachmentMenu(theme),
                _buildMessageInput(theme),
              ],
            ),
          );
        },
      ),
    );
  }

  // --- Keep existing helper widgets ---
  Widget _buildEmptyChat(ThemeData theme) {
    // ... existing implementation ...
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.chat_bubble_outline,
            size: 80,
            color: theme.colorScheme.primary
                .withValues(alpha: 0.5), // Use withOpacity
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
              color: theme.colorScheme.onSurface
                  .withValues(alpha: 0.6), // Use withOpacity
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMessagesList(
      ThemeData theme, List<Message> messages, String currentUserId) {
    // ... existing implementation ...
    return ListView.builder(
      controller: _scrollController,
      // reverse: true, // Set to true if you want newest messages at the bottom AND load older messages at the top
      padding: const EdgeInsets.all(16),
      itemCount: messages.length,
      itemBuilder: (context, index) {
        final message = messages[index];
        final isCurrentUser = message.senderId == currentUserId;

        final bool showDate;
        if (index == 0) {
          showDate = true;
        } else {
          final previousMessage = messages[index - 1];
          showDate = !_isSameDay(previousMessage.createdAt, message.createdAt);
        }

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
    // ... existing implementation ...
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 16),
      child: Row(
        children: [
          Expanded(child: Divider(color: theme.dividerColor)),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Text(
              _formatDateSeparator(date), // Use helper
              style: theme.textTheme.labelSmall?.copyWith(
                color: theme.colorScheme.onSurface
                    .withValues(alpha: 0.6), // Use withOpacity
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
    // ... existing implementation ...
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
    // ... existing implementation ...
    final borderRadius = BorderRadius.only(
      topLeft: const Radius.circular(18),
      topRight: const Radius.circular(18),
      bottomLeft:
          isCurrentUser ? const Radius.circular(18) : const Radius.circular(4),
      bottomRight:
          isCurrentUser ? const Radius.circular(4) : const Radius.circular(18),
    );

    // Ensure message.type comparison works with the enum
    if (message.type == MessageType.image) {
      // Compare with enum value
      return ClipRRect(
        borderRadius: borderRadius,
        child: Stack(
          children: [
            // Placeholder for image loading
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: isCurrentUser
                    ? theme.colorScheme.primaryContainer
                    : theme.colorScheme.surfaceContainerHighest,
                borderRadius: borderRadius,
              ),
              child: Text(message.content,
                  style: const TextStyle(
                      fontStyle:
                          FontStyle.italic)), // Show URL or placeholder text
            ),
            // Optional: Add overlay for image type indication if needed
          ],
        ),
      );
    } else {
      // Default to text
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: isCurrentUser
              ? theme.colorScheme
                  .primaryContainer // Use primaryContainer for user's messages
              : theme.colorScheme
                  .surfaceContainerHighest, // Use surface variant for others
          borderRadius: borderRadius,
        ),
        child: Text(
          message.content,
          style: TextStyle(
            color: isCurrentUser
                ? theme.colorScheme.onPrimaryContainer
                : theme.colorScheme.onSurface,
          ),
        ),
      );
    }
  }

  Widget _buildMessageTimestamp(
      Message message, bool isCurrentUser, ThemeData theme) {
    // ... existing implementation ...
    return Padding(
      padding:
          const EdgeInsets.only(left: 4, right: 4, top: 2), // Added top padding
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            _formatMessageTime(message.createdAt), // Use helper
            style: TextStyle(
              fontSize: 10, // Smaller font size
              color: theme.colorScheme.onSurface
                  .withValues(alpha: 0.5), // Use withOpacity
            ),
          ),
          if (isCurrentUser) ...[
            // Add read receipt checkmark
            const SizedBox(width: 4),
            Icon(
              message.isRead ? Icons.done_all : Icons.done,
              size: 14, // Smaller icon size
              color: message.isRead
                  ? Colors.blue // Or theme.colorScheme.primary
                  : theme.colorScheme.onSurface
                      .withValues(alpha: 0.5), // Use withOpacity
            ),
          ]
        ],
      ),
    );
  }

  Widget _buildDivider() {
    // ... existing implementation ...
    return const Divider(height: 1);
  }

  Widget _buildAttachmentMenu(ThemeData theme) {
    // ... existing implementation ...
    if (!_isAttachmentMenuOpen) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      color: theme.colorScheme.surface, // Use theme color
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildAttachmentOption(
            icon: Icons.photo,
            color: Colors.deepPurple, // Use theme colors if possible
            label: 'Gallery',
            onTap: () {
              // TODO: Implement gallery picker
              setState(() => _isAttachmentMenuOpen = false);
            },
          ),
          _buildAttachmentOption(
            icon: Icons.camera_alt,
            color: Colors.redAccent,
            label: 'Camera',
            onTap: () {
              // TODO: Implement camera
              setState(() => _isAttachmentMenuOpen = false);
            },
          ),
          _buildAttachmentOption(
            icon: Icons.insert_drive_file,
            color: Colors.blueAccent,
            label: 'Document',
            onTap: () {
              // TODO: Implement document picker
              setState(() => _isAttachmentMenuOpen = false);
            },
          ),
          _buildAttachmentOption(
            icon: Icons.location_on,
            color: Colors.green,
            label: 'Location',
            onTap: () {
              // TODO: Implement location sharing
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
    // ... existing implementation ...
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(30),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircleAvatar(
              radius: 24, // Slightly larger
              backgroundColor: color.withValues(alpha: 0.1), // Background tint
              child: Icon(icon, color: color, size: 24),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: Theme.of(context).textTheme.bodySmall, // Use text theme
            ),
          ],
        ),
      ),
    );
  }

  // --- Helper Functions (Keep existing ones) ---
  bool _isSameDay(DateTime date1, DateTime date2) {
    // ... existing implementation ...
    return date1.year == date2.year &&
        date1.month == date2.month &&
        date1.day == date2.day;
  }

  String _formatDateSeparator(DateTime date) {
    // ... existing implementation ...
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final messageDate = DateTime(date.year, date.month, date.day);

    if (messageDate == today) {
      return 'Today';
    } else if (messageDate == yesterday) {
      return 'Yesterday';
    } else if (now.difference(date).inDays < 7) {
      return DateFormat('EEEE').format(date); // Day of the week
    } else {
      return DateFormat('MMM d, yyyy').format(date); // Full date
    }
  }

  String _formatMessageTime(DateTime date) {
    // ... existing implementation ...
    return DateFormat('h:mm a').format(date.toLocal()); // Use local time
  }

  // --- Updated Message Input ---
  Widget _buildMessageInput(ThemeData theme) {
    // ... existing implementation ...
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      color: theme.scaffoldBackgroundColor, // Or theme.colorScheme.surface
      child: Row(
        children: [
          IconButton(
            icon: Icon(
              _isAttachmentMenuOpen
                  ? Icons.close
                  : Icons.add_circle_outline, // Changed icon
              color: theme.colorScheme.primary,
            ),
            onPressed: () {
              FocusScope.of(context).unfocus(); // Close keyboard
              setState(() {
                _isAttachmentMenuOpen = !_isAttachmentMenuOpen;
              });
            },
          ),
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14),
              decoration: BoxDecoration(
                color: theme
                    .colorScheme.surfaceContainerHighest, // Use theme color
                borderRadius: BorderRadius.circular(24),
              ),
              child: TextField(
                controller: _messageController,
                decoration: InputDecoration(
                  hintText: 'Type a message...',
                  border: InputBorder.none,
                  hintStyle: TextStyle(color: theme.hintColor),
                ),
                textCapitalization: TextCapitalization.sentences,
                minLines: 1,
                maxLines: 5, // Allow multi-line input
              ),
            ),
          ),
          const SizedBox(width: 8),
          // Send Button
          FloatingActionButton(
            mini: true,
            onPressed: _sendMessage, // Call the send message function
            elevation: 1,
            backgroundColor: theme.colorScheme.primary,
            child:
                Icon(Icons.send, color: theme.colorScheme.onPrimary, size: 20),
          ),
        ],
      ),
    );
  }
}
