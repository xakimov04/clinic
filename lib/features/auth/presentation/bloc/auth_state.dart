// lib/features/auth/presentation/bloc/auth_state.dart
import 'package:clinic/features/auth/domain/entities/doctor_login_response_entity.dart';
import 'package:clinic/features/auth/domain/entities/otp_response_entity.dart';
import 'package:equatable/equatable.dart';
import 'package:clinic/features/auth/domain/entities/auth_response_entity.dart';

abstract class AuthState extends Equatable {
  const AuthState();

  @override
  List<Object?> get props => [];
}

class AuthInitial extends AuthState {}

class AuthLoading extends AuthState {}

class AuthAuthenticated extends AuthState {
  final AuthResponseEntity authResponseEntity;

  const AuthAuthenticated(this.authResponseEntity);

  @override
  List<Object?> get props => [AuthResponseEntity];
}

class AuthUnauthenticated extends AuthState {}

class AuthFailure extends AuthState {
  final String message;

  const AuthFailure(this.message);

  @override
  List<Object?> get props => [message];
}

// OTP-specific states
class OtpSending extends AuthState {}

class OtpSent extends AuthState {
  final String message;

  const OtpSent(this.message);

  @override
  List<Object?> get props => [message];
}

class OtpVerifying extends AuthState {}

class OtpVerified extends AuthState {
  final OtpResponseEntity otpResponse;

  const OtpVerified(this.otpResponse);

  @override
  List<Object?> get props => [otpResponse];
}

class OtpFailure extends AuthState {
  final String message;

  const OtpFailure(this.message);

  @override
  List<Object?> get props => [message];
}

// Doctor login states
class DoctorLoginLoading extends AuthState {}

class DoctorLoginAuthenticated extends AuthState {
  final DoctorLoginResponse doctorLoginResponse;

  const DoctorLoginAuthenticated(this.doctorLoginResponse);

  @override
  List<Object?> get props => [doctorLoginResponse];
}

class DoctorLoginFailure extends AuthState {
  final String message;

  const DoctorLoginFailure(this.message);

  @override
  List<Object?> get props => [message];
}
