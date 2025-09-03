part of 'chat_list_bloc.dart';

sealed class ChatListEvent extends Equatable {
  const ChatListEvent();

  @override
  List<Object> get props => [];
}

final class GetChatsListEvent extends ChatListEvent {
  const GetChatsListEvent();
}

final class GetChatsListEventNotLoading extends ChatListEvent {}

final class RefreshChatsListEvent extends ChatListEvent {
  const RefreshChatsListEvent();
}

final class CreateChatEvent extends ChatListEvent {
  final String patientId;

  const CreateChatEvent(this.patientId);

  @override
  List<Object> get props => [patientId];
}

final class MarkChatAsReadEvent extends ChatListEvent {
  final int chatId;

  const MarkChatAsReadEvent(this.chatId);

  @override
  List<Object> get props => [chatId];
}
