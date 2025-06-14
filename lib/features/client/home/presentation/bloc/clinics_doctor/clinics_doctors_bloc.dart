import 'package:bloc/bloc.dart';
import 'package:clinic/features/client/home/domain/doctors/entities/doctor_entity.dart';
import 'package:clinic/features/client/home/domain/clinics/usecase/get_clinic_doctors_usecase.dart';
import 'package:equatable/equatable.dart';

part 'clinics_doctors_event.dart';
part 'clinics_doctors_state.dart';

class ClinicsDoctorsBloc
    extends Bloc<ClinicsDoctorsEvent, ClinicsDoctorsState> {
  final GetClinicDoctorsUsecase getClinicDoctorsUsecase;

  ClinicsDoctorsBloc({
    required this.getClinicDoctorsUsecase,
  }) : super(ClinicsDoctorsInitial()) {
    on<GetClinicDoctorsEvent>(_getClinicDoctors);
  }

  Future<void> _getClinicDoctors(
    GetClinicDoctorsEvent event,
    Emitter<ClinicsDoctorsState> emit,
  ) async {
    emit(ClinicsDoctorsLoading());
    final result = await getClinicDoctorsUsecase(event.clinicId);
    result.fold(
      (failure) => emit(ClinicsDoctorsError(failure.message)),
      (doctors) {
        emit(ClinicsDoctorsLoaded(doctors));
      },
    );
  }
}
