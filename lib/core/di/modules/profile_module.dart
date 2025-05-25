
import 'package:clinic/core/di/export/di_export.dart';

Future<void> registerProfileModule() async {
  final sl = GetIt.instance;
  
  // Data Sources
  sl.registerLazySingleton<ProfileRemoteDataSource>(
    () => ProfileRemoteDataSourceImpl(networkManager: sl()),
  );
  
  sl.registerLazySingleton<ProfileLocalDataSource>(
    () => ProfileLocalDataSourceImpl(localStorageService: sl()),
  );
  
  // Repositories
  sl.registerLazySingleton<ProfileRepository>(
    () => ProfileRepositoryImpl(
      remoteDataSource: sl(),
      localDataSource: sl(),
      platformInfo: sl(),
    ),
  );
  
  // Use Cases
  sl.registerLazySingleton(() => GetUserProfile(sl()));
  sl.registerLazySingleton(() => Logout(sl()));
  
  // BLoC
  sl.registerFactory(
    () => ProfileBloc(
      getUserProfile: sl(),
      logout: sl(),
    ),
  );
}