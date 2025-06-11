import 'package:clinic/core/error/either.dart';
import 'package:clinic/core/error/failure.dart';
import 'package:clinic/features/client/chat/domain/entities/message_model.dart';
import 'package:clinic/features/client/chat/domain/entities/send_message_request.dart';

abstract class MessageRepository {
  Future<Either<Failure, List<MessageEntity>>> getMessages(int chatId);

  Future<Either<Failure, MessageEntity>> sendMessage(
    int chatId,
    SendMessageRequest request,
  );

  Stream<List<MessageEntity>> getMessagesStream(int chatId);
}
