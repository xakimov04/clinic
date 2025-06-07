import 'package:clinic/core/error/either.dart';
import 'package:clinic/core/error/failure.dart';
import 'package:clinic/features/client/chat/domain/entities/message_model.dart';
import 'package:clinic/features/client/chat/domain/entities/send_message_request.dart';

abstract class MessageRepository {
  /// Xabarlar ro'yxatini olish
  Future<Either<Failure, List<MessageEntity>>> getMessages(int chatId);

  /// Xabar yuborish
  Future<Either<Failure, MessageEntity>> sendMessage(
    int chatId,
    SendMessageRequest request,
  );

  /// Xabarlar streamini olish (real-time)
  Stream<List<MessageEntity>> getMessagesStream(int chatId);
}
