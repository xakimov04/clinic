import 'package:clinic/features/client/receptions/data/datasources/reception_remote_data_source.dart';
import 'package:clinic/features/client/receptions/domain/usecases/get_reception_info.dart';
import 'package:clinic/features/client/receptions/domain/usecases/get_reception_list.dart';
import 'package:get_it/get_it.dart';
import 'package:clinic/features/client/receptions/domain/repositories/reception_repository.dart';
import 'package:clinic/features/client/receptions/data/repositories/reception_repository_impl.dart';
import 'package:clinic/features/client/receptions/domain/usecases/get_reception_client.dart';
import 'package:clinic/features/client/receptions/presentation/bloc/reception_bloc.dart';
import 'package:clinic/core/network/network_manager.dart';

final sl = GetIt.instance;

Future<void> registerReceptionsModule() async {
  sl.registerLazySingleton<ReceptionRemoteDataSource>(
    () => ReceptionRemoteDataSourceImpl(sl<NetworkManager>()),
  );
  sl.registerLazySingleton<ReceptionRepository>(
    () => ReceptionRepositoryImpl(sl<ReceptionRemoteDataSource>()),
  );

  sl.registerLazySingleton(() => GetReceptionClient(sl()));
  sl.registerLazySingleton(() => GetReceptionInfo(sl()));
  sl.registerLazySingleton(() => GetReceptionList(sl()));
  
  sl.registerFactory(() => ReceptionBloc(sl(), sl(), sl()));
}
