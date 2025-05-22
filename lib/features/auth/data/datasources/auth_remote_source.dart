import 'package:clinic/core/error/either.dart';
import 'package:clinic/core/error/failure.dart';
import 'package:clinic/core/network/network_manager.dart';
import 'package:clinic/features/auth/data/models/auth_request_model.dart';
import 'package:clinic/features/auth/data/models/auth_response_model.dart';

abstract class AuthRemoteSource {
  Future<Either<Failure, AuthResponseModel>> loginWithVK(
      AuthRequestModel params);
}

class AuthRemoteSourceImpl implements AuthRemoteSource {
  final NetworkManager networkManager;
  AuthRemoteSourceImpl({required this.networkManager});
  @override
  Future<Either<Failure, AuthResponseModel>> loginWithVK(
      AuthRequestModel params) async {
    try {
      final response = await networkManager.postData(
        url: 'auth/',
        useAuthorization: true,
        data: params.toJson(),
      );
      final data = AuthResponseModel.fromJson(response);
      return Right(data);
    } catch (e) {
      return Left(ServerFailure(
        message: e.toString(),
      ));
    }
  }
}
