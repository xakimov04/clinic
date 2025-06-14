import 'package:clinic/core/di/export/di_export.dart';
import 'package:clinic/features/client/appointments/data/datasources/appointment_remote_data_source.dart';
import 'package:clinic/features/client/appointments/data/repositories/appointment_repository_impl.dart';
import 'package:clinic/features/client/appointments/domain/repositories/appointment_repository.dart';
import 'package:clinic/features/client/appointments/presentation/bloc/appointment_booking/appointment_booking_bloc.dart';
import 'package:clinic/features/client/appointments/domain/usecases/create_appointment_usecase.dart';
import 'package:clinic/features/client/appointments/domain/usecases/get_doctor_clinics_usecase.dart';

Future<void> registerAppointmentModule() async {
  final sl = GetIt.instance;

  // Data Sources
  sl.registerLazySingleton<AppointmentRemoteDataSource>(
    () => AppointmentRemoteDataSourceImpl(sl<NetworkManager>()),
  );

  // Repositories
  sl.registerLazySingleton<AppointmentRepository>(
    () => AppointmentRepositoryImpl(),
  );

  // Use Cases
  sl.registerLazySingleton(
    () => GetDoctorClinicsUsecase(sl<AppointmentRepository>()),
  );
  sl.registerLazySingleton(
    () => CreateAppointmentUsecase(sl<AppointmentRepository>()),
  );

  // BLoC
  sl.registerFactory(
    () => AppointmentBookingBloc(
      getDoctorClinicsUsecase: sl<GetDoctorClinicsUsecase>(),
      createAppointmentUsecase: sl<CreateAppointmentUsecase>(),
    ),
  );
}
