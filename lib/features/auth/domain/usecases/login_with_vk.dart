import 'package:clinic/core/usecase/usecase.dart';
import 'package:clinic/features/auth/domain/entities/auth_request_entities.dart';
import 'package:clinic/features/auth/domain/repositories/auth_repository.dart';
import '../entities/auth_response_entity.dart';
import 'package:clinic/core/error/either.dart';
import 'package:clinic/core/error/failure.dart';

class LoginWithVK implements UseCase<AuthResponseEntity, AuthRequest> {
  final AuthRepository repository;

  const LoginWithVK(this.repository);

  @override
  Future<Either<Failure, AuthResponseEntity>> call(AuthRequest params) {
    return repository.loginWithVK(
      params,
    );
  }
}
