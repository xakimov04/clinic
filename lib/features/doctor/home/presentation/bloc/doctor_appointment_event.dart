part of 'doctor_appointment_bloc.dart';

sealed class DoctorAppointmentEvent extends Equatable {
  const DoctorAppointmentEvent();

  @override
  List<Object?> get props => [];
}

class LoadDoctorAppointmentsEvent extends DoctorAppointmentEvent {
  const LoadDoctorAppointmentsEvent();

  @override
  List<Object?> get props => [];
}
