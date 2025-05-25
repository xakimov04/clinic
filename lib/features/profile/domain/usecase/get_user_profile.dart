import 'package:clinic/core/error/either.dart';
import 'package:clinic/core/error/failure.dart';
import 'package:clinic/core/usecase/usecase.dart';
import 'package:clinic/features/profile/domain/entities/profile_entities.dart';
import 'package:clinic/features/profile/domain/repositories/profile_repositories.dart';

class GetUserProfile implements UseCase<ProfileEntities, NoParams> {
  final ProfileRepository repository;

  GetUserProfile(this.repository);

  @override
  Future<Either<Failure, ProfileEntities>> call(NoParams params) {
    return repository.getUserProfile();
  }
}
