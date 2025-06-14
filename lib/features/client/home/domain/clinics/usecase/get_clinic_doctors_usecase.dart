import 'package:clinic/core/error/either.dart';
import 'package:clinic/core/error/failure.dart';
import 'package:clinic/core/usecase/usecase.dart';
import 'package:clinic/features/client/home/domain/doctors/entities/doctor_entity.dart';
import 'package:clinic/features/client/home/domain/clinics/repositories/clinics_repository.dart';

class GetClinicDoctorsUsecase implements UseCase<List<DoctorEntity>, int> {
  final ClinicsRepository repository;

  GetClinicDoctorsUsecase(this.repository);

  @override
  Future<Either<Failure, List<DoctorEntity>>> call(int params) async {
    return await repository.getClinicDoctors(params);
  }
}
