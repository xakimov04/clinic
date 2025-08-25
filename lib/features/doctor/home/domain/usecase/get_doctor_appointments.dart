import 'package:clinic/core/error/either.dart';
import 'package:clinic/core/error/failure.dart';
import 'package:clinic/core/usecase/usecase.dart';
import 'package:clinic/features/doctor/home/domain/entity/doctor_appointment_entity.dart';
import 'package:clinic/features/doctor/home/domain/repositories/doctor_appointment_repository.dart';

class GetDoctorAppointments
    implements UseCase<List<DoctorAppointmentEntity>, NoParams> {
  final DoctorAppointmentRepository repository;

  GetDoctorAppointments(this.repository);

  @override
  Future<Either<Failure, List<DoctorAppointmentEntity>>> call(params) async {
    return await repository.getDoctorAppointments();
  }
}
