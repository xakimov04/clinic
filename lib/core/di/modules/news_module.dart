import 'package:clinic/core/di/export/di_export.dart';
import 'package:clinic/features/client/news/data/datasources/news_remote_data_source.dart';
import 'package:clinic/features/client/news/data/repositories/news_repository_impl.dart';
import 'package:clinic/features/client/news/domain/repositories/news_repository.dart';
import 'package:clinic/features/client/news/domain/usecases/get_news_usecase.dart';
import 'package:clinic/features/client/news/presentation/bloc/news_bloc.dart';

Future<void> registerNewsModule() async {
  final sl = GetIt.instance;

  // Data Sources
  sl.registerLazySingleton<NewsRemoteDataSource>(
    () => NewsRemoteDataSourceImpl(networkManager: sl()),
  );

  // Repositories
  sl.registerLazySingleton<NewsRepository>(
    () => NewsRepositoryImpl(remoteDataSource: sl()),
  );

  // Use Cases
  sl.registerLazySingleton(() => GetNewsUseCase(sl()));

  // BLoC
  sl.registerFactory(() => NewsBloc(getNewsUseCase: sl()));
}
