import 'package:clinic/di/export/di_export.dart';

Future<void> registerAuthModule() async {
  final sl = GetIt.instance;

  // Data Sources
  sl.registerSingleton<AuthRemoteSource>(
    AuthRemoteSourceImpl(networkManager: sl<NetworkManager>()),
  );

  // Repositories
  sl.registerSingleton<AuthRepository>(
    AuthRepositoriesImpl(remoteSource: sl<AuthRemoteSource>()),
  );

  // Use Cases
  sl.registerSingleton<LoginWithVK>(LoginWithVK(sl()));

  // BLoC
  sl.registerFactory(() => AuthBloc(
        localStorageService: sl(),
        loginWithVKUseCase: sl(),
        authRepository: sl(),
      ));
}
