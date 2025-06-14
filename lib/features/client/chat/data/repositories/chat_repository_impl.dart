import 'package:clinic/core/error/either.dart';
import 'package:clinic/core/error/failure.dart';
import 'package:clinic/features/client/chat/data/datasources/chat_remote_data_source.dart';
import 'package:clinic/features/client/chat/domain/entities/chat_entity.dart';
import 'package:clinic/features/client/chat/domain/repositories/chat_repository.dart';

class ChatRepositoryImpl implements ChatRepository {
  final ChatRemoteDataSource remoteDataSource;

  ChatRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, List<ChatEntity>>> getChats() async {
    final result = await remoteDataSource.getChats();
    return result.fold(
      (failure) => Left(failure),
      (chatModels) => Right(chatModels),
    );
  }

  @override
  Future<Either<Failure, void>> createChats(String patientId) async {
    final result = await remoteDataSource.createChats(patientId);
    return result.fold(
      (failure) => Left(failure),
      (chatModels) => Right(chatModels),
    );
  }
}
