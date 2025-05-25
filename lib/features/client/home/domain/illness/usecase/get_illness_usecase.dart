import 'package:clinic/core/error/either.dart';
import 'package:clinic/core/error/failure.dart';
import 'package:clinic/core/usecase/usecase.dart';
import 'package:clinic/features/client/home/domain/illness/entities/illness_entities.dart';
import 'package:clinic/features/client/home/domain/illness/repositories/illness_repositories.dart';

class GetIllnessUsecase implements UseCase<List<IllnessEntities>, NoParams> {
  final IllnessRepository repository;
  const GetIllnessUsecase(this.repository);

  @override
  Future<Either<Failure, List<IllnessEntities>>> call(NoParams params) {
    return repository.getAllIllnesses();
  }
}
