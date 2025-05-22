// lib/features/auth/presentation/bloc/auth_event.dart
import 'package:clinic/features/auth/domain/entities/auth_request_entities.dart';
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
