part of 'messages_bloc.dart';

@immutable
sealed class MessagesState {
  final Map<String, ChatMessagesData> chatData;

  const MessagesState({this.chatData = const {}});
}

final class MessagesInitial extends MessagesState {}

final class MessagesLoading extends MessagesState {
  const MessagesLoading({super.chatData});
}

final class GetMessagesViaAPISuccess extends MessagesState {
  const GetMessagesViaAPISuccess({required super.chatData});
}

final class MessagesFailure extends MessagesState {
  final int? status;
  final String message;

  const MessagesFailure({
    this.status,
    required this.message,
    super.chatData,
  });
}
