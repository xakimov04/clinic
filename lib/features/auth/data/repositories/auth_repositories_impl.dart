import 'package:clinic/core/error/either.dart';
import 'package:clinic/core/error/failure.dart';
import 'package:clinic/features/auth/data/datasources/auth_remote_source.dart';
import 'package:clinic/features/auth/data/models/auth_request_model.dart';
import 'package:clinic/features/auth/domain/entities/auth_request_entities.dart';
import 'package:clinic/features/auth/domain/entities/auth_response_entity.dart';
import 'package:clinic/features/auth/domain/repositories/auth_repository.dart';

class AuthRepositoriesImpl implements AuthRepository {
  final AuthRemoteSource remoteSource;
  AuthRepositoriesImpl({required this.remoteSource});
  @override
  Future<Either<Failure, AuthResponseEntity>> loginWithVK(
      AuthRequest params) async {
    final requestModel = AuthRequestModel(
      accessToken: params.accessToken,
      firstName: params.firstName,
      lastName: params.lastName,
      vkId: params.vkId,
    );
    final response = await remoteSource.loginWithVK(requestModel);
    return response.fold(
      (failure) => Left(failure),
      (data) => Right(
        AuthResponseEntity(
          accessToken: data.accessToken,
          refreshToken: data.refreshToken,
          user: data.user,
        ),
      ),
    );
  }
}
