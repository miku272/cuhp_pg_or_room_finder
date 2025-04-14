import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/common/entities/message.dart';
import '../../data/models/chat_messages_data.dart';
import '../../data/models/message_response.dart';
import '../../domain/usecase/get_messages.dart';

part 'messages_state.dart';
part 'messages_event.dart';

class MessagesBloc extends Bloc<MessagesEvent, MessagesState> {
  final GetMessages _getMessages;

  MessagesBloc({
    required GetMessages getMessages,
  })  : _getMessages = getMessages,
        super(MessagesInitial()) {
    on<MessagesEvent>(
      (event, emit) => emit(MessagesLoading(chatData: state.chatData)),
    );

    on<GetMessagesViaAPIEvent>(_onGetMessagesViaAPIEvent);
  }

  Future<void> _onGetMessagesViaAPIEvent(
    GetMessagesViaAPIEvent event,
    Emitter<MessagesState> emit,
  ) async {
    final res = await _getMessages(GetMessagesParam(
      chatId: event.chatId,
      page: event.page,
      limit: event.limit,
      token: event.token,
    ));

    res.fold(
      (failure) => emit(MessagesFailure(
        status: failure.status,
        message: failure.message,
      )),
      (MessageResponse messageResponse) {
        final currentChatData = state.chatData[event.chatId];
        final newMessages = messageResponse.messages;

        final allMessages = (currentChatData != null && event.page > 1)
            ? [...currentChatData.messages, ...newMessages]
            : newMessages;

        // 2. Filter duplicates (Recommended for robustness)
        final uniqueMessages = <Message>[];
        final uniqueIds = <String>{};
        for (final message in allMessages) {
          if (uniqueIds.add(message.id)) {
            uniqueMessages.add(message);
          }
        }

        uniqueMessages.sort((a, b) => a.createdAt.compareTo(b.createdAt));

        final updatedChatData = ChatMessagesData(
          messages: uniqueMessages,
          chat: messageResponse.chat,
          currentPage: messageResponse.currentPage,
          totalPages: messageResponse.totalPages,
          totalMessages: messageResponse.totalMessages,
        );

        final newChatDataMap = Map<String, ChatMessagesData>.from(
          state.chatData,
        );
        newChatDataMap[event.chatId] = updatedChatData;

        emit(GetMessagesViaAPISuccess(chatData: newChatDataMap));
      },
    );
  }
}
