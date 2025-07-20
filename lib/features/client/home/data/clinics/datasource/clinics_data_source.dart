import 'package:clinic/core/error/either.dart';
import 'package:clinic/core/error/failure.dart';
import 'package:clinic/core/network/network_manager.dart';
import 'package:clinic/features/client/home/data/clinics/models/clinics_model.dart';
import 'package:clinic/features/client/home/data/doctors/models/doctor_model.dart';

abstract class ClinicsDataSource {
  Future<Either<Failure, List<ClinicsModel>>> getClinics();
  Future<Either<Failure, List<DoctorModel>>> getClinicDoctors(int clinicId);
}

class ClinicsDataSourceImpl implements ClinicsDataSource {
  final NetworkManager networkManager;
  ClinicsDataSourceImpl(this.networkManager);
  @override
  Future<Either<Failure, List<ClinicsModel>>> getClinics() async {
    try {
      final response = await networkManager.fetchData(
        url: 'clinics/',
      );
      final data =
          (response as List).map((e) => ClinicsModel.fromJson(e)).toList();
      return Right(data);
    } catch (e) {
      return Left(ServerFailure(
        message:
            'Произошла ошибка при загрузке данных. Пожалуйста, попробуйте позже.',
      ));
    }
  }

  @override
  Future<Either<Failure, List<DoctorModel>>> getClinicDoctors(
      int clinicId) async {
    try {
      final response = await networkManager.fetchData(
        url: 'clinics/$clinicId/doctors/',
      );
      final data =
          (response as List).map((e) => DoctorModel.fromJson(e)).toList();
      return Right(data);
    } catch (e) {
      return Left(ServerFailure(
        message:
            'Произошла ошибка при загрузке данных. Пожалуйста, попробуйте позже.',
      ));
    }
  }
}
