import 'package:clinic/core/error/either.dart';
import 'package:clinic/core/error/failure.dart';
import 'package:clinic/core/usecase/usecase.dart';
import 'package:clinic/features/client/chat/domain/entities/message_model.dart';
import 'package:clinic/features/client/chat/domain/entities/send_message_request.dart';
import 'package:clinic/features/client/chat/domain/repositories/message_repository.dart';
import 'package:equatable/equatable.dart';

class SendMessageParams extends Equatable {
  final int chatId;
  final SendMessageRequest request;

  const SendMessageParams({
    required this.chatId,
    required this.request,
  });

  @override
  List<Object?> get props => [chatId, request];
}

class SendMessageUsecase implements UseCase<MessageEntity, SendMessageParams> {
  final MessageRepository repository;

  const SendMessageUsecase(this.repository);

  @override
  Future<Either<Failure, MessageEntity>> call(SendMessageParams params) {
    return repository.sendMessage(params.chatId, params.request);
  }
}
