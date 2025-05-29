part of 'chat_list_bloc.dart';

sealed class ChatListEvent extends Equatable {
  const ChatListEvent();

  @override
  List<Object> get props => [];
}

final class GetChatsListEvent extends ChatListEvent {
  const GetChatsListEvent();
}

final class RefreshChatsListEvent extends ChatListEvent {
  const RefreshChatsListEvent();
}

final class MarkChatAsReadEvent extends ChatListEvent {
  final int chatId;

  const MarkChatAsReadEvent(this.chatId);

  @override
  List<Object> get props => [chatId];
}
