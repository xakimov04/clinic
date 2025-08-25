import 'package:clinic/core/error/either.dart';
import 'package:clinic/core/error/exception.dart';
import 'package:clinic/core/error/failure.dart';
import 'package:clinic/core/platform/platform_info.dart';
import 'package:clinic/features/doctor/home/data/datasource/doctor_appointment_remote_data_source.dart';
import 'package:clinic/features/doctor/home/domain/entity/doctor_appointment_entity.dart';
import 'package:clinic/features/doctor/home/domain/repositories/doctor_appointment_repository.dart';

class DoctorAppointmentRepositoryImpl implements DoctorAppointmentRepository {
  final DoctorAppointmentRemoteDataSource remoteDataSource;
  final PlatformInfo platformInfo;

  DoctorAppointmentRepositoryImpl({
    required this.remoteDataSource,
    required this.platformInfo,
  });

  @override
  Future<Either<Failure, List<DoctorAppointmentEntity>>> getDoctorAppointments({
    int? page,
    int? limit,
    String? status,
    DateTime? fromDate,
    DateTime? toDate,
  }) async {
    try {
      final appointments = await remoteDataSource.getDoctorAppointments();

      return Right(appointments);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } on FormatException {
      return const Left(ServerFailure(message: 'Ошибка формата данных'));
    } catch (e) {
      return Left(
          ServerFailure(message: 'Неожиданная ошибка: ${e.toString()}'));
    }
  }
}
