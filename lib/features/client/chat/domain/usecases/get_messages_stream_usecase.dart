import 'package:clinic/features/client/chat/domain/entities/message_model.dart';
import 'package:clinic/features/client/chat/domain/repositories/message_repository.dart';

class GetMessagesStreamUsecase {
  final MessageRepository repository;

  const GetMessagesStreamUsecase(this.repository);

  Stream<List<MessageEntity>> call(int chatId) {
    return repository.getMessagesStream(chatId);
  }
}
