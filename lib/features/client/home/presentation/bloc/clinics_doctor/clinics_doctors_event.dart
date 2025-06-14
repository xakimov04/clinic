part of '../clinics_doctor/clinics_doctors_bloc.dart';

sealed class ClinicsDoctorsEvent extends Equatable {
  const ClinicsDoctorsEvent();

  @override
  List<Object> get props => [];
}

final class GetClinicDoctorsEvent extends ClinicsDoctorsEvent {
  final int clinicId;

  const GetClinicDoctorsEvent(this.clinicId);

  @override
  List<Object> get props => [clinicId];
}
