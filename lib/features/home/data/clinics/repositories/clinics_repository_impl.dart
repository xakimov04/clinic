import 'package:clinic/core/error/either.dart';
import 'package:clinic/core/error/failure.dart';
import 'package:clinic/features/home/data/clinics/datasource/clinics_data_source.dart';
import 'package:clinic/features/home/domain/clinics/entities/clinics_entity.dart';
import 'package:clinic/features/home/domain/clinics/repositories/clinics_repository.dart';

class ClinicsRepositoryImpl implements ClinicsRepository {
  final ClinicsDataSource remoteDataSource;
  
  ClinicsRepositoryImpl({
    required this.remoteDataSource,
  });

  @override
  Future<Either<Failure, List<ClinicsEntity>>> getClinics() async {
    final result = await remoteDataSource.getClinics();
    return result.fold(
      (failure) => Left(failure),
      (clinicsModel) => Right(clinicsModel),
    );
  }
}
