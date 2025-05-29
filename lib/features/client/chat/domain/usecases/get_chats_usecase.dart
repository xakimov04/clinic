import 'package:clinic/core/error/either.dart';
import 'package:clinic/core/error/failure.dart';
import 'package:clinic/core/usecase/usecase.dart';
import 'package:clinic/features/client/chat/domain/entities/chat_entity.dart';
import 'package:clinic/features/client/chat/domain/repositories/chat_repository.dart';

class GetChatsUsecase implements UseCase<List<ChatEntity>, NoParams> {
  final ChatRepository repository;

  const GetChatsUsecase(this.repository);

  @override
  Future<Either<Failure, List<ChatEntity>>> call(NoParams params) {
    return repository.getChats();
  }
}