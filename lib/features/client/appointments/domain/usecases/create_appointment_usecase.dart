import 'package:clinic/core/error/either.dart';
import 'package:clinic/core/error/failure.dart';
import 'package:clinic/core/usecase/usecase.dart';
import 'package:clinic/features/client/appointments/domain/entities/create_appointment_request.dart';
import 'package:clinic/features/client/appointments/domain/repositories/appointment_repository.dart';

class CreateAppointmentUsecase implements UseCase<void, CreateAppointmentRequest> {
  final AppointmentRepository repository;

  const CreateAppointmentUsecase(this.repository);

  @override
  Future<Either<Failure, void>> call(CreateAppointmentRequest params) {
    return repository.createAppointment(params);
  }
}