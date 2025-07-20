import 'package:clinic/core/error/either.dart';
import 'package:clinic/core/error/failure.dart';
import 'package:clinic/core/usecase/usecase.dart';
import 'package:clinic/features/client/appointments/data/models/put_appointment_model.dart';
import 'package:clinic/features/client/appointments/domain/repositories/appointment_repository.dart';
import 'package:equatable/equatable.dart';

class PutAppointmentParams extends Equatable {
  final PutAppointmentModel request;
  final String id;

  const PutAppointmentParams({
    required this.request,
    required this.id,
  });

  @override
  List<Object?> get props => [request, id];
}

class PutAppointmentUsecase implements UseCase<PutAppointmentModel, PutAppointmentParams> {
  final AppointmentRepository repository;

  const PutAppointmentUsecase(this.repository);

  @override
  Future<Either<Failure, PutAppointmentModel>> call(PutAppointmentParams params) async {
    return await repository.putAppointment(params.request, params.id);
  }
}
