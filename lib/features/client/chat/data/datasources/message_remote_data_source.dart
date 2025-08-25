import 'dart:async';
import 'package:clinic/core/constants/app_contants.dart';
import 'package:clinic/core/di/modules/receptions_module.dart';
import 'package:clinic/core/error/either.dart';
import 'package:clinic/core/error/failure.dart';
import 'package:clinic/core/local/local_storage_service.dart';
import 'package:clinic/core/local/storage_keys.dart';
import 'package:clinic/core/network/network_manager.dart';
import 'package:clinic/features/client/chat/data/models/message_model.dart';
import 'package:clinic/features/client/chat/data/models/send_message_request_model.dart';
import 'package:dio/dio.dart';

abstract class MessageRemoteDataSource {
  Future<Either<Failure, List<MessageModel>>> getMessages(int chatId);
  Future<Either<Failure, MessageModel>> sendMessage(
    int chatId,
    SendMessageRequestModel request,
  );
  Stream<List<MessageModel>> getMessagesStream(int chatId);
  void disposeStream(int chatId);
}

class MessageRemoteDataSourceImpl implements MessageRemoteDataSource {
  final NetworkManager networkManager;

  final Map<int, StreamController<List<MessageModel>>> _messageStreams = {};
  final Map<int, Timer?> _pollingTimers = {};

  MessageRemoteDataSourceImpl(this.networkManager);

  @override
  Future<Either<Failure, List<MessageModel>>> getMessages(int chatId) async {
    try {
      final response = await networkManager.fetchData(
        url: 'chats/$chatId/messages/',
      );

      final List<MessageModel> messages = (response as List)
          .map((json) => MessageModel.fromJson(json))
          .toList();

      messages.sort((a, b) => a.timestamp.compareTo(b.timestamp));
      return Right(messages);
    } catch (e) {
      return Left(ServerFailure(
        message: 'Xabarlarni yuklashda xatolik yuz berdi',
      ));
    }
  }

  @override
  Future<Either<Failure, MessageModel>> sendMessage(
    int chatId,
    SendMessageRequestModel request,
  ) async {
    try {
      final accesToken =
          await LocalStorageService().getString(StorageKeys.accesToken);
      if (request.hasFile) {
        final formData = await request.toFormData();
        final response = await sl<Dio>().post(
          '${AppConstants.apiBaseUrl}/chats/$chatId/send/',
          data: formData,
          options: Options(
            headers: {
              'Content-Type': 'multipart/form-data',
              'Authorization': 'Bearer $accesToken'
            },
          ),
        );
        final message = MessageModel.fromJson(response.data);

        _updateMessageStream(chatId);

        return Right(message);
      } else {
        final response = await networkManager.postData(
          url: 'chats/$chatId/send/',
          data: request.toJson(),
        );
        final message = MessageModel.fromJson(response);

        _updateMessageStream(chatId);

        return Right(message);
      }
    } on DioException catch (e) {
      print(e.response!.data);
      return Left(ServerFailure());
    } catch (e) {
      return Left(ServerFailure());
    }
  }

  @override
  Stream<List<MessageModel>> getMessagesStream(int chatId) {
    if (_messageStreams[chatId] == null) {
      _messageStreams[chatId] =
          StreamController<List<MessageModel>>.broadcast();
      _startPolling(chatId);
    }
    return _messageStreams[chatId]!.stream;
  }

  void _startPolling(int chatId) {
    _pollingTimers[chatId] = Timer.periodic(
      const Duration(seconds: 3),
      (_) => _updateMessageStream(chatId),
    );

    // Dastlabki ma'lumotlarni yuklash
    _updateMessageStream(chatId);
  }

  Future<void> _updateMessageStream(int chatId) async {
    final result = await getMessages(chatId);
    result.fold(
      (failure) {
        // Xatolikni handle qilish
      },
      (messages) {
        if (_messageStreams[chatId] != null &&
            !_messageStreams[chatId]!.isClosed) {
          _messageStreams[chatId]!.add(messages);
        }
      },
    );
  }

  @override
  void disposeStream(int chatId) {
    _pollingTimers[chatId]?.cancel();
    _pollingTimers.remove(chatId);

    _messageStreams[chatId]?.close();
    _messageStreams.remove(chatId);
  }

  void dispose() {
    for (final timer in _pollingTimers.values) {
      timer?.cancel();
    }
    _pollingTimers.clear();

    for (final stream in _messageStreams.values) {
      stream.close();
    }
    _messageStreams.clear();
  }
}
