import 'package:clinic/features/client/home/data/clinics/datasource/clinics_data_source.dart';
import 'package:clinic/features/client/home/data/clinics/repositories/clinics_repository_impl.dart';
import 'package:clinic/features/client/home/domain/clinics/repositories/clinics_repository.dart';
import 'package:clinic/features/client/home/domain/clinics/usecase/get_clinics_usecase.dart';
import 'package:clinic/features/client/home/domain/clinics/usecase/get_clinic_doctors_usecase.dart';
import 'package:clinic/features/client/home/domain/illness/usecase/get_illness_details_usecase.dart';
import 'package:clinic/features/client/home/presentation/bloc/clinics/clinics_bloc.dart';
import 'package:clinic/features/client/home/presentation/bloc/clinics_doctor/clinics_doctors_bloc.dart';

import '../export/di_export.dart';

Future<void> registerHomeModule() async {
  final sl = GetIt.instance;

  // Data Source
  sl.registerLazySingleton<DoctorRemoteDataSource>(
      () => DoctorRemoteDataSourceImpl(sl<NetworkManager>()));
  sl.registerLazySingleton<IllnessDataSource>(
      () => IllnessDataSourceImpl(sl<NetworkManager>()));
  sl.registerLazySingleton<ClinicsDataSource>(
      () => ClinicsDataSourceImpl(sl<NetworkManager>()));

  // Repository
  sl.registerLazySingleton<DoctorRepository>(() =>
      DoctorRepositoryImpl(remoteDataSource: sl<DoctorRemoteDataSource>()));
  sl.registerLazySingleton<IllnessRepository>(
      () => IllnessRepositoriesImpl(remoteDataSource: sl<IllnessDataSource>()));
  sl.registerLazySingleton<ClinicsRepository>(
      () => ClinicsRepositoryImpl(remoteDataSource: sl<ClinicsDataSource>()));

  // Use Cases
  sl.registerLazySingleton(() => GetDoctorUsecase(sl<DoctorRepository>()));
  sl.registerLazySingleton(() => GetIllnessUsecase(sl<IllnessRepository>()));
  sl.registerLazySingleton(() => GetClinicsUsecase(sl<ClinicsRepository>()));
  sl.registerLazySingleton(
      () => GetIllnessDetailsUseCase(sl<IllnessRepository>()));
  sl.registerLazySingleton(
      () => GetClinicDoctorsUsecase(sl<ClinicsRepository>()));

  // BLoC
  sl.registerFactory(() => DoctorBloc(sl<GetDoctorUsecase>()));
  sl.registerFactory(() =>
      IllnessBloc(getIllnessUsecase: sl(), getIllnessDetailsUseCase: sl()));
  sl.registerFactory(() => ClinicsBloc(sl<GetClinicsUsecase>()));
  sl.registerFactory(() => ClinicsDoctorsBloc(getClinicDoctorsUsecase: sl()));
}
