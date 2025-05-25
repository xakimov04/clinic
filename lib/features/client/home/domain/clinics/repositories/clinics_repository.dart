import 'package:clinic/core/error/either.dart';
import 'package:clinic/core/error/failure.dart';
import 'package:clinic/features/client/home/domain/clinics/entities/clinics_entity.dart';

abstract class ClinicsRepository {
  Future<Either<Failure, List<ClinicsEntity>>> getClinics();
}
