import 'package:bloc/bloc.dart';
import 'package:clinic/core/usecase/usecase.dart';
import 'package:clinic/features/doctor/home/domain/entity/doctor_appointment_entity.dart';
import 'package:clinic/features/doctor/home/domain/usecase/get_doctor_appointments.dart';
import 'package:equatable/equatable.dart';

part 'doctor_appointment_event.dart';
part 'doctor_appointment_state.dart';

class DoctorAppointmentBloc
    extends Bloc<DoctorAppointmentEvent, DoctorAppointmentState> {
  final GetDoctorAppointments getDoctorAppointments;

  DoctorAppointmentBloc({
    required this.getDoctorAppointments,
  }) : super(DoctorAppointmentInitial()) { 
    on<LoadDoctorAppointmentsEvent>(_onLoadDoctorAppointments);
  }

  Future<void> _onLoadDoctorAppointments(
    LoadDoctorAppointmentsEvent event,
    Emitter<DoctorAppointmentState> emit,
  ) async {
    emit(DoctorAppointmentLoading());

    final result = await getDoctorAppointments(NoParams());

    result.fold(
      (error) => emit(DoctorAppointmentError(error.message)),
      (appointments) => emit(DoctorAppointmentLoaded(appointments)),
    );
  }
}