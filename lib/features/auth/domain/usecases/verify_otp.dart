import 'package:clinic/core/usecase/usecase.dart';
import 'package:clinic/features/auth/domain/entities/verify_otp_entity.dart';
import 'package:clinic/features/auth/domain/entities/otp_response_entity.dart';
import 'package:clinic/features/auth/domain/repositories/auth_repository.dart';
import 'package:clinic/core/error/either.dart';
import 'package:clinic/core/error/failure.dart';

class VerifyOtp implements UseCase<OtpResponseEntity, VerifyOtpEntity> {
  final AuthRepository repository;

  const VerifyOtp(this.repository);

  @override
  Future<Either<Failure, OtpResponseEntity>> call(VerifyOtpEntity params) {
    return repository.verifyOtp(params);
  }
}