import 'package:bloc/bloc.dart';
import 'package:clinic/core/usecase/usecase.dart';
import 'package:clinic/features/home/domain/clinics/entities/clinics_entity.dart';
import 'package:clinic/features/home/domain/clinics/usecase/get_clinics_usecase.dart';
import 'package:equatable/equatable.dart';

part 'clinics_event.dart';
part 'clinics_state.dart';

class ClinicsBloc extends Bloc<ClinicsEvent, ClinicsState> {
  final GetClinicsUsecase getClinicsUsecase;
  ClinicsBloc(this.getClinicsUsecase) : super(ClinicsInitial()) {
    on<GetClinicsEvent>(_getClinicsEvent);
  }

  Future<void> _getClinicsEvent(
      GetClinicsEvent event, Emitter<ClinicsState> emit) async {
    emit(ClinicsLoading());
    final result = await getClinicsUsecase.call(NoParams());
    result.fold(
      (failure) => emit(ClinicsError(failure.message)),
      (clinics) {
        if (clinics.isEmpty) {
          emit(ClinicsEmpty("Нет доступных клиник"));
        } else {
          emit(ClinicsLoaded(clinics));
        }
      },
    );
  }
}
