import 'package:clinic/core/error/either.dart';
import 'package:clinic/core/error/failure.dart';
import 'package:clinic/core/network/network_manager.dart';
import 'package:clinic/features/auth/data/models/auth_request_model.dart';
import 'package:clinic/features/auth/data/models/auth_response_model.dart';
import 'package:clinic/features/auth/data/models/doctor_login_request_model.dart';
import 'package:clinic/features/auth/data/models/doctor_login_response_model.dart';
import 'package:clinic/features/auth/data/models/send_otp_model.dart';
import 'package:clinic/features/auth/data/models/verify_otp_model.dart';
import 'package:clinic/features/auth/data/models/otp_response_model.dart';

abstract class AuthRemoteSource {
  Future<Either<Failure, AuthResponseModel>> loginWithVK(
      AuthRequestModel params);
  Future<Either<Failure, String>> sendOtp(SendOtpModel params);
  Future<Either<Failure, OtpResponseModel>> verifyOtp(VerifyOtpModel params);
  Future<Either<Failure, DoctorLoginResponseModel>> doctorLogin(
      DoctorLoginRequestModel params);
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
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, String>> sendOtp(SendOtpModel params) async {
    try {
      final response = await networkManager.postData(
        url: 'auth/request-otp/',
        useAuthorization: true,
        data: params.toJson(),
      );
      return Right(response['detail'] ?? 'OTP muvaffaqiyatli yuborildi');
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, OtpResponseModel>> verifyOtp(
      VerifyOtpModel params) async {
    try {
      final response = await networkManager.postData(
        url: 'auth/verify-otp/',
        useAuthorization: true,
        data: params.toJson(),
      );
      final data = OtpResponseModel.fromJson(response);
      return Right(data);
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, DoctorLoginResponseModel>> doctorLogin(
      DoctorLoginRequestModel params) async {
    try {
      final response = await networkManager.postData(
        url: 'auth/doctor-login/',
        useAuthorization: true,
        data: params.toJson(),
      );
      final data = DoctorLoginResponseModel.fromJson(response);

      return Right(data);
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }
}
