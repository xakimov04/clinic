import 'package:clinic/core/di/export/di_export.dart';

Future<void> registerCoreModule() async {
  final sl = GetIt.instance;

  // Device va Platform info
  sl.registerLazySingleton(() => DeviceInfoPlugin());
  sl.registerLazySingleton(() => Connectivity());
  sl.registerLazySingleton(() => PlatformInfo(connectivity: sl()));

  // Network va Local Storage
  sl.registerLazySingleton(() => LocalStorageService());
  sl.registerLazySingleton(() => RequestHandler());
  sl.registerLazySingleton(() => NetworkManager(requestHandler: sl()));
}
