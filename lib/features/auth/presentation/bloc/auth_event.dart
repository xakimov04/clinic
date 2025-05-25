// lib/features/auth/presentation/bloc/auth_event.dart
import 'package:clinic/features/auth/domain/entities/auth_request_entities.dart';
import 'package:clinic/features/auth/domain/entities/doctor_login_request_entity.dart';
import 'package:clinic/features/auth/domain/entities/send_otp_entity.dart';
import 'package:clinic/features/auth/domain/entities/verify_otp_entity.dart';
import 'package:equatable/equatable.dart';

abstract class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object?> get props => [];
}

class LoginWithVKEvent extends AuthEvent {
  final AuthRequest authRequestEntities;
  const LoginWithVKEvent(this.authRequestEntities);
  @override
  List<Object?> get props => [authRequestEntities];
}

class SendOtpEvent extends AuthEvent {
  final SendOtpEntity sendOtpEntity;

  const SendOtpEvent(this.sendOtpEntity);

  @override
  List<Object?> get props => [sendOtpEntity];
}

class VerifyOtpEvent extends AuthEvent {
  final VerifyOtpEntity verifyOtpEntity;

  const VerifyOtpEvent(this.verifyOtpEntity);

  @override
  List<Object?> get props => [verifyOtpEntity];
}

class DoctorLoginEvent extends AuthEvent {
  final DoctorLoginRequest doctorLoginRequest;

  const DoctorLoginEvent(this.doctorLoginRequest);

  @override
  List<Object?> get props => [doctorLoginRequest];
}
