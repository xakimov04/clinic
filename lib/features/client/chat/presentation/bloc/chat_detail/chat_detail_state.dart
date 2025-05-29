part of 'chat_detail_bloc.dart';

sealed class ChatDetailState extends Equatable {
  const ChatDetailState();

  @override
  List<Object> get props => [];
}

final class ChatDetailInitial extends ChatDetailState {}

final class ChatDetailLoading extends ChatDetailState {}

final class ChatDetailLoaded extends ChatDetailState {
  final List<MessageEntity> messages;
  final bool isSendingMessage;

  const ChatDetailLoaded({
    required this.messages,
    this.isSendingMessage = false,
  });

  @override
  List<Object> get props => [messages, isSendingMessage];

  ChatDetailLoaded copyWith({
    List<MessageEntity>? messages,
    bool? isSendingMessage,
  }) {
    return ChatDetailLoaded(
      messages: messages ?? this.messages,
      isSendingMessage: isSendingMessage ?? this.isSendingMessage,
    );
  }

  bool get hasMessages => messages.isNotEmpty;
  int get unreadCount =>
      messages.where((m) => !m.isRead && !m.isFromCurrentUser).length;
}

final class ChatDetailError extends ChatDetailState {
  final String message;

  const ChatDetailError(this.message);

  @override
  List<Object> get props => [message];
}

final class MessageSentSuccess extends ChatDetailState {
  final MessageEntity message;

  const MessageSentSuccess(this.message);

  @override
  List<Object> get props => [message];
}

final class MessageSendError extends ChatDetailState {
  final String error;

  const MessageSendError(this.error);

  @override
  List<Object> get props => [error];
}
