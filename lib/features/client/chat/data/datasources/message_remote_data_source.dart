import 'dart:async';
import 'package:clinic/core/error/either.dart';
import 'package:clinic/core/error/failure.dart';
import 'package:clinic/core/network/network_manager.dart';
import 'package:clinic/features/client/chat/data/models/message_model.dart';
import 'package:clinic/features/client/chat/data/models/send_message_request_model.dart';

abstract class MessageRemoteDataSource {
  Future<Either<Failure, List<MessageModel>>> getMessages(int chatId);
  Future<Either<Failure, MessageModel>> sendMessage(
    int chatId,
    SendMessageRequestModel request,
  );
  Stream<List<MessageModel>> getMessagesStream(int chatId);
  Future<Either<Failure, void>> markMessageAsRead(int chatId, int messageId);
  Future<Either<Failure, void>> markAllMessagesAsRead(int chatId);
}

class MessageRemoteDataSourceImpl implements MessageRemoteDataSource {
  final NetworkManager networkManager;

  // Stream controller'lar har bir chat uchun
  final Map<int, StreamController<List<MessageModel>>> _messageStreams = {};
  final Map<int, Timer?> _pollingTimers = {};

  MessageRemoteDataSourceImpl(this.networkManager);

  @override
  Future<Either<Failure, List<MessageModel>>> getMessages(int chatId) async {
    try {
      final response = await networkManager.fetchData(
        url: 'chats/$chatId/messages/',
        useAuthorization: false,
      );

      final List<MessageModel> messages = (response as List)
          .map((json) => MessageModel.fromJson(json))
          .toList();

      // Vaqt bo'yicha tartiblash (eski xabarlar yuqorida)
      messages.sort((a, b) => a.timestamp.compareTo(b.timestamp));

      return Right(messages);
    } catch (e) {
      return Left(ServerFailure(
        message: 'Сообщения загрузить не удалось: ${e.toString()}',
      ));
    }
  }

  @override
  Future<Either<Failure, MessageModel>> sendMessage(
    int chatId,
    SendMessageRequestModel request,
  ) async {
    try {
      final response = await networkManager.postData(
        url: 'chats/$chatId/send/',
        useAuthorization: false,
        data: request.toJson(),
      );

      final message = MessageModel.fromJson(response);

      // Stream'ga yangi xabarni qo'shish
      _updateMessageStream(chatId);

      return Right(message);
    } catch (e) {
      return Left(ServerFailure(
        message: 'Сообщение отправить не удалось: ${e.toString()}',
      ));
    }
  }

  @override
  Stream<List<MessageModel>> getMessagesStream(int chatId) {
    // Agar stream mavjud bo'lmasa, yangi yaratamiz
    if (!_messageStreams.containsKey(chatId)) {
      _messageStreams[chatId] =
          StreamController<List<MessageModel>>.broadcast();

      // Dastlabki ma'lumotlarni yuklash
      _loadInitialMessages(chatId);

      // Polling boshlash (har 3 soniyada yangi xabarlarni tekshirish)
      _startPolling(chatId);
    }

    return _messageStreams[chatId]!.stream;
  }

  void _loadInitialMessages(int chatId) async {
    final result = await getMessages(chatId);
    result.fold(
      (failure) {
        _messageStreams[chatId]?.addError(failure);
      },
      (messages) {
        _messageStreams[chatId]?.add(messages);
      },
    );
  }

  void _startPolling(int chatId) {
    _pollingTimers[chatId] = Timer.periodic(
      const Duration(seconds: 3),
      (_) => _updateMessageStream(chatId),
    );
  }

  void _updateMessageStream(int chatId) async {
    if (!_messageStreams.containsKey(chatId)) return;

    final result = await getMessages(chatId);
    result.fold(
      (failure) {
        // Xatolikni log qilish, lekin stream'ni to'xtatmaslik
      },
      (messages) {
        if (!_messageStreams[chatId]!.isClosed) {
          _messageStreams[chatId]!.add(messages);
        }
      },
    );
  }

  @override
  Future<Either<Failure, void>> markMessageAsRead(
      int chatId, int messageId) async {
    try {
      await networkManager.postData(
        url: 'chats/$chatId/messages/$messageId/mark-read/',
        useAuthorization: false,
        data: {},
      );

      // Stream'ni yangilash
      _updateMessageStream(chatId);

      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(
        message:
            'Сообщение как прочитанное отметить не удалось: ${e.toString()}',
      ));
    }
  }

  @override
  Future<Either<Failure, void>> markAllMessagesAsRead(int chatId) async {
    try {
      await networkManager.postData(
        url: 'chats/$chatId/mark-all-read/',
        useAuthorization: false,
        data: {},
      );

      // Stream'ni yangilash
      _updateMessageStream(chatId);

      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(
        message:
            'Все сообщения как прочитанные отметить не удалось: ${e.toString()}',
      ));
    }
  }

  // Stream'larni tozalash
  void dispose() {
    for (final timer in _pollingTimers.values) {
      timer?.cancel();
    }
    _pollingTimers.clear();

    for (final controller in _messageStreams.values) {
      controller.close();
    }
    _messageStreams.clear();
  }


  void closeStream(int chatId) {
    _pollingTimers[chatId]?.cancel();
    _pollingTimers.remove(chatId);

    _messageStreams[chatId]?.close();
    _messageStreams.remove(chatId);
  }
}
