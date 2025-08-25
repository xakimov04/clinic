import 'package:clinic/core/error/either.dart';
import 'package:clinic/core/error/failure.dart';
import 'package:clinic/features/doctor/home/domain/entity/doctor_appointment_entity.dart';

abstract class DoctorAppointmentRepository {
  Future<Either<Failure, List<DoctorAppointmentEntity>>>
      getDoctorAppointments();
}
