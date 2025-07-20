import 'package:clinic/core/error/either.dart';
import 'package:clinic/core/error/failure.dart';
import 'package:clinic/core/usecase/usecase.dart';
import 'package:clinic/features/client/appointments/data/models/appointment_filter.dart';
import 'package:clinic/features/client/appointments/data/models/appointment_model.dart';
import 'package:clinic/features/client/appointments/domain/repositories/appointment_repository.dart';

class GetAppointmentParams {
  final AppointmentFilters? filters;

  const GetAppointmentParams({this.filters});
}

class GetAppointmentUsecase
    implements UseCase<List<AppointmentModel>, GetAppointmentParams> {
  final AppointmentRepository repository;

  const GetAppointmentUsecase(this.repository);

  @override
  Future<Either<Failure, List<AppointmentModel>>> call(
      GetAppointmentParams params) async {
    return await repository.getAppointments(filters: params.filters);
  }
}
