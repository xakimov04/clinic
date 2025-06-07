import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:clinic/features/client/chat/domain/entities/message_model.dart';
import 'package:clinic/features/client/chat/domain/entities/send_message_request.dart';
import 'package:clinic/features/client/chat/domain/repositories/message_repository.dart';
import 'package:clinic/features/client/chat/domain/usecases/get_messages_stream_usecase.dart';
import 'package:clinic/features/client/chat/domain/usecases/get_messages_usecase.dart';
import 'package:clinic/features/client/chat/domain/usecases/send_message_usecase.dart';
import 'package:equatable/equatable.dart';

part 'chat_detail_event.dart';
part 'chat_detail_state.dart';

class ChatDetailBloc extends Bloc<ChatDetailEvent, ChatDetailState> {
  final GetMessagesUsecase getMessagesUsecase;
  final SendMessageUsecase sendMessageUsecase;
  final GetMessagesStreamUsecase getMessagesStreamUsecase;
  final MessageRepository messageRepository;

  StreamSubscription<List<MessageEntity>>? _messagesSubscription;
  int? _currentChatId;

  ChatDetailBloc({
    required this.getMessagesUsecase,
    required this.sendMessageUsecase,
    required this.getMessagesStreamUsecase,
    required this.messageRepository,
  }) : super(ChatDetailInitial()) {
    on<LoadMessagesEvent>(_onLoadMessages);
    on<SendMessageEvent>(_onSendMessage);
    on<MessagesUpdatedEvent>(_onMessagesUpdated);
  }

  Future<void> _onLoadMessages(
    LoadMessagesEvent event,
    Emitter<ChatDetailState> emit,
  ) async {
    emit(ChatDetailLoading());
    _currentChatId = event.chatId;

    // Avvalgi subscription'ni bekor qilish
    await _messagesSubscription?.cancel();

    try {
      // Stream'ni boshlash
      _messagesSubscription = getMessagesStreamUsecase(event.chatId).listen(
        (messages) {
          add(MessagesUpdatedEvent(messages));
        },
        onError: (error) {
          add(MessagesUpdatedEvent([]));
        },
      );

      // Dastlabki ma'lumotlarni yuklash
      final result =
          await getMessagesUsecase(GetMessagesParams(chatId: event.chatId));

      result.fold(
        (failure) => emit(ChatDetailError(failure.message)),
        (messages) {
          emit(ChatDetailLoaded(messages: messages));
        },
      );
    } catch (e) {
      emit(ChatDetailError('Ошибка загрузки сообщений: ${e.toString()}'));
    }
  }

  Future<void> _onSendMessage(
    SendMessageEvent event,
    Emitter<ChatDetailState> emit,
  ) async {
    if (state is! ChatDetailLoaded) return;

    final currentState = state as ChatDetailLoaded;

    // Yuborish holatini ko'rsatish
    emit(currentState.copyWith(isSendingMessage: true));

    // Optimistic update - darhol UI'ga qo'shish
    final tempMessage = MessageEntity(
      id: -DateTime.now().millisecondsSinceEpoch, // Vaqtinchalik ID
      content: event.content,
      timestamp: DateTime.now(),
      isRead: true,
      senderId: 0, // Current user ID
      senderName: 'Siz',
      senderType: MessageSenderType.patient,
    );

    final optimisticMessages = [...currentState.messages, tempMessage];
    emit(ChatDetailLoaded(
      messages: optimisticMessages,
      isSendingMessage: true,
    ));

    // Backend'ga yuborish
    final result = await sendMessageUsecase(SendMessageParams(
      chatId: event.chatId,
      request: SendMessageRequest(content: event.content),
    ));

    result.fold(
      (failure) {
        // Xatolik bo'lsa, optimistic update'ni bekor qilish
        emit(ChatDetailLoaded(
          messages: currentState.messages,
          isSendingMessage: false,
        ));
        emit(MessageSendError(failure.message));
      },
      (message) {
        // Muvaffaqiyat - stream orqali yangi xabar keladi
        emit(currentState.copyWith(isSendingMessage: false));
      },
    );
  }

  void _onMessagesUpdated(
    MessagesUpdatedEvent event,
    Emitter<ChatDetailState> emit,
  ) {
    if (state is ChatDetailLoaded) {
      final currentState = state as ChatDetailLoaded;
      emit(ChatDetailLoaded(
        messages: event.messages,
        isSendingMessage: currentState.isSendingMessage,
      ));
    } else if (state is ChatDetailLoading) {
      emit(ChatDetailLoaded(messages: event.messages));
    }
  }

  @override
  Future<void> close() async {
    await _messagesSubscription?.cancel();
    return super.close();
  }

  // Chat yopilganda stream'ni tozalash
  void disposeChat() {
    _messagesSubscription?.cancel();
    if (_currentChatId != null) {
      // MessageRemoteDataSource'da stream'ni yopish
      // Bu method'ni MessageRemoteDataSource'da implement qilish kerak
    }
  }
}
