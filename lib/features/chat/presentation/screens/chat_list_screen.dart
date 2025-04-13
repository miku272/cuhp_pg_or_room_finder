import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import '../../../../core/common/cubits/app_user/app_user_cubit.dart';
import '../../../../core/common/entities/user.dart';
import '../../../../core/utils/jwt_expiration_handler.dart';

import '../../../../init_dependencies.dart';

import '../../data/models/chat.dart';
import '../../data/models/message.dart';
import '../bloc/chat_bloc.dart';

class ChatListScreen extends StatefulWidget {
  const ChatListScreen({super.key});

  @override
  State<ChatListScreen> createState() => _ChatListScreenState();
}

class _ChatListScreenState extends State<ChatListScreen> {
  User? _currentUser;
  String? _lastShownErrorMessage;

  @override
  void initState() {
    super.initState();

    _currentUser = _getCurrentUser();
    _fetchInitialData();

    if (!context.read<ChatBloc>().state.isSocketConnected) {
      context.read<ChatBloc>().add(ChatConnectSocket());
    }
  }

  User? _getCurrentUser() {
    final user = context.read<AppUserCubit>().user;

    if (user != null) {
      return user;
    }
    return null;
  }

  void _fetchInitialData() {
    if (_currentUser == null) {
      ScaffoldMessenger.of(context)
        ..clearSnackBars()
        ..showSnackBar(
          const SnackBar(
            content: Text('User not found. Please log in again.'),
          ),
        );

      serviceLocator<JwtExpirationHandler>().stopExpiryCheck();
      context.read<AppUserCubit>().logoutUser(context);
      return;
    }

    final token = _currentUser!.jwtToken;
    if (token.isEmpty) {
      ScaffoldMessenger.of(context)
        ..clearSnackBars()
        ..showSnackBar(
          const SnackBar(
            content: Text('Authentication token missing. Please log in again.'),
          ),
        );

      serviceLocator<JwtExpirationHandler>().stopExpiryCheck();
      context.read<AppUserCubit>().logoutUser(context);
      return;
    }

    context.read<ChatBloc>().add(ChatFetchUserChats(token: token));
    context.read<ChatBloc>().add(ChatConnectSocket());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        centerTitle: false,
        title: const Text(
          'Chats',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: () {
              // TODO: Implement filter logic
            },
          ),
        ],
      ),
      body: BlocListener<ChatBloc, ChatState>(
        listenWhen: (previous, current) =>
            previous.status != current.status &&
            current.status == ChatStatus.chatsLoaded,
        listener: (context, state) {
          // Join all chat rooms when chats are loaded
          if (state.isSocketConnected && state.chats.isNotEmpty) {
            for (final chat in state.chats) {
              context.read<ChatBloc>().add(ChatJoinRoom(chatId: chat.id));
            }
          }
        },
        child: Column(
          children: <Widget>[
            _buildSearchBar(context),
            Expanded(
              child: BlocConsumer<ChatBloc, ChatState>(
                listener: (context, state) {
                  if (state.status == ChatStatus.failure &&
                      state.errorMessage != null &&
                      state.errorMessage != _lastShownErrorMessage) {
                    ScaffoldMessenger.of(context)
                      ..clearSnackBars()
                      ..showSnackBar(
                        SnackBar(
                          content: Text(state.errorMessage!),
                        ),
                      );

                    _lastShownErrorMessage =
                        state.errorMessage; // Track last shown error
                  } else if (state.status != ChatStatus.failure) {
                    _lastShownErrorMessage =
                        null; // Reset when not in failure state
                  }
                },
                builder: (context, state) {
                  if (state.status == ChatStatus.loadingChats &&
                      state.chats.isEmpty) {
                    return const CircularProgressIndicator();
                  }

                  if (state.status == ChatStatus.failure &&
                      state.chats.isEmpty) {
                    return Center(
                      child: Text(
                        state.errorMessage ?? 'Failed to load chats.',
                        style: TextStyle(
                            color: Theme.of(context).colorScheme.error),
                      ),
                    );
                  }

                  if (state.chats.isEmpty &&
                      state.status != ChatStatus.loadingChats) {
                    return const _EmptyChats();
                  }

                  // Display list using BlocBuilder's state
                  return RefreshIndicator(
                    onRefresh: () async {
                      _fetchInitialData(); // Re-fetch on pull-to-refresh
                    },
                    child: ListView.builder(
                      itemCount: state.chats.length,
                      itemBuilder: (context, index) {
                        final chat = state.chats[index];
                        return _ChatListItem(
                          chat: chat,
                          currentuser: _currentUser!,
                        );
                      },
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchBar(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
      decoration: BoxDecoration(
        color: theme.appBarTheme.backgroundColor ?? theme.colorScheme.surface,
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(20),
          bottomRight: Radius.circular(20),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Container(
        height: 48,
        decoration: BoxDecoration(
          color: theme.brightness == Brightness.light
              ? Colors.grey.shade200 // Lighter background for light theme
              : theme.colorScheme
                  .surfaceContainerHighest, // Slightly different surface for dark
          borderRadius: BorderRadius.circular(24),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Row(
          children: <Widget>[
            Icon(
              Icons.search,
              size: 20,
              color: theme.hintColor,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: TextField(
                decoration: InputDecoration(
                  hintText: 'Search chats...',
                  border: InputBorder.none,
                  hintStyle: TextStyle(color: theme.hintColor),
                ),
                onChanged: (value) {
                  // TODO: Implement search logic
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ChatListItem extends StatelessWidget {
  final Chat chat;
  final User currentuser;

  const _ChatListItem({required this.chat, required this.currentuser});

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
          // TODO: Navigate to chat detail screen
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
                    // Last message with indicators
                    Row(
                      children: <Widget>[
                        if (chat.lastMessage?.type != MessageType.text)
                          _buildMessageTypeIcon(chat.lastMessage?.type, theme),
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

class _EmptyChats extends StatelessWidget {
  const _EmptyChats();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Center(
      child: SingleChildScrollView(
        // Allow scrolling on small screens
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color:
                    theme.colorScheme.primaryContainer.withValues(alpha: 0.5),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.chat_bubble_outline_rounded,
                size: 60,
                color: theme.colorScheme.primary,
              ),
            ),
            const SizedBox(height: 32),
            Text(
              'No Chats Yet',
              style: theme.textTheme.headlineSmall
                  ?.copyWith(fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Text(
                'Start a conversation by finding a property and contacting the owner.',
                style:
                    theme.textTheme.bodyLarge?.copyWith(color: theme.hintColor),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 32),
            ElevatedButton.icon(
              icon: const Icon(Icons.search_rounded),
              label: const Text('Find Properties'),
              style: ElevatedButton.styleFrom(
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                textStyle: theme.textTheme.titleMedium,
              ),
              onPressed: () {
                // TODO: Navigate to the property search/listing screen
              },
            ),
            const SizedBox(height: 16),
            // Optional: Add a link or button to refresh
            // TextButton(
            //   onPressed: () {
            //     // Trigger a refresh, e.g., re-fetch chats
            //     final user = context.read<AppUserCubit>().user;
            //     if (user != null && user.jwtToken.isNotEmpty) {
            //       context.read<ChatBloc>().add(ChatFetchUserChats(token: user.jwtToken));
            //     }
            //   },
            //   child: const Text('Refresh'),
            // ),
          ],
        ),
      ),
    );
  }
}
