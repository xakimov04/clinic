import 'package:clinic/core/error/either.dart';
import 'package:clinic/core/error/failure.dart';
import 'package:clinic/features/auth/data/datasources/auth_remote_source.dart';
import 'package:clinic/features/auth/data/models/auth_request_model.dart';
import 'package:clinic/features/auth/data/models/doctor_login_request_model.dart';
import 'package:clinic/features/auth/data/models/send_otp_model.dart';
import 'package:clinic/features/auth/data/models/verify_otp_model.dart';
import 'package:clinic/features/auth/domain/entities/auth_request_entities.dart';
import 'package:clinic/features/auth/domain/entities/auth_response_entity.dart';
import 'package:clinic/features/auth/domain/entities/doctor_login_request_entity.dart';
import 'package:clinic/features/auth/domain/entities/doctor_login_response_entity.dart';
import 'package:clinic/features/auth/domain/entities/send_otp_entity.dart';
import 'package:clinic/features/auth/domain/entities/verify_otp_entity.dart';
import 'package:clinic/features/auth/domain/entities/otp_response_entity.dart';
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

  @override
  Future<Either<Failure, String>> sendOtp(SendOtpEntity params) async {
    final requestModel = SendOtpModel.fromEntity(params);
    return await remoteSource.sendOtp(requestModel);
  }

  @override
  Future<Either<Failure, OtpResponseEntity>> verifyOtp(
      VerifyOtpEntity params) async {
    final requestModel = VerifyOtpModel.fromEntity(params);
    final response = await remoteSource.verifyOtp(requestModel);

    return response.fold(
      (failure) => Left(failure),
      (data) => Right(
        OtpResponseEntity(
          detail: data.detail,
          token: data.token,
          userId: data.userId,
          userType: data.userType,
          isNewUser: data.isNewUser,
        ),
      ),
    );
  }

  @override
  Future<Either<Failure, DoctorLoginResponse>> doctorLogin(
      DoctorLoginRequest params) async {
    final requestModel = DoctorLoginRequestModel(
      username: params.username,
      password: params.password,
    );
    final response = await remoteSource.doctorLogin(requestModel);
    return response.fold(
      (failure) => Left(failure),
      (data) => Right(
        DoctorLoginResponse(
          accessToken: data.accessToken,
          refreshToken: data.refreshToken,
          detail: data.detail,
          userId: data.userId,
          userType: data.userType,
        ),
      ),
    );
  }
}
