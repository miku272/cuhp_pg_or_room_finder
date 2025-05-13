import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/common/cubits/app_socket/app_socket_cubit.dart';
import '../../../../core/common/cubits/app_user/app_user_cubit.dart';
import '../../../../core/common/entities/chat.dart';
import '../../../../core/common/entities/user.dart';
import '../../../../core/utils/jwt_expiration_handler.dart';

import '../../../../init_dependencies.dart';

import '../bloc/chat_bloc.dart';

import '../widgets/chat_list_item.dart';
import '../widgets/empty_chat_list.dart';

enum ChatSortCriteria {
  lastActivity,
  unreadFirst,
  participantName,
  propertyName,
}

class ChatListScreen extends StatefulWidget {
  const ChatListScreen({super.key});

  @override
  State<ChatListScreen> createState() => _ChatListScreenState();
}

class _ChatListScreenState extends State<ChatListScreen> {
  User? _currentUser;
  String? _lastShownErrorMessage;

  final TextEditingController _searchController = TextEditingController();
  String _searchText = '';

  ChatSortCriteria _currentSortCriteria = ChatSortCriteria.lastActivity;

  @override
  void initState() {
    super.initState();

    _currentUser = _getCurrentUser();
    _fetchInitialData();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _searchController.addListener(() {
        if (_searchText != _searchController.text) {
          setState(() {
            _searchText = _searchController.text;
          });
        }
      });
    });
  }

  User? _getCurrentUser() {
    final user = context.read<AppUserCubit>().user;

    return user;
  }

  int _compareChatTimestamps(Chat a, Chat b) {
    final timeA = a.lastMessageTimestamp ?? a.createdAt;
    final timeB = b.lastMessageTimestamp ?? b.createdAt;

    return timeB.compareTo(timeA);
  }

  List<Chat> _sortChats(List<Chat> chats, ChatSortCriteria chatSortCriteria) {
    final List<Chat> sortedList = List.from(chats);
    final currentUserId = _currentUser?.id;

    sortedList.sort((a, b) {
      switch (chatSortCriteria) {
        case ChatSortCriteria.unreadFirst:
          final isAUnread = a.lastMessage != null &&
              !a.lastMessage!.isRead &&
              a.lastMessage!.senderId != currentUserId;
          final isBUnread = b.lastMessage != null &&
              !b.lastMessage!.isRead &&
              b.lastMessage!.senderId != currentUserId;
          if (isAUnread && !isBUnread) return -1;
          if (!isAUnread && isBUnread) return 1;
          return _compareChatTimestamps(a, b); // Secondary sort by time

        case ChatSortCriteria.participantName:
          final nameA =
              (a.senderId == currentUserId ? a.receiverName : a.senderName) ??
                  '';
          final nameB =
              (b.senderId == currentUserId ? b.receiverName : b.senderName) ??
                  '';
          final nameComparison =
              nameA.toLowerCase().compareTo(nameB.toLowerCase());
          if (nameComparison != 0) return nameComparison;
          return _compareChatTimestamps(a, b); // Secondary sort by time

        case ChatSortCriteria.propertyName:
          final propA = a.propertyName ?? '';
          final propB = b.propertyName ?? '';
          final propComparison =
              propA.toLowerCase().compareTo(propB.toLowerCase());
          if (propComparison != 0) return propComparison;
          return _compareChatTimestamps(a, b); // Secondary sort by time

        case ChatSortCriteria.lastActivity:
          return _compareChatTimestamps(a, b);
      }
    });

    return sortedList;
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
  }

  @override
  void dispose() {
    _searchController.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
      },
      child: Scaffold(
        appBar: AppBar(
          elevation: 0,
          centerTitle: false,
          title: const Text(
            'Chats',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          actions: [
            _buildSortMenuButton(context, _currentSortCriteria),
          ],
        ),
        body: BlocListener<AppSocketCubit, AppSocketState>(
          listener: (context, socketState) {
            if (socketState is AppSocketError) {
              // Show persistent error if needed, ChatBloc handles action failures
              // ScaffoldMessenger.of(context)
              //   ..clearSnackBars()
              //   ..showSnackBar(SnackBar(content: Text('Connection Error: ${socketState.message}')));
              debugPrint(
                  "AppSocket Error in ChatListScreen: ${socketState.message}");
            } else if (socketState is AppSocketDisconnected) {
              // Optionally show a disconnected message
              debugPrint(
                  "AppSocket Disconnected in ChatListScreen: ${socketState.reason}");
            }
          },
          child: BlocListener<ChatBloc, ChatState>(
            listenWhen: (previous, current) =>
                previous.status != current.status &&
                current.status == ChatStatus.chatsLoaded,
            listener: (context, state) {
              if (context.read<AppSocketCubit>().isConnected &&
                  state.chats.isNotEmpty) {
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

                        _lastShownErrorMessage = state.errorMessage;
                      } else if (state.status != ChatStatus.failure) {
                        _lastShownErrorMessage =
                            null; // Reset when not in failure state
                      }
                    },
                    builder: (context, state) {
                      if (state.status == ChatStatus.loadingChats &&
                          state.chats.isEmpty) {
                        return const Center(
                          child: CircularProgressIndicator(),
                        );
                      }

                      final locallySortedChats = _sortChats(
                        state.chats,
                        _currentSortCriteria,
                      );

                      final filteredChats = locallySortedChats.where((chat) {
                        final query = _searchText.trim();

                        if (query.isEmpty) {
                          return true;
                        }

                        final otherParticipant =
                            chat.senderId == _currentUser?.id
                                ? chat.receiverId
                                : chat.senderId;
                        final nameMatch = (otherParticipant == _currentUser?.id
                                ? chat.receiverName
                                    ?.toLowerCase()
                                    .contains(query.toLowerCase())
                                : chat.senderName
                                    ?.toLowerCase()
                                    .contains(query.toLowerCase())) ??
                            false;
                        final messageMatch = chat.lastMessage?.content
                                .toLowerCase()
                                .contains(query) ??
                            false;
                        return nameMatch || messageMatch;
                      }).toList();

                      if (state.status == ChatStatus.failure &&
                          filteredChats.isEmpty &&
                          _searchText.isEmpty) {
                        return Center(
                          child: Text(
                            state.errorMessage ?? 'Failed to load chats.',
                            style: TextStyle(
                                color: Theme.of(context).colorScheme.error),
                          ),
                        );
                      }

                      if (filteredChats.isEmpty &&
                          state.status != ChatStatus.loadingChats) {
                        return Center(
                          child: Text(
                            _searchText.isNotEmpty // Check local query
                                ? 'No chats match your search.'
                                : 'You have no chats yet.',
                            style:
                                TextStyle(color: Theme.of(context).hintColor),
                          ),
                        );
                      }

                      if (state.chats.isEmpty &&
                          _searchText.isEmpty &&
                          state.status != ChatStatus.loadingChats) {
                        return const EmptyChatsList();
                      }

                      final typingStatusMap = state.typingUserIdByChatId;

                      return RefreshIndicator(
                        onRefresh: () async {
                          _searchController.clear();
                          _fetchInitialData();
                        },
                        child: ListView.builder(
                          itemCount: filteredChats.length,
                          itemBuilder: (context, index) {
                            final chat = filteredChats[index];

                            final typinguserId = typingStatusMap[chat.id];

                            final isOtherUserTyping = typinguserId != null &&
                                typinguserId != _currentUser!.id;

                            return ChatListItem(
                              chat: chat,
                              currentuser: _currentUser!,
                              isTyping: isOtherUserTyping,
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
        ),
      ),
    );
  }

  Widget _buildSortMenuButton(
      BuildContext context, ChatSortCriteria? currentCriteria) {
    return PopupMenuButton<ChatSortCriteria>(
      icon: const Icon(Icons.sort),
      tooltip: "Sort Chats",
      onSelected: (ChatSortCriteria result) {
        if (_currentSortCriteria != result) {
          setState(() {
            _currentSortCriteria = result;
          });
        }
      },
      itemBuilder: (BuildContext context) => <PopupMenuEntry<ChatSortCriteria>>[
        PopupMenuItem<ChatSortCriteria>(
          value: ChatSortCriteria.lastActivity,
          child: Text('Sort by Last Activity',
              style: TextStyle(
                  fontWeight: currentCriteria == ChatSortCriteria.lastActivity
                      ? FontWeight.bold
                      : FontWeight.normal)),
        ),
        PopupMenuItem<ChatSortCriteria>(
          value: ChatSortCriteria.unreadFirst,
          child: Text('Sort by Unread First',
              style: TextStyle(
                  fontWeight: currentCriteria == ChatSortCriteria.unreadFirst
                      ? FontWeight.bold
                      : FontWeight.normal)),
        ),
        PopupMenuItem<ChatSortCriteria>(
          value: ChatSortCriteria.participantName,
          child: Text('Sort by Participant Name',
              style: TextStyle(
                  fontWeight:
                      currentCriteria == ChatSortCriteria.participantName
                          ? FontWeight.bold
                          : FontWeight.normal)),
        ),
        PopupMenuItem<ChatSortCriteria>(
          value: ChatSortCriteria.propertyName,
          child: Text('Sort by Property Name',
              style: TextStyle(
                  fontWeight: currentCriteria == ChatSortCriteria.propertyName
                      ? FontWeight.bold
                      : FontWeight.normal)),
        ),
      ],
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
          color: theme.colorScheme.surfaceContainerHighest,
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
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: 'Search chats...',
                  border: InputBorder.none,
                  focusedBorder: InputBorder.none,
                  enabledBorder: InputBorder.none,
                  disabledBorder: InputBorder.none,
                  hintStyle: TextStyle(color: theme.hintColor),
                ),
              ),
            ),
            if (_searchText.isNotEmpty)
              IconButton(
                icon: const Icon(Icons.clear, size: 20),
                color: theme.hintColor,
                onPressed: () {
                  _searchController.clear();
                },
              ),
          ],
        ),
      ),
    );
  }
}
