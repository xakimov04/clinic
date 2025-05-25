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

// Profile updating states
class ProfileUpdating extends ProfileState {}

class ProfileUpdateSuccess extends ProfileState {
  final ProfileEntities updatedUser;

  const ProfileUpdateSuccess(this.updatedUser);

  @override
  List<Object> get props => [updatedUser];
}

class ProfileUpdateError extends ProfileState {
  final String message;

  const ProfileUpdateError(this.message);

  @override
  List<Object> get props => [message];
}

// Logout states
class LogoutLoading extends ProfileState {}

class LogoutSuccess extends ProfileState {}

class LogoutError extends ProfileState {
  final String message;

  const LogoutError(this.message);

  @override
  List<Object> get props => [message];
}
