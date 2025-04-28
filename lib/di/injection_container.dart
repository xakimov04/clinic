import 'di_export.dart';

final sl = GetIt.instance;

Future<void> init() async {
  // MARK: - CORE REGISTRATIONS
  sl.registerLazySingleton(() => LocalStorageService());
  sl.registerLazySingleton(() => RequestHandler());
  sl.registerLazySingleton(() => NetworkManager(requestHandler: sl()));
}
