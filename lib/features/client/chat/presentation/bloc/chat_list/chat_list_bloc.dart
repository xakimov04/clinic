import 'package:bloc/bloc.dart';
import 'package:clinic/core/usecase/usecase.dart';
import 'package:clinic/features/client/chat/domain/entities/chat_entity.dart';
import 'package:clinic/features/client/chat/domain/usecases/create_chat_usecase.dart';
import 'package:clinic/features/client/chat/domain/usecases/get_chats_usecase.dart';
import 'package:equatable/equatable.dart';

part 'chat_list_event.dart';
part 'chat_list_state.dart';

class ChatListBloc extends Bloc<ChatListEvent, ChatListState> {
  final GetChatsUsecase getChatsUsecase;
  final CreateChatUsecase createChatUsecase;
  ChatListBloc({
    required this.getChatsUsecase,
    required this.createChatUsecase,
  }) : super(ChatListInitial()) {
    on<GetChatsListEvent>(_onGetChatsList);
    on<RefreshChatsListEvent>(_onRefreshChatsList);
    on<MarkChatAsReadEvent>(_onMarkChatAsRead);
    on<CreateChatEvent>(_onCreateChat);
  }

  Future<void> _onGetChatsList(
    GetChatsListEvent event,
    Emitter<ChatListState> emit,
  ) async {
    emit(ChatListLoading());

    final result = await getChatsUsecase(NoParams());

    result.fold(
      (failure) => emit(ChatListError(failure.message)),
      (chats) {
        if (chats.isEmpty) {
          emit(const ChatListEmpty('У вас нет активных чатов'));
        } else {
          emit(ChatListLoaded(chats));
        }
      },
    );
  }

  Future<void> _onRefreshChatsList(
    RefreshChatsListEvent event,
    Emitter<ChatListState> emit,
  ) async {
    if (state is ChatListLoaded) {
      emit(ChatListRefreshing((state as ChatListLoaded).chats));
    }

    final result = await getChatsUsecase(NoParams());

    result.fold(
      (failure) => emit(ChatListError(failure.message)),
      (chats) {
        if (chats.isEmpty) {
          emit(const ChatListEmpty('У вас нет активных чатов'));
        } else {
          emit(ChatListLoaded(chats));
        }
      },
    );
  }

  Future<void> _onMarkChatAsRead(
    MarkChatAsReadEvent event,
    Emitter<ChatListState> emit,
  ) async {
    if (state is! ChatListLoaded) return;

    final currentState = state as ChatListLoaded;

    // Optimistic update - darhol UI'da o'zgarishni ko'rsatamiz
    final updatedChats = currentState.chats.map((chat) {
      if (chat.id == event.chatId) {
        return ChatEntity(
          id: chat.id,
          patientId: chat.patientId,
          doctorId: chat.doctorId,
          patientName: chat.patientName,
          doctorName: chat.doctorName,
          createdAt: chat.createdAt,
          isActive: chat.isActive,
          lastMessageAt: chat.lastMessageAt,
          lastMessage: chat.lastMessage,
          unreadCount: 0, // O'qilgan deb belgilaymiz
        );
      }
      return chat;
    }).toList();

    emit(ChatListLoaded(updatedChats));
  }

  Future<void> _onCreateChat(
    CreateChatEvent event,
    Emitter<ChatListState> emit,
  ) async {
    if (state is ChatListLoaded) {
      emit(ChatCreating((state as ChatListLoaded).chats));
    }

    final result = await createChatUsecase(event.patientId.toString());

    result.fold(
      (failure) => emit(ChatListError(failure.message)),
      (_) async {
        // After creating chat, refresh the chat list
        final chatsResult = await getChatsUsecase(NoParams());
        if (!emit.isDone) {
          chatsResult.fold(
            (failure) => emit(ChatListError(failure.message)),
            (chats) => emit(ChatListLoaded(chats)),
          );
        }
      },
    );
  }
}
