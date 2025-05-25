import 'package:bloc/bloc.dart';
import 'package:clinic/core/usecase/usecase.dart';
import 'package:clinic/features/client/home/domain/doctors/entities/doctor_entity.dart';
import 'package:clinic/features/client/home/domain/doctors/usecase/get_doctor_usecase.dart';
import 'package:equatable/equatable.dart';

part 'doctor_event.dart';
part 'doctor_state.dart';

class DoctorBloc extends Bloc<DoctorEvent, DoctorState> {
  final GetDoctorUsecase getDoctorUsecase;
  DoctorBloc(this.getDoctorUsecase) : super(DoctorInitial()) {
    on<GetDoctorEvent>(_getDoctorEvent);
  }

  Future<void> _getDoctorEvent(
      GetDoctorEvent event, Emitter<DoctorState> emit) async {
    emit(DoctorLoading());
    final result = await getDoctorUsecase(NoParams());
    result.fold(
      (failure) => emit(DoctorError(failure.message)),
      (doctor) => emit(DoctorLoaded(doctor)),
    );
  }
}
