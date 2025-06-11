import 'package:clinic/core/error/either.dart';
import 'package:clinic/core/error/failure.dart';
import 'package:clinic/features/client/home/domain/illness/entities/illness_entities.dart';

abstract class IllnessRepository {
  Future<Either<Failure, List<IllnessEntities>>> getAllIllnesses();
  Future<Either<Failure, IllnessEntities>> getIllnessDetails(int id);
}
