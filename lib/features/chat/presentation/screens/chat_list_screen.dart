import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/common/cubits/app_socket/app_socket_cubit.dart';
import '../../../../core/common/cubits/app_user/app_user_cubit.dart';
import '../../../../core/common/entities/user.dart';
import '../../../../core/utils/jwt_expiration_handler.dart';

import '../../../../init_dependencies.dart';

import '../bloc/chat_bloc.dart';

import '../widgets/chat_list_item.dart';
import '../widgets/empty_chat_list.dart';

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
  }

  User? _getCurrentUser() {
    final user = context.read<AppUserCubit>().user;

    return user;
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
                      return const EmptyChatsList();
                    }

                    final typingStatusMap = state.typingUserIdByChatId;

                    return RefreshIndicator(
                      onRefresh: () async {
                        _fetchInitialData();
                      },
                      child: ListView.builder(
                        itemCount: state.chats.length,
                        itemBuilder: (context, index) {
                          final chat = state.chats[index];

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
              ? Colors.grey.shade200
              : theme.colorScheme.surfaceContainerHighest,
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
