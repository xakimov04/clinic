import 'package:clinic/core/error/either.dart';
import 'package:clinic/core/error/failure.dart';
import 'package:clinic/features/client/home/data/illness/datasources/illness_data_source.dart';
import 'package:clinic/features/client/home/domain/illness/entities/illness_entities.dart';
import 'package:clinic/features/client/home/domain/illness/repositories/illness_repositories.dart';

class IllnessRepositoriesImpl implements IllnessRepository {
  final IllnessDataSource remoteDataSource;

  IllnessRepositoriesImpl({
    required this.remoteDataSource,
  });

  @override
  Future<Either<Failure, List<IllnessEntities>>> getAllIllnesses() async {
    final result = await remoteDataSource.getAllIllnesses();
    return result.fold(
      (failure) => Left(failure),
      (illnessModel) => Right(illnessModel),
    );
  }
}
