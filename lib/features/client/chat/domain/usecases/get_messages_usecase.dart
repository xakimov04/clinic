import 'package:clinic/core/error/either.dart';
import 'package:clinic/core/error/failure.dart';
import 'package:clinic/core/usecase/usecase.dart';
import 'package:clinic/features/client/chat/domain/entities/message_model.dart';
import 'package:clinic/features/client/chat/domain/repositories/message_repository.dart';
import 'package:equatable/equatable.dart';

class GetMessagesParams extends Equatable {
  final int chatId;

  const GetMessagesParams({required this.chatId});

  @override
  List<Object?> get props => [chatId];
}

class GetMessagesUsecase
    implements UseCase<List<MessageEntity>, GetMessagesParams> {
  final MessageRepository repository;

  const GetMessagesUsecase(this.repository);

  @override
  Future<Either<Failure, List<MessageEntity>>> call(GetMessagesParams params) {
    return repository.getMessages(params.chatId);
  }
}
