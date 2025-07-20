import 'package:clinic/core/error/either.dart';
import 'package:clinic/core/error/failure.dart';
import 'package:clinic/core/usecase/usecase.dart';
import 'package:clinic/features/client/chat/domain/entities/chat_entity.dart';
import 'package:clinic/features/client/chat/domain/repositories/chat_repository.dart';

class CreateChatUsecase implements UseCase<ChatEntity, String> {
  final ChatRepository repository;

  const CreateChatUsecase(this.repository);

  @override
  Future<Either<Failure, ChatEntity>> call(String patientId) async {
    return await repository.createChats(patientId);
  }
}
