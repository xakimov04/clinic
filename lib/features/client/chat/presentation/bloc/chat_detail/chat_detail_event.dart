part of 'chat_detail_bloc.dart';

abstract class ChatDetailEvent extends Equatable {
  const ChatDetailEvent();

  @override
  List<Object?> get props => [];
}

class LoadMessagesEvent extends ChatDetailEvent {
  final int chatId;

  const LoadMessagesEvent(this.chatId);

  @override
  List<Object> get props => [chatId];
}

class SendMessageEvent extends ChatDetailEvent {
  final int chatId;
  final String content;
  final File? file; // Yangi parameter

  const SendMessageEvent({
    required this.chatId,
    required this.content,
    this.file,
  });

  @override
  List<Object?> get props => [chatId, content, file];
}

class MessagesUpdatedEvent extends ChatDetailEvent {
  final List<MessageEntity> messages;

  const MessagesUpdatedEvent(this.messages);

  @override
  List<Object> get props => [messages];
}
