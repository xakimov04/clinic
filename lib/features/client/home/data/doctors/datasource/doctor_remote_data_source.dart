import 'package:clinic/core/error/either.dart';
import 'package:clinic/core/error/failure.dart';
import 'package:clinic/core/di/export/di_export.dart';
import 'package:clinic/features/client/home/data/doctors/models/doctor_model.dart';

abstract class DoctorRemoteDataSource {
  Future<Either<Failure, List<DoctorModel>>> getDoctors();
}

class DoctorRemoteDataSourceImpl implements DoctorRemoteDataSource {
  final NetworkManager networkManager;
  DoctorRemoteDataSourceImpl(this.networkManager);

  @override
  Future<Either<Failure, List<DoctorModel>>> getDoctors() async {
    try {
      final response = await networkManager.fetchData(
        url: 'doctors/available/',
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
