import 'package:clinic/core/error/either.dart';
import 'package:clinic/core/error/failure.dart';
import 'package:clinic/core/network/network_manager.dart';
import 'package:clinic/features/home/data/illness/model/illness_model.dart';

abstract class IllnessDataSource {
  Future<Either<Failure, List<IllnessModel>>> getAllIllnesses();
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
}
