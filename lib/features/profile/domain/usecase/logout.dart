import 'package:clinic/core/error/either.dart';
import 'package:clinic/core/error/failure.dart';
import 'package:clinic/core/usecase/usecase.dart';
import 'package:clinic/features/profile/domain/repositories/profile_repositories.dart';

class Logout implements UseCase<void, NoParams> {
  final ProfileRepository repository;

  Logout(this.repository);

  @override
  Future<Either<Failure, void>> call(NoParams params) {
    return repository.logout();
  }
}
