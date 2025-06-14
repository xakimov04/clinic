import 'package:clinic/core/error/either.dart';
import 'package:clinic/core/error/failure.dart';
import 'package:clinic/core/usecase/usecase.dart';
import 'package:clinic/features/client/chat/domain/repositories/chat_repository.dart';

class CreateChatUsecase implements UseCase<void, String> {
  final ChatRepository repository;

  const CreateChatUsecase(this.repository);

  @override
  Future<Either<Failure, void>> call(String patientId) async {
    return await repository.createChats(patientId);
  }
}
