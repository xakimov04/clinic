import 'package:clinic/core/error/either.dart';
import 'package:clinic/core/error/failure.dart';
import 'package:clinic/features/client/chat/data/datasources/message_remote_data_source.dart';
import 'package:clinic/features/client/chat/data/models/send_message_request_model.dart';
import 'package:clinic/features/client/chat/domain/entities/message_model.dart';
import 'package:clinic/features/client/chat/domain/entities/send_message_request.dart';
import 'package:clinic/features/client/chat/domain/repositories/message_repository.dart';

class MessageRepositoryImpl implements MessageRepository {
  final MessageRemoteDataSource remoteDataSource;

  MessageRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, List<MessageEntity>>> getMessages(int chatId) async {
    final result = await remoteDataSource.getMessages(chatId);
    return result.fold(
      (failure) => Left(failure),
      (messageModels) => Right(messageModels),
    );
  }

  @override
  Future<Either<Failure, MessageEntity>> sendMessage(
    int chatId,
    SendMessageRequest request,
  ) async {
    final requestModel = SendMessageRequestModel.fromEntity(request);
    final result = await remoteDataSource.sendMessage(chatId, requestModel);

    return result.fold(
      (failure) => Left(failure),
      (messageModel) => Right(messageModel),
    );
  }

  @override
  Stream<List<MessageEntity>> getMessagesStream(int chatId) {
    return remoteDataSource.getMessagesStream(chatId);
  }

  @override
  Future<Either<Failure, void>> markMessageAsRead(int chatId, int messageId) {
    return remoteDataSource.markMessageAsRead(chatId, messageId);
  }

  @override
  Future<Either<Failure, void>> markAllMessagesAsRead(int chatId) {
    return remoteDataSource.markAllMessagesAsRead(chatId);
  }
}
