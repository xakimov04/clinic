part of 'profile_bloc.dart';

abstract class ProfileEvent extends Equatable {
  const ProfileEvent();

  @override
  List<Object> get props => [];
}

class GetProfileEvent extends ProfileEvent {}

class UpdateProfileEvent extends ProfileEvent {
  final ProfileEntities request;

  const UpdateProfileEvent(this.request);

  @override
  List<Object> get props => [request];
}

class LogoutEvent extends ProfileEvent {}
