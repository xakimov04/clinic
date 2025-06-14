part of '../clinics_doctor/clinics_doctors_bloc.dart';

abstract class ClinicsDoctorsState extends Equatable {
  const ClinicsDoctorsState();

  @override
  List<Object> get props => [];
}

class ClinicsDoctorsInitial extends ClinicsDoctorsState {}

class ClinicsDoctorsLoading extends ClinicsDoctorsState {}

class ClinicsDoctorsLoaded extends ClinicsDoctorsState {
  final List<DoctorEntity> doctors;

  const ClinicsDoctorsLoaded(this.doctors);

  @override
  List<Object> get props => [doctors];
}

class ClinicsDoctorsEmpty extends ClinicsDoctorsState {
  final String message;

  const ClinicsDoctorsEmpty(this.message);

  @override
  List<Object> get props => [message];
}

class ClinicsDoctorsError extends ClinicsDoctorsState {
  final String message;

  const ClinicsDoctorsError(this.message);

  @override
  List<Object> get props => [message];
}
