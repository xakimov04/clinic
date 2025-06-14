part of 'appointment_booking_bloc.dart';

abstract class AppointmentBookingEvent extends Equatable {
  const AppointmentBookingEvent();

  @override
  List<Object?> get props => [];
}

class LoadDoctorClinics extends AppointmentBookingEvent {
  final int doctorId;
  final DoctorEntity doctor;

  const LoadDoctorClinics({
    required this.doctorId,
    required this.doctor,
  });

  @override
  List<Object?> get props => [doctorId, doctor];
}



class SelectClinic extends AppointmentBookingEvent {
  final ClinicEntity clinic;

  const SelectClinic(this.clinic);

  @override
  List<Object?> get props => [clinic];
}

class SelectDate extends AppointmentBookingEvent {
  final DateTime date;

  const SelectDate(this.date);

  @override
  List<Object?> get props => [date];
}

class SelectTime extends AppointmentBookingEvent {
  final String time;

  const SelectTime(this.time);

  @override
  List<Object?> get props => [time];
}

class UpdateNotes extends AppointmentBookingEvent {
  final String notes;

  const UpdateNotes(this.notes);

  @override
  List<Object?> get props => [notes];
}

class CreateAppointment extends AppointmentBookingEvent {
  const CreateAppointment();
}

class ResetBooking extends AppointmentBookingEvent {
  const ResetBooking();
}
