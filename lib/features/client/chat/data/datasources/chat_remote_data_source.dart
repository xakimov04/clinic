import 'package:clinic/core/error/either.dart';
import 'package:clinic/core/error/failure.dart';
import 'package:clinic/core/network/network_manager.dart';
import 'package:clinic/features/client/chat/data/models/chat_model.dart';

abstract class ChatRemoteDataSource {
  Future<Either<Failure, List<ChatModel>>> getChats();
  Future<Either<Failure, ChatModel>> getChatById(int chatId);
}

class ChatRemoteDataSourceImpl implements ChatRemoteDataSource {
  final NetworkManager networkManager;

  ChatRemoteDataSourceImpl(this.networkManager);

  @override
  Future<Either<Failure, List<ChatModel>>> getChats() async {
    try {
      final response = await networkManager.fetchData(
        url: 'chats/',
      );

      final List<ChatModel> chats =
          (response as List).map((json) => ChatModel.fromJson(json)).toList();

      chats.sort((a, b) => b.lastMessageAt.compareTo(a.lastMessageAt));

      return Right(chats);
    } catch (e) {
      return Left(
          ServerFailure(message: 'Чаты загрузить не удалось: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, ChatModel>> getChatById(int chatId) async {
    try {
      final response = await networkManager.fetchData(
        url: 'chats/$chatId/',
        useAuthorization: false,
      );

      final chat = ChatModel.fromJson(response);
      return Right(chat);
    } catch (e) {
      return Left(
          ServerFailure(message: 'Чат загрузить не удалось: ${e.toString()}'));
    }
  }
}
