import 'package:clinic/core/error/either.dart';
import 'package:clinic/core/error/failure.dart';
import 'package:clinic/core/network/network_manager.dart';
import 'package:clinic/features/client/appointments/data/models/appointment_filter.dart';
import 'package:clinic/features/client/appointments/data/models/appointment_model.dart';
import 'package:clinic/features/client/appointments/data/models/clinic_model.dart';
import 'package:clinic/features/client/appointments/data/models/put_appointment_model.dart';
import 'package:clinic/features/client/appointments/domain/entities/create_appointment_request.dart';

abstract class AppointmentRemoteDataSource {
  Future<Either<Failure, List<ClinicModel>>> getDoctorClinics(int doctorId);
  Future<Either<Failure, void>> createAppointment(
      CreateAppointmentRequest request);
  Future<Either<Failure, PutAppointmentModel>> putAppointment(
      PutAppointmentModel request, String id);
  Future<Either<Failure, List<AppointmentModel>>> getAppointments({
    AppointmentFilters? filters,
  });
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
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> createAppointment(
      CreateAppointmentRequest request) async {
    await networkManager.postData(
      url: '/book-appointment-v2/',
      data: request.toJson(),
    );

    return Right(null);
  }

  @override
  Future<Either<Failure, List<AppointmentModel>>> getAppointments({
    AppointmentFilters? filters,
  }) async {
    try {
      String url = 'employees-client/';

      final response = await networkManager.fetchData(url: url);

      final List<dynamic> data = response['data'];
      final appointments =
          data.map((json) => AppointmentModel.fromJson(json)).toList();
      return Right(appointments);
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, PutAppointmentModel>> putAppointment(
      PutAppointmentModel request, String id) async {
    try {
      final response = await networkManager.putData(
        url: 'appointments/$id/',
        data: request.toJson(),
      );
      final data = PutAppointmentModel.fromJson(response);

      return Right(data);
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }
}
