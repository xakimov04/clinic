import 'package:clinic/core/platform/platform_info.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

import 'di_export.dart';

final sl = GetIt.instance;

Future<void> init() async {
  // MARK: - CORE REGISTRATIONS
  sl.registerLazySingleton(() => LocalStorageService());
  sl.registerLazySingleton(() => RequestHandler());
  sl.registerLazySingleton(() => NetworkManager(requestHandler: sl()));

  // Core
  sl.registerLazySingleton(() => PlatformInfo(connectivity: sl()));
  sl.registerLazySingleton(() => Connectivity());
}
