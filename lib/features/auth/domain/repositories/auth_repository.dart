import 'package:clinic/core/error/either.dart';
import 'package:clinic/core/error/failure.dart';
import 'package:clinic/features/auth/domain/entities/auth_request_entities.dart';
import 'package:clinic/features/auth/domain/entities/auth_response_entity.dart';

abstract class AuthRepository {
  Future<Either<Failure, AuthResponseEntity>> loginWithVK(AuthRequest params);
}
