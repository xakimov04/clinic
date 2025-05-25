import 'package:clinic/core/error/either.dart';
import 'package:clinic/core/error/failure.dart';
import 'package:clinic/core/usecase/usecase.dart';
import 'package:clinic/features/profile/domain/entities/profile_entities.dart';
import 'package:clinic/features/profile/domain/repositories/profile_repositories.dart';

class UpdateProfile implements UseCase<ProfileEntities, ProfileEntities> {
  final ProfileRepository repository;

  UpdateProfile(this.repository);

  @override
  Future<Either<Failure, ProfileEntities>> call(ProfileEntities params) {
    return repository.updateProfile(params);
  }
}