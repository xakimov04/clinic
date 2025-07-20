import 'package:clinic/core/di/export/di_export.dart';
import 'package:clinic/features/client/appointments/data/datasources/appointment_remote_data_source.dart';
import 'package:clinic/features/client/appointments/data/repositories/appointment_repository_impl.dart';
import 'package:clinic/features/client/appointments/domain/repositories/appointment_repository.dart';
import 'package:clinic/features/client/appointments/presentation/bloc/appointment_booking/appointment_booking_bloc.dart';
import 'package:clinic/features/client/appointments/domain/usecases/create_appointment_usecase.dart';
import 'package:clinic/features/client/appointments/domain/usecases/get_doctor_clinics_usecase.dart';
import 'package:clinic/features/client/appointments/domain/usecases/get_appointment_usecase.dart';
import 'package:clinic/features/client/appointments/domain/usecases/put_appointment_usecase.dart';
import 'package:clinic/features/client/appointments/presentation/bloc/appointment/appointment_bloc.dart';

Future<void> registerAppointmentModule() async {
  final sl = GetIt.instance;

  // Data Sources
  sl.registerLazySingleton<AppointmentRemoteDataSource>(
    () => AppointmentRemoteDataSourceImpl(sl<NetworkManager>()),
  );

  // Repositories
  sl.registerLazySingleton<AppointmentRepository>(
    () => AppointmentRepositoryImpl(remoteDataSource: sl()),
  );

  // Use Cases
  sl.registerLazySingleton(
    () => GetDoctorClinicsUsecase(sl<AppointmentRepository>()),
  );
  sl.registerLazySingleton(
    () => CreateAppointmentUsecase(sl<AppointmentRepository>()),
  );
  sl.registerLazySingleton(
    () => PutAppointmentUsecase(sl<AppointmentRepository>()),
  );
  sl.registerLazySingleton(
    () => GetAppointmentUsecase(sl<AppointmentRepository>()),
  );

  // BLoCs
  sl.registerFactory(
    () => AppointmentBookingBloc(
      getDoctorClinicsUsecase: sl<GetDoctorClinicsUsecase>(),
      createAppointmentUsecase: sl<CreateAppointmentUsecase>(),
    ),
  );

  sl.registerFactory(
    () => AppointmentBloc(
      getDoctorClinicsUsecase: sl<GetDoctorClinicsUsecase>(),
      createAppointmentUsecase: sl<CreateAppointmentUsecase>(),
      putAppointmentUsecase: sl<PutAppointmentUsecase>(),
      getAppointmentUsecase: sl<GetAppointmentUsecase>(),
    ),
  );
}
