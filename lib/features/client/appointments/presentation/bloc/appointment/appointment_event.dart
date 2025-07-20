import 'package:clinic/features/client/appointments/data/models/appointment_filter.dart';
import 'package:equatable/equatable.dart';
import 'package:clinic/features/client/appointments/data/models/put_appointment_model.dart';
import 'package:clinic/features/client/appointments/domain/entities/create_appointment_request.dart';

abstract class AppointmentEvent extends Equatable {
  const AppointmentEvent();

  @override
  List<Object?> get props => [];
}

class GetDoctorClinicsEvent extends AppointmentEvent {
  final int doctorId;

  const GetDoctorClinicsEvent({required this.doctorId});

  @override
  List<Object?> get props => [doctorId];
}

class CreateAppointmentEvent extends AppointmentEvent {
  final CreateAppointmentRequest request;

  const CreateAppointmentEvent({required this.request});

  @override
  List<Object?> get props => [request];
}

class UpdateAppointmentEvent extends AppointmentEvent {
  final PutAppointmentModel request;
  final String id;

  const UpdateAppointmentEvent({
    required this.request,
    required this.id,
  });

  @override
  List<Object?> get props => [request, id];
}

class GetAppointmentsEvent extends AppointmentEvent {
  final AppointmentFilters? filters;

  const GetAppointmentsEvent({this.filters});

  @override
  List<Object?> get props => [filters];
}
