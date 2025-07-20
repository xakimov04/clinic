import 'package:clinic/core/error/either.dart';
import 'package:clinic/core/error/failure.dart';
import 'package:clinic/features/client/appointments/data/datasources/appointment_remote_data_source.dart';
import 'package:clinic/features/client/appointments/data/models/appointment_filter.dart';
import 'package:clinic/features/client/appointments/data/models/appointment_model.dart';
import 'package:clinic/features/client/appointments/data/models/put_appointment_model.dart';
import 'package:clinic/features/client/appointments/domain/entities/clinic_entity.dart';
import 'package:clinic/features/client/appointments/domain/entities/create_appointment_request.dart';
import 'package:clinic/features/client/appointments/domain/repositories/appointment_repository.dart';
import 'package:dio/dio.dart';

class AppointmentRepositoryImpl implements AppointmentRepository {
  final AppointmentRemoteDataSource _remoteDataSource;

  const AppointmentRepositoryImpl({
    required AppointmentRemoteDataSource remoteDataSource,
  }) : _remoteDataSource = remoteDataSource;

  @override
  Future<Either<Failure, List<ClinicEntity>>> getDoctorClinics(
    int doctorId,
  ) async {
    try {
      final result = await _remoteDataSource.getDoctorClinics(doctorId);

      return result.fold(
        (failure) => Left(failure),
        (clinicModels) {
          final entities = clinicModels.map((model) => model).toList();
          return Right(entities);
        },
      );
    } catch (e) {
      return Left(
        ServerFailure(message: 'Неожиданная ошибка при получении клиник: $e'),
      );
    }
  }

  @override
  Future<Either<Failure, void>> createAppointment(
    CreateAppointmentRequest request,
  ) async {
    try {
      final result = await _remoteDataSource.createAppointment(request);

      return result.fold(
        (failure) => Left(failure),
        (success) => const Right(null),
      );
    } on DioException catch (e) {
      return Left(
        ServerFailure(
            message: 'Неожиданная ошибка при создании записи',
            code: e.response!.statusCode.toString()),
      );
    } catch (e) {
      return Left(
        ServerFailure(message: 'Неожиданная ошибка при создании записи: $e'),
      );
    }
  }

  @override
  Future<Either<Failure, List<AppointmentModel>>> getAppointments({
    AppointmentFilters? filters,
  }) async {
    try {
      final result = await _remoteDataSource.getAppointments(filters: filters);

      return result.fold(
        (failure) => Left(failure),
        (appointments) => Right(appointments),
      );
    } catch (e) {
      return Left(
        ServerFailure(message: 'Неожиданная ошибка при получении записей: $e'),
      );
    }
  }

  @override
  Future<Either<Failure, PutAppointmentModel>> putAppointment(
    PutAppointmentModel request,
    String appointmentId,
  ) async {
    try {
      final result =
          await _remoteDataSource.putAppointment(request, appointmentId);

      return result.fold(
        (failure) => Left(failure),
        (success) => Right(success),
      );
    } catch (e) {
      return Left(
        ServerFailure(message: 'Неожиданная ошибка при обновлении записи: $e'),
      );
    }
  }

  Future<Either<Failure, void>> updateAppointmentStatus({
    required String appointmentId,
    required String status,
    required int doctorId,
    required int clinicId,
  }) async {
    final request = PutAppointmentModel(
      doctor: doctorId,
      clinic: clinicId,
      status: status,
    );

    return await putAppointment(request, appointmentId);
  }

  Future<Either<Failure, void>> acceptAppointment({
    required String appointmentId,
    required int doctorId,
    required int clinicId,
  }) async {
    return await updateAppointmentStatus(
      appointmentId: appointmentId,
      status: 'confirmed',
      doctorId: doctorId,
      clinicId: clinicId,
    );
  }

  Future<Either<Failure, void>> rejectAppointment({
    required String appointmentId,
    required int doctorId,
    required int clinicId,
  }) async {
    return await updateAppointmentStatus(
      appointmentId: appointmentId,
      status: 'cancelled',
      doctorId: doctorId,
      clinicId: clinicId,
    );
  }
}
