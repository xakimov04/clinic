// lib/features/auth/domain/usecases/doctor_login.dart
import 'package:clinic/core/usecase/usecase.dart';
import 'package:clinic/features/auth/domain/entities/doctor_login_request_entity.dart';
import 'package:clinic/features/auth/domain/entities/doctor_login_response_entity.dart';
import 'package:clinic/features/auth/domain/repositories/auth_repository.dart';
import 'package:clinic/core/error/either.dart';
import 'package:clinic/core/error/failure.dart';

class DoctorLogin implements UseCase<DoctorLoginResponse, DoctorLoginRequest> {
  final AuthRepository repository;

  const DoctorLogin(this.repository);

  @override
  Future<Either<Failure, DoctorLoginResponse>> call(DoctorLoginRequest params) {
    return repository.doctorLogin(params);
  }
}