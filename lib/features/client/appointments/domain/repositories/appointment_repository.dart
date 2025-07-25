import 'package:clinic/core/error/either.dart';
import 'package:clinic/core/error/failure.dart';
import 'package:clinic/features/client/appointments/data/models/appointment_filter.dart';
import 'package:clinic/features/client/appointments/data/models/appointment_model.dart';
import 'package:clinic/features/client/appointments/data/models/put_appointment_model.dart';
import 'package:clinic/features/client/appointments/domain/entities/clinic_entity.dart';
import 'package:clinic/features/client/appointments/domain/entities/create_appointment_request.dart';

abstract class AppointmentRepository {
  Future<Either<Failure, List<ClinicEntity>>> getDoctorClinics(int doctorId);
  Future<Either<Failure, void>> createAppointment(
      CreateAppointmentRequest request);
  Future<Either<Failure, PutAppointmentModel>> putAppointment(
      PutAppointmentModel request, String id);
  Future<Either<Failure, List<AppointmentModel>>> getAppointments({
    AppointmentFilters? filters,
  });
}
