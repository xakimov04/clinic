import 'package:clinic/features/doctor/home/data/datasource/doctor_appointment_remote_data_source.dart';
import 'package:clinic/features/doctor/home/data/repositories/doctor_appointment_repository_impl.dart';
import 'package:clinic/features/doctor/home/domain/repositories/doctor_appointment_repository.dart';
import 'package:clinic/features/doctor/home/domain/usecase/get_doctor_appointments.dart';
import 'package:clinic/features/doctor/home/presentation/bloc/doctor_appointment_bloc.dart';
import 'package:get_it/get_it.dart';

final sl = GetIt.instance;

Future<void> registerDoctorAppointmentsModule() async {
  // Data Source
  sl.registerLazySingleton<DoctorAppointmentRemoteDataSource>(
    () => DoctorAppointmentRemoteDataSourceImpl(
      networkManager: sl(),
    ),
  );

  // Repository
  sl.registerLazySingleton<DoctorAppointmentRepository>(
    () => DoctorAppointmentRepositoryImpl(
      remoteDataSource: sl(),
      platformInfo: sl(),
    ),
  );

  // Use Cases
  sl.registerLazySingleton(() => GetDoctorAppointments(sl()));

  // BLoC
  sl.registerFactory(() => DoctorAppointmentBloc(
        getDoctorAppointments: sl(),
      ));
}
