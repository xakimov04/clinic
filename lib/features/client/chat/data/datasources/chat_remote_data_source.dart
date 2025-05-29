// lib/features/client/chat/data/datasources/chat_remote_data_source.dart
import 'package:clinic/core/error/either.dart';
import 'package:clinic/core/error/failure.dart';
import 'package:clinic/core/network/network_manager.dart';
import 'package:clinic/features/client/chat/data/models/chat_model.dart';

abstract class ChatRemoteDataSource {
  Future<Either<Failure, List<ChatModel>>> getChats();
  Future<Either<Failure, ChatModel>> getChatById(int chatId);
  Future<Either<Failure, void>> markChatAsRead(int chatId);
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

      // Oxirgi xabarga qarab tartiblash (eng yangi birinchi)
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

  @override
  Future<Either<Failure, void>> markChatAsRead(int chatId) async {
    try {
      await networkManager.postData(
        url: 'chats/$chatId/mark-read/',
        useAuthorization: false,
        data: {},
      );

      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(
          message: 'Чат как прочитанный отметить не удалось: ${e.toString()}'));
    }
  }
}
