import 'package:clinic/core/error/either.dart';
import 'package:clinic/core/error/failure.dart';
import 'package:clinic/core/network/network_manager.dart';
import 'package:clinic/features/client/home/data/illness/model/illness_model.dart';

abstract class IllnessDataSource {
  Future<Either<Failure, List<IllnessModel>>> getAllIllnesses();
  Future<Either<Failure, IllnessModel>> getIllnessDetails(int id);
}

class IllnessDataSourceImpl implements IllnessDataSource {
  final NetworkManager networkManager;
  IllnessDataSourceImpl(this.networkManager);

  @override
  Future<Either<Failure, List<IllnessModel>>> getAllIllnesses() async {
    try {
      final response = await networkManager.fetchData(
        url: 'illness/',
      );
      final data =
          (response as List).map((e) => IllnessModel.fromJson(e)).toList();
      return Right(data);
    } catch (e) {
      return Left(ServerFailure(
        message: e.toString(),
      ));
    }
  }

  @override
  Future<Either<Failure, IllnessModel>> getIllnessDetails(int id) async {
    try {
      final response = await networkManager.fetchData(
        url: 'illness/$id',
      );
      final data = IllnessModel.fromJson(response);
      return Right(data);
    } catch (e) {
      return Left(ServerFailure(
        message: e.toString(),
      ));
    }
  }
}
