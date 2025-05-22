import 'package:clinic/core/error/either.dart';
import 'package:clinic/core/error/failure.dart';
import 'package:clinic/core/usecase/usecase.dart';
import 'package:clinic/features/home/domain/clinics/entities/clinics_entity.dart';
import 'package:clinic/features/home/domain/clinics/repositories/clinics_repository.dart';

class GetClinicsUsecase implements UseCase<List<ClinicsEntity>, NoParams> {
  final ClinicsRepository repository;

  GetClinicsUsecase(this.repository);

  @override
  Future<Either<Failure, List<ClinicsEntity>>> call(NoParams params) async {
    return await repository.getClinics();
  }
}
