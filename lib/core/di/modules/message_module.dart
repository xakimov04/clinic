import 'package:clinic/core/di/export/di_export.dart';
import 'package:clinic/features/client/chat/data/datasources/message_remote_data_source.dart';
import 'package:clinic/features/client/chat/data/repositories/message_repository_impl.dart';
import 'package:clinic/features/client/chat/domain/repositories/message_repository.dart';
import 'package:clinic/features/client/chat/domain/usecases/get_messages_usecase.dart';
import 'package:clinic/features/client/chat/domain/usecases/get_messages_stream_usecase.dart';
import 'package:clinic/features/client/chat/domain/usecases/send_message_usecase.dart';
import 'package:clinic/features/client/chat/presentation/bloc/chat_detail/chat_detail_bloc.dart';

Future<void> registerMessageModule() async {
  final sl = GetIt.instance;

  // Data Sources
  sl.registerLazySingleton<MessageRemoteDataSource>(
    () => MessageRemoteDataSourceImpl(sl<NetworkManager>()),
  );

  // Repositories
  sl.registerLazySingleton<MessageRepository>(
    () =>
        MessageRepositoryImpl(remoteDataSource: sl<MessageRemoteDataSource>()),
  );

  // Use Cases
  sl.registerLazySingleton(() => GetMessagesUsecase(sl<MessageRepository>()));
  sl.registerLazySingleton(() => SendMessageUsecase(sl<MessageRepository>()));
  sl.registerLazySingleton(
      () => GetMessagesStreamUsecase(sl<MessageRepository>()));

  // BLoC
  sl.registerFactory(
    () => ChatDetailBloc(
      getMessagesUsecase: sl<GetMessagesUsecase>(),
      sendMessageUsecase: sl<SendMessageUsecase>(),
      getMessagesStreamUsecase: sl<GetMessagesStreamUsecase>(),
    ),
  );
}

// lib/core/di/injection_container.dart da qo'shiladi:
// await registerMessageModule(); // Buni qo'shing
