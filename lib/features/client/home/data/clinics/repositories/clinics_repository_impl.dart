import 'package:clinic/core/error/either.dart';
import 'package:clinic/core/error/failure.dart';
import 'package:clinic/features/client/home/data/clinics/datasource/clinics_data_source.dart';
import 'package:clinic/features/client/home/domain/clinics/entities/clinics_entity.dart';
import 'package:clinic/features/client/home/domain/clinics/repositories/clinics_repository.dart';
import 'package:clinic/features/client/home/domain/doctors/entities/doctor_entity.dart';

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

  @override
  Future<Either<Failure, List<DoctorEntity>>> getClinicDoctors(
      int clinicId) async {
    final result = await remoteDataSource.getClinicDoctors(clinicId);
    return result.fold(
      (failure) => Left(failure),
      (doctorsModel) => Right(doctorsModel),
    );
  }
}
