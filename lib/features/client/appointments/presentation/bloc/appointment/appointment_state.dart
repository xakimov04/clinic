import 'package:clinic/features/client/appointments/data/models/put_appointment_model.dart';
import 'package:equatable/equatable.dart';
import 'package:clinic/features/client/appointments/data/models/appointment_model.dart';
import 'package:clinic/features/client/appointments/domain/entities/clinic_entity.dart';

abstract class AppointmentState extends Equatable {
  const AppointmentState();

  @override
  List<Object?> get props => [];
}

class AppointmentInitial extends AppointmentState {}

class AppointmentLoading extends AppointmentState {}

class DoctorClinicsLoaded extends AppointmentState {
  final List<ClinicEntity> clinics;

  const DoctorClinicsLoaded({required this.clinics});

  @override
  List<Object?> get props => [clinics];
}

class AppointmentsLoaded extends AppointmentState {
  final List<AppointmentModel> appointments;

  const AppointmentsLoaded({required this.appointments});

  @override
  List<Object?> get props => [appointments];
}

class AppointmentCreated extends AppointmentState {}

class AppointmentUpdated extends AppointmentState {
  final PutAppointmentModel putAppointmentModel;
  const AppointmentUpdated(this.putAppointmentModel);

  @override
  List<Object?> get props => [putAppointmentModel];
}

class AppointmentError extends AppointmentState {
  final String message;

  const AppointmentError({required this.message});

  @override
  List<Object?> get props => [message];
}
