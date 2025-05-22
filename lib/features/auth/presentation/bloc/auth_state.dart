// lib/features/auth/presentation/bloc/auth_state.dart
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
