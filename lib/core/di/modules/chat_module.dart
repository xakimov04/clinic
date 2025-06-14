import 'package:clinic/core/di/export/di_export.dart';
import 'package:clinic/features/client/chat/data/datasources/chat_remote_data_source.dart';
import 'package:clinic/features/client/chat/data/repositories/chat_repository_impl.dart';
import 'package:clinic/features/client/chat/domain/repositories/chat_repository.dart';
import 'package:clinic/features/client/chat/domain/usecases/create_chat_usecase.dart';
import 'package:clinic/features/client/chat/domain/usecases/get_chats_usecase.dart';
import 'package:clinic/features/client/chat/presentation/bloc/chat_list/chat_list_bloc.dart';

Future<void> registerChatModule() async {
  final sl = GetIt.instance;

  // Data Sources
  sl.registerLazySingleton<ChatRemoteDataSource>(
    () => ChatRemoteDataSourceImpl(sl<NetworkManager>()),
  );

  // Repositories
  sl.registerLazySingleton<ChatRepository>(
    () => ChatRepositoryImpl(remoteDataSource: sl<ChatRemoteDataSource>()),
  );

  // Use Cases
  sl.registerLazySingleton(() => GetChatsUsecase(sl<ChatRepository>()));
  sl.registerLazySingleton(() => CreateChatUsecase(sl<ChatRepository>()));

  // BLoC
  sl.registerFactory(
    () => ChatListBloc(
      getChatsUsecase: sl<GetChatsUsecase>(),
      createChatUsecase: sl<CreateChatUsecase>(),
    ),
  );
}
