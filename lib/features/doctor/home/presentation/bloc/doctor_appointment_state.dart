part of 'doctor_appointment_bloc.dart';

sealed class DoctorAppointmentState extends Equatable {
  const DoctorAppointmentState();

  @override
  List<Object> get props => [];
}

final class DoctorAppointmentInitial extends DoctorAppointmentState {}

final class DoctorAppointmentLoading extends DoctorAppointmentState {}

final class DoctorAppointmentLoaded extends DoctorAppointmentState {
  final List<DoctorAppointmentEntity> data;
  const DoctorAppointmentLoaded(this.data);
  @override
  List<Object> get props => [data];
}

final class DoctorAppointmentError extends DoctorAppointmentState {
  final String error;
  const DoctorAppointmentError(this.error);
  @override
  List<Object> get props => [error];
}
