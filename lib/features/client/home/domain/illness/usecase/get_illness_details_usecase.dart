import 'package:clinic/core/error/either.dart';
import 'package:clinic/core/error/failure.dart';
import 'package:clinic/core/usecase/usecase.dart';
import 'package:clinic/features/client/home/domain/illness/entities/illness_entities.dart';
import 'package:clinic/features/client/home/domain/illness/repositories/illness_repositories.dart';

class GetIllnessDetailsUseCase implements UseCase<IllnessEntities, int> {
  final IllnessRepository repository;

  GetIllnessDetailsUseCase(this.repository);

  @override
  Future<Either<Failure, IllnessEntities>> call(int params) async {
    return await repository.getIllnessDetails(params);
  }
}
