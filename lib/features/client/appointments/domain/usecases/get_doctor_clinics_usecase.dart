import 'package:clinic/core/error/either.dart';
import 'package:clinic/core/error/failure.dart';
import 'package:clinic/core/usecase/usecase.dart';
import 'package:clinic/features/client/appointments/domain/entities/clinic_entity.dart';
import 'package:clinic/features/client/appointments/domain/repositories/appointment_repository.dart';
import 'package:equatable/equatable.dart';

class GetDoctorClinicsParams extends Equatable {
  final int doctorId;

  const GetDoctorClinicsParams({required this.doctorId});

  @override
  List<Object?> get props => [doctorId];
}

class GetDoctorClinicsUsecase implements UseCase<List<ClinicEntity>, GetDoctorClinicsParams> {
  final AppointmentRepository repository;

  const GetDoctorClinicsUsecase(this.repository);

  @override
  Future<Either<Failure, List<ClinicEntity>>> call(GetDoctorClinicsParams params) {
    return repository.getDoctorClinics(params.doctorId);
  }
}
