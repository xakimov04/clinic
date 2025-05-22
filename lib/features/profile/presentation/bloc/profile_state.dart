part of 'profile_bloc.dart';

abstract class ProfileState extends Equatable {
  const ProfileState();
  
  @override
  List<Object?> get props => [];
}

class ProfileInitial extends ProfileState {}

class ProfileLoading extends ProfileState {}

class ProfileLoaded extends ProfileState {
  final ProfileEntities user;
  
  const ProfileLoaded(this.user);
  
  @override
  List<Object> get props => [user];
}

class ProfileError extends ProfileState {
  final String message;
  
  const ProfileError(this.message);
  
  @override
  List<Object> get props => [message];
}

class LogoutLoading extends ProfileState {}

class LogoutSuccess extends ProfileState {}

class LogoutError extends ProfileState {
  final String message;
  
  const LogoutError(this.message);
  
  @override
  List<Object> get props => [message];
}