part of 'chat_detail_bloc.dart';

sealed class ChatDetailEvent extends Equatable {
  const ChatDetailEvent();

  @override
  List<Object> get props => [];
}

final class LoadMessagesEvent extends ChatDetailEvent {
  final int chatId;

  const LoadMessagesEvent(this.chatId);

  @override
  List<Object> get props => [chatId];
}

final class SendMessageEvent extends ChatDetailEvent {
  final int chatId;
  final String content;

  const SendMessageEvent({
    required this.chatId,
    required this.content,
  });

  @override
  List<Object> get props => [chatId, content];
}

final class MarkAllAsReadEvent extends ChatDetailEvent {
  final int chatId;

  const MarkAllAsReadEvent(this.chatId);

  @override
  List<Object> get props => [chatId];
}

final class MessagesUpdatedEvent extends ChatDetailEvent {
  final List<MessageEntity> messages;

  const MessagesUpdatedEvent(this.messages);

  @override
  List<Object> get props => [messages];
}
