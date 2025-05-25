import 'package:clinic/core/error/either.dart';
import 'package:clinic/core/error/failure.dart';
import 'package:clinic/features/auth/domain/entities/auth_request_entities.dart';
import 'package:clinic/features/auth/domain/entities/auth_response_entity.dart';
import 'package:clinic/features/auth/domain/entities/doctor_login_request_entity.dart';
import 'package:clinic/features/auth/domain/entities/doctor_login_response_entity.dart';
import 'package:clinic/features/auth/domain/entities/otp_response_entity.dart';
import 'package:clinic/features/auth/domain/entities/send_otp_entity.dart';
import 'package:clinic/features/auth/domain/entities/verify_otp_entity.dart';

abstract class AuthRepository {
  Future<Either<Failure, AuthResponseEntity>> loginWithVK(AuthRequest params);
  Future<Either<Failure, String>> sendOtp(SendOtpEntity params);
  Future<Either<Failure, OtpResponseEntity>> verifyOtp(VerifyOtpEntity params);
  Future<Either<Failure, DoctorLoginResponse>> doctorLogin(
      DoctorLoginRequest params);
}
