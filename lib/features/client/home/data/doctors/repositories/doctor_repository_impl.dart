import 'package:clinic/core/error/either.dart';
import 'package:clinic/core/error/failure.dart';
import 'package:clinic/features/client/home/data/doctors/datasource/doctor_remote_data_source.dart';
import 'package:clinic/features/client/home/domain/doctors/entities/doctor_entity.dart';
import 'package:clinic/features/client/home/domain/doctors/repositories/doctor_repository.dart';

class DoctorRepositoryImpl implements DoctorRepository {
  final DoctorRemoteDataSource remoteDataSource;

  DoctorRepositoryImpl({
    required this.remoteDataSource,
  });

  @override
  Future<Either<Failure, List<DoctorEntity>>> getDoctors() async {
    final result = await remoteDataSource.getDoctors();
    return result.fold(
      (failure) => Left(failure),
      (doctorModel) => Right(doctorModel),
    );
  }
}
