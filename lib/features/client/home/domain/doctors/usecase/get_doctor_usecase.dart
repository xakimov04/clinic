import 'package:clinic/core/error/either.dart';
import 'package:clinic/core/error/failure.dart';
import 'package:clinic/core/usecase/usecase.dart';
import 'package:clinic/features/client/home/domain/doctors/entities/doctor_entity.dart';
import 'package:clinic/features/client/home/domain/doctors/repositories/doctor_repository.dart';

class GetDoctorUsecase implements UseCase<List<DoctorEntity>, NoParams> {
  final DoctorRepository repository;

  GetDoctorUsecase(this.repository);

  @override
  Future<Either<Failure, List<DoctorEntity>>> call(NoParams params) async {
    return await repository.getDoctors();
  }
}
