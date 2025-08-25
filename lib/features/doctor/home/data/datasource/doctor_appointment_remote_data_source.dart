import 'package:clinic/core/error/exception.dart';
import 'package:clinic/core/network/network_manager.dart';
import 'package:clinic/features/doctor/home/data/model/doctor_appointment_model.dart';

abstract class DoctorAppointmentRemoteDataSource {
  Future<List<DoctorAppointmentModel>> getDoctorAppointments();

}

class DoctorAppointmentRemoteDataSourceImpl
    implements DoctorAppointmentRemoteDataSource {
  final NetworkManager networkManager;

  DoctorAppointmentRemoteDataSourceImpl({required this.networkManager});

  @override
  Future<List<DoctorAppointmentModel>> getDoctorAppointments() async {
    try {
      final response = await networkManager.fetchData(
        url: '/get-zayovok-doktora',
      );

      final data = response as List<dynamic>; // ✅ cast qildik

      return data.map((json) => DoctorAppointmentModel.fromJson(json)).toList();
    } catch (e) {
      throw ServerException(
        message: 'Ошибка при получении данных: ${e.toString()}',
      );
    }
  }

 
}
