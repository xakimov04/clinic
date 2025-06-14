part of 'chat_list_bloc.dart';

sealed class ChatListState extends Equatable {
  const ChatListState();

  @override
  List<Object> get props => [];
}

final class ChatListInitial extends ChatListState {}

final class ChatListLoading extends ChatListState {}

final class ChatListRefreshing extends ChatListState {
  final List<ChatEntity> currentChats;

  const ChatListRefreshing(this.currentChats);

  @override
  List<Object> get props => [currentChats];
}

final class ChatListLoaded extends ChatListState {
  final List<ChatEntity> chats;

  const ChatListLoaded(this.chats);

  @override
  List<Object> get props => [chats];

  int get totalUnreadCount =>
      chats.fold(0, (sum, chat) => sum + chat.unreadCount);

  bool get hasUnreadMessages => totalUnreadCount > 0;
}

final class ChatListEmpty extends ChatListState {
  final String message;

  const ChatListEmpty(this.message);

  @override
  List<Object> get props => [message];
}

final class ChatListError extends ChatListState {
  final String message;

  const ChatListError(this.message);

  @override
  List<Object> get props => [message];
}

final class ChatCreating extends ChatListState {
  final List<ChatEntity> currentChats;

  const ChatCreating(this.currentChats);

  @override
  List<Object> get props => [currentChats];
}

final class ChatCreated extends ChatListState {
  final ChatEntity chat;

  const ChatCreated(this.chat);

  @override
  List<Object> get props => [chat];
}
