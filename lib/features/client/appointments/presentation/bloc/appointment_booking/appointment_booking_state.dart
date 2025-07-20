part of 'appointment_booking_bloc.dart';

enum AppointmentBookingStatus {
  initial,
  loading,
  loaded,
  creating,
  success,
  error,
}
class AppointmentBookingState extends Equatable {
  final AppointmentBookingStatus status;
  final DoctorEntity? doctor;
  final List<ClinicEntity> clinics;
  final ClinicEntity? selectedClinic;
  final List<DoctorEntity> clinicDoctors;
  final DateTime? selectedDate;
  final TimeOfDay? selectedTime;
  final List<TimeSlotEntity> timeSlots;
  final String notes;
  final String specialization;
  final String? errorMessage;
  final String? errorCode;
  final AppointmentEntity? createdAppointment;

  const AppointmentBookingState({
    this.status = AppointmentBookingStatus.initial,
    this.doctor,
    this.clinics = const [],
    this.selectedClinic,
    this.clinicDoctors = const [],
    this.selectedDate,
    this.selectedTime,
    this.timeSlots = const [],
    this.notes = '',
    this.specialization = '',
    this.errorMessage,
    this.errorCode,
    this.createdAppointment,
  });

  bool get isReadyToBook =>
      doctor != null &&
      selectedClinic != null &&
      selectedDate != null &&
      selectedTime != null;

  AppointmentBookingState copyWith({
    AppointmentBookingStatus? status,
    DoctorEntity? doctor,
    List<ClinicEntity>? clinics,
    ClinicEntity? selectedClinic,
    List<DoctorEntity>? clinicDoctors,
    DateTime? selectedDate,
    TimeOfDay? selectedTime,
    List<TimeSlotEntity>? timeSlots,
    String? notes,
    String? specialization,
    String? errorMessage,
    String? errorCode,
    AppointmentEntity? createdAppointment,
  }) {
    return AppointmentBookingState(
      status: status ?? this.status,
      doctor: doctor ?? this.doctor,
      clinics: clinics ?? this.clinics,
      selectedClinic: selectedClinic ?? this.selectedClinic,
      clinicDoctors: clinicDoctors ?? this.clinicDoctors,
      selectedDate: selectedDate ?? this.selectedDate,
      selectedTime: selectedTime ?? this.selectedTime,
      timeSlots: timeSlots ?? this.timeSlots,
      notes: notes ?? this.notes,
      specialization: specialization ?? this.specialization,
      errorMessage: errorMessage ?? this.errorMessage,
      errorCode: errorCode ?? this.errorCode,
      createdAppointment: createdAppointment ?? this.createdAppointment,
    );
  }

  @override
  List<Object?> get props => [
        status,
        doctor,
        clinics,
        selectedClinic,
        clinicDoctors,
        selectedDate,
        selectedTime,
        timeSlots,
        notes,
        specialization,
        errorMessage,
        errorCode,
        createdAppointment,
      ];
}
