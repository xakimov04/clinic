import 'package:clinic/core/error/either.dart';
import 'package:clinic/core/error/failure.dart';
import 'package:clinic/core/network/network_manager.dart';
import 'package:clinic/features/client/appointments/data/models/clinic_model.dart';
import 'package:clinic/features/client/appointments/domain/entities/create_appointment_request.dart';

abstract class AppointmentRemoteDataSource {
  Future<Either<Failure, List<ClinicModel>>> getDoctorClinics(int doctorId);
  Future<Either<Failure, void>> createAppointment(
      CreateAppointmentRequest request);
}

class AppointmentRemoteDataSourceImpl implements AppointmentRemoteDataSource {
  final NetworkManager networkManager;

  AppointmentRemoteDataSourceImpl(this.networkManager);

  @override
  Future<Either<Failure, List<ClinicModel>>> getDoctorClinics(
      int doctorId) async {
    try {
      final response = await networkManager.fetchData(
        url: '/doctors/$doctorId/clinics/',
      );

      final List<dynamic> data = response is List ? response : response.data;
      final clinics = data.map((json) => ClinicModel.fromJson(json)).toList();
      return Right(clinics);
    } catch (e) {
      return Left(ServerFailure(message: 'Tarmoq xatoligi: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, void>> createAppointment(
      CreateAppointmentRequest request) async {
    try {
      await networkManager.postData(
        url: '/appointments/create/',
        data: request.toJson(),
      );

      return Right(null);
    } catch (e) {
      return Left(ServerFailure(
          message: 'Appointment yaratishda xatolik: ${e.toString()}'));
    }
  }

 
}
