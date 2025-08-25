import 'dart:async';
import 'dart:io';

import 'package:bloc/bloc.dart';
import 'package:clinic/features/client/chat/domain/entities/message_model.dart';
import 'package:clinic/features/client/chat/domain/entities/send_message_request.dart';
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

  StreamSubscription<List<MessageEntity>>? _messagesSubscription;
  int? _currentChatId;

  ChatDetailBloc({
    required this.getMessagesUsecase,
    required this.sendMessageUsecase,
    required this.getMessagesStreamUsecase,
  }) : super(ChatDetailInitial()) {
    on<LoadMessagesEvent>(_onLoadMessages);
    on<SendMessageEvent>(_onSendMessage);
    on<MessagesUpdatedEvent>(_onMessagesUpdated);
  }

  Future<void> _onLoadMessages(
    LoadMessagesEvent event,
    Emitter<ChatDetailState> emit,
  ) async {
    if (_currentChatId == event.chatId && state is ChatDetailLoaded) {
      return; // Allaqachon yuklangan
    }

    emit(ChatDetailLoading());

    _currentChatId = event.chatId;

    // Stream'ni boshqarish
    await _messagesSubscription?.cancel();
    _messagesSubscription = getMessagesStreamUsecase(event.chatId).listen(
      (messages) => add(MessagesUpdatedEvent(messages)),
    );
  }

  Future<void> _onSendMessage(
    SendMessageEvent event,
    Emitter<ChatDetailState> emit,
  ) async {
    if (state is! ChatDetailLoaded) return;

    final currentState = state as ChatDetailLoaded;

    // Validatsiya
    if (event.content.trim().isEmpty && event.file == null) {
      emit(MessageSendError('Xabar matni yoki fayl bo\'lishi kerak'));
      return;
    }

    // File size validation (10MB)
    if (event.file != null) {
      final fileSize = await event.file!.length();
      const maxSize = 10 * 1024 * 1024; // 10MB

      if (fileSize > maxSize) {
        emit(MessageSendError('Fayl hajmi 10MB dan oshmasligi kerak'));
        return;
      }
    }

    // Yuborish holatini ko'rsatish
    emit(currentState.copyWith(isSendingMessage: true));

    // Optimistic update
    final tempMessage = MessageEntity(
      id: -DateTime.now().millisecondsSinceEpoch,
      content: event.content,
      timestamp: DateTime.now(),
      isRead: true,
      senderId: 0, // Current user ID
      senderName: 'Siz',
      senderType: MessageSenderType.patient,
      file: event.file?.path, // Local path for preview
      isTemporary: true,
      isSending: true,
    );

    final optimisticMessages = [...currentState.messages, tempMessage];
    emit(ChatDetailLoaded(
      messages: optimisticMessages,
      isSendingMessage: true,
    ));

    // Backend'ga yuborish
    final result = await sendMessageUsecase(SendMessageParams(
      chatId: event.chatId,
      request: SendMessageRequest(
        content: event.content,
        file: event.file,
      ),
    ));

    result.fold(
      (failure) {
        // Optimistic update'ni bekor qilish
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
    _messagesSubscription = null;
    if (_currentChatId != null) {
      getMessagesStreamUsecase.disposeStream(_currentChatId!);
      _currentChatId = null;
    }
    return super.close();
  }
}
