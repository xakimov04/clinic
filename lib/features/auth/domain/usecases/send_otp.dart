import 'package:clinic/core/usecase/usecase.dart';
import 'package:clinic/features/auth/domain/entities/send_otp_entity.dart';
import 'package:clinic/features/auth/domain/repositories/auth_repository.dart';
import 'package:clinic/core/error/either.dart';
import 'package:clinic/core/error/failure.dart';

class SendOtp implements UseCase<String, SendOtpEntity> {
  final AuthRepository repository;

  const SendOtp(this.repository);

  @override
  Future<Either<Failure, String>> call(SendOtpEntity params) {
    return repository.sendOtp(params);
  }
}
