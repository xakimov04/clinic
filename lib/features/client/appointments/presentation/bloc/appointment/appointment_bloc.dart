import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:clinic/features/client/appointments/domain/usecases/create_appointment_usecase.dart';
import 'package:clinic/features/client/appointments/domain/usecases/get_appointment_usecase.dart';
import 'package:clinic/features/client/appointments/domain/usecases/get_doctor_clinics_usecase.dart';
import 'package:clinic/features/client/appointments/domain/usecases/put_appointment_usecase.dart';
import 'appointment_event.dart';
import 'appointment_state.dart';

class AppointmentBloc extends Bloc<AppointmentEvent, AppointmentState> {
  final GetDoctorClinicsUsecase getDoctorClinicsUsecase;
  final CreateAppointmentUsecase createAppointmentUsecase;
  final PutAppointmentUsecase putAppointmentUsecase;
  final GetAppointmentUsecase getAppointmentUsecase;

  AppointmentBloc({
    required this.getDoctorClinicsUsecase,
    required this.createAppointmentUsecase,
    required this.putAppointmentUsecase,
    required this.getAppointmentUsecase,
  }) : super(AppointmentInitial()) {
    on<GetDoctorClinicsEvent>(_onGetDoctorClinics);
    on<CreateAppointmentEvent>(_onCreateAppointment);
    on<UpdateAppointmentEvent>(_onUpdateAppointment);
    on<GetAppointmentsEvent>(_onGetAppointments);
  }

  Future<void> _onGetDoctorClinics(
    GetDoctorClinicsEvent event,
    Emitter<AppointmentState> emit,
  ) async {
    emit(AppointmentLoading());
    final result = await getDoctorClinicsUsecase(
      GetDoctorClinicsParams(doctorId: event.doctorId),
    );
    result.fold(
      (failure) => emit(AppointmentError(message: failure.message)),
      (clinics) => emit(DoctorClinicsLoaded(clinics: clinics)),
    );
  }

  Future<void> _onCreateAppointment(
    CreateAppointmentEvent event,
    Emitter<AppointmentState> emit,
  ) async {
    emit(AppointmentLoading());
    final result = await createAppointmentUsecase(event.request);
    result.fold(
      (failure) => emit(AppointmentError(message: failure.message)),
      (_) => emit(AppointmentCreated()),
    );
  }

  Future<void> _onUpdateAppointment(
    UpdateAppointmentEvent event,
    Emitter<AppointmentState> emit,
  ) async {
    emit(AppointmentLoading());
    final result = await putAppointmentUsecase(
      PutAppointmentParams(
        request: event.request,
        id: event.id,
      ),
    );
    result.fold(
      (failure) => emit(AppointmentError(message: failure.message)),
      (data) => emit(AppointmentUpdated(data)),
    );
  }

  Future<void> _onGetAppointments(
    GetAppointmentsEvent event,
    Emitter<AppointmentState> emit,
  ) async {
    emit(AppointmentLoading());
    final result = await getAppointmentUsecase(
      GetAppointmentParams(filters: event.filters),
    );
    result.fold(
      (failure) => emit(AppointmentError(message: failure.message)),
      (appointments) => emit(AppointmentsLoaded(appointments: appointments)),
    );
  }
}
