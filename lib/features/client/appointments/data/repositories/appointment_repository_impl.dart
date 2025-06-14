import 'package:clinic/core/error/either.dart';
import 'package:clinic/core/error/failure.dart';
import 'package:clinic/core/network/network_service.dart';
import 'package:clinic/features/client/appointments/data/models/appointment_model.dart';
import 'package:clinic/features/client/appointments/data/models/clinic_model.dart';
import 'package:clinic/features/client/appointments/domain/entities/clinic_entity.dart';
import 'package:clinic/features/client/appointments/domain/entities/create_appointment_request.dart';
import 'package:clinic/features/client/appointments/domain/repositories/appointment_repository.dart';

class AppointmentRepositoryImpl implements AppointmentRepository {
  @override
  Future<Either<Failure, List<ClinicEntity>>> getDoctorClinics(
      int doctorId) async {
    try {
      final response = await NetworkService.request(
        url: 'doctors/$doctorId/clinics/',
        method: 'GET',
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = response.data;
        final clinics = data.map((json) => ClinicModel.fromJson(json)).toList();
        return Right(clinics);
      } else {
        return Left(ServerFailure(message: 'Failed to load clinics'));
      }
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> createAppointment(
      CreateAppointmentRequest request) async {
    try {
      final response = await NetworkService.request(
        url: 'appointments/create/',
        method: 'POST',
        data: request.toJson(),
      );

      if (response.statusCode == 201) {
        return const Right(null);
      } else {
        return Left(ServerFailure(message: 'Failed to create appointment'));
      }
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<AppointmentModel>>> getAppointments() async {
    try {
      final response = await NetworkService.request(
        url: 'appointments/',
        method: 'GET',
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = response.data;
        final appointments =
            data.map((json) => AppointmentModel.fromJson(json)).toList();
        return Right(appointments);
      } else {
        return Left(ServerFailure(message: 'Failed to load appointments'));
      }
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<void> cancelAppointment(int appointmentId) async {
    try {
      final response = await NetworkService.request(
        url: 'appointments/$appointmentId/cancel/',
        method: 'POST',
      );

      if (response.statusCode != 200) {
        throw Exception('Failed to cancel appointment');
      }
    } catch (e) {
      throw Exception(e.toString());
    }
  }

  @override
  Future<void> rescheduleAppointment(
      int appointmentId, DateTime newDate, String newTime) async {
    try {
      final response = await NetworkService.request(
        url: 'appointments/$appointmentId/reschedule/',
        method: 'POST',
        data: {
          'date': newDate.toIso8601String().split('T')[0],
          'time': newTime,
        },
      );

      if (response.statusCode != 200) {
        throw Exception('Failed to reschedule appointment');
      }
    } catch (e) {
      throw Exception(e.toString());
    }
  }
}
