import 'package:bloc/bloc.dart';
import 'package:clinic/features/client/appointments/domain/entities/appointment_entity.dart';
import 'package:clinic/features/client/appointments/domain/entities/clinic_entity.dart';
import 'package:clinic/features/client/appointments/domain/entities/create_appointment_request.dart';
import 'package:clinic/features/client/appointments/domain/entities/time_slot_entity.dart';
import 'package:clinic/features/client/appointments/domain/usecases/create_appointment_usecase.dart';
import 'package:clinic/features/client/appointments/domain/usecases/get_doctor_clinics_usecase.dart';
import 'package:clinic/features/client/home/domain/doctors/entities/doctor_entity.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

part 'appointment_booking_event.dart';
part 'appointment_booking_state.dart';

class AppointmentBookingBloc
    extends Bloc<AppointmentBookingEvent, AppointmentBookingState> {
  final GetDoctorClinicsUsecase _getDoctorClinicsUsecase;
  final CreateAppointmentUsecase _createAppointmentUsecase;

  AppointmentBookingBloc({
    required GetDoctorClinicsUsecase getDoctorClinicsUsecase,
    required CreateAppointmentUsecase createAppointmentUsecase,
  })  : _getDoctorClinicsUsecase = getDoctorClinicsUsecase,
        _createAppointmentUsecase = createAppointmentUsecase,
        super(const AppointmentBookingState()) {
    on<LoadDoctorClinics>(_onLoadDoctorClinics);
    on<SelectClinic>(_onSelectClinic);
    on<SelectDate>(_onSelectDate);
    on<SelectTime>(_onSelectTime);
    on<UpdateNotes>(_onUpdateNotes);
    on<CreateAppointment>(_onCreateAppointment);
    on<ResetBooking>(_onResetBooking);
  }

  Future<void> _onLoadDoctorClinics(
      LoadDoctorClinics event, Emitter<AppointmentBookingState> emit) async {
    // Avval doctor ma'lumotlarini o'rnatamiz
    emit(state.copyWith(
      status: AppointmentBookingStatus.loading,
      doctor: event.doctor,
    ));

    final result = await _getDoctorClinicsUsecase(
        GetDoctorClinicsParams(doctorId: event.doctorId));

    result.fold(
      (failure) => emit(state.copyWith(
        status: AppointmentBookingStatus.error,
        errorMessage: failure.message,
      )),
      (clinics) => emit(state.copyWith(
        status: AppointmentBookingStatus.loaded,
        clinics: clinics,
        timeSlots: _generateTimeSlots(),
      )),
    );
  }

  void _onSelectClinic(
      SelectClinic event, Emitter<AppointmentBookingState> emit) {
    emit(state.copyWith(selectedClinic: event.clinic));
  }

  void _onSelectDate(SelectDate event, Emitter<AppointmentBookingState> emit) {
    emit(state.copyWith(
        selectedDate: event.date, specialization: event.specialization));
  }

  void _onSelectTime(SelectTime event, Emitter<AppointmentBookingState> emit) {
    final updatedTimeSlots = state.timeSlots.map((slot) {
      return slot.copyWith(isSelected: slot.time == event.time);
    }).toList();

    TimeOfDay parseTime(String timeString) {
      final parts = timeString.split(':');
      final hour = int.parse(parts[0]);
      final minute = int.parse(parts[1]);
      return TimeOfDay(hour: hour, minute: minute);
    }

    emit(state.copyWith(
      timeSlots: updatedTimeSlots,
      selectedTime: parseTime(event.time),
    ));
  }

  void _onUpdateNotes(
      UpdateNotes event, Emitter<AppointmentBookingState> emit) {
    emit(state.copyWith(notes: event.notes));
  }

  Future<void> _onCreateAppointment(
      CreateAppointment event, Emitter<AppointmentBookingState> emit) async {
    if (!state.isReadyToBook) {
      emit(state.copyWith(
        status: AppointmentBookingStatus.error,
        errorMessage: 'Iltimos, barcha ma\'lumotlarni to\'ldiring',
      ));
      return;
    }

    emit(state.copyWith(status: AppointmentBookingStatus.creating));

    final request = CreateAppointmentRequest(
        employeeId: state.doctor!.username,
        clinicId: state.selectedClinic!.uuid,
        date: state.selectedDate!,
        timeBegin: state.selectedTime!,
        comment: state.notes,
        specialization: state.specialization);

    final result = await _createAppointmentUsecase(request);

    result.fold(
      (failure) => emit(state.copyWith(
        status: AppointmentBookingStatus.error,
        errorMessage: failure.message,
        errorCode: failure.code,
      )),
      (appointment) => emit(state.copyWith(
        status: AppointmentBookingStatus.success,
      )),
    );
  }

  void _onResetBooking(
      ResetBooking event, Emitter<AppointmentBookingState> emit) {
    emit(const AppointmentBookingState());
  }

  List<TimeSlotEntity> _generateTimeSlots() {
    final List<TimeSlotEntity> slots = [];

    for (int hour = 9; hour <= 17; hour++) {
      for (int minute = 0; minute < 60; minute += 30) {
        final timeString =
            '${hour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')}';
        slots.add(TimeSlotEntity(
          time: timeString,
          isAvailable: true,
        ));
      }
    }

    return slots;
  }
}
