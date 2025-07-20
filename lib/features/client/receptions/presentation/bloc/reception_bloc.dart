import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:clinic/core/usecase/usecase.dart';
import 'package:clinic/features/client/receptions/domain/entities/reception_client_entity.dart';
import 'package:clinic/features/client/receptions/domain/entities/reception_info_entity.dart';
import 'package:clinic/features/client/receptions/domain/entities/reception_list_entity.dart';
import 'package:clinic/features/client/receptions/domain/usecases/get_reception_client.dart';
import 'package:clinic/features/client/receptions/domain/usecases/get_reception_info.dart';
import 'package:clinic/features/client/receptions/domain/usecases/get_reception_list.dart';

part 'reception_event.dart';
part 'reception_state.dart';

class ReceptionBloc extends Bloc<ReceptionEvent, ReceptionState> {
  final GetReceptionClient getReceptionsUseCase;
  final GetReceptionInfo getReceptionInfo;
  final GetReceptionList getReceptionList;

  ReceptionBloc(
    this.getReceptionsUseCase,
    this.getReceptionInfo,
    this.getReceptionList,
  ) : super(ReceptionInitial()) {
    on<GetReceptionsClientEvent>(_onGetReceptionsClientEvent);
    on<GetReceptionsInfoEvent>(_onGetReceptionsInfoEvent);
    on<GetReceptionsListEvent>(_onGetReceptionsListEvent);
  }

  Future<void> _onGetReceptionsClientEvent(
    GetReceptionsClientEvent event,
    Emitter<ReceptionState> emit,
  ) async {
    emit(ReceptionLoading());
    final result = await getReceptionsUseCase(NoParams());
    result.fold(
      (failure) => emit(ReceptionError(failure.message)),
      (data) => emit(ReceptionLoaded(data)),
    );
  }

  Future<void> _onGetReceptionsInfoEvent(
    GetReceptionsInfoEvent event,
    Emitter<ReceptionState> emit,
  ) async {
    emit(ReceptionLoading());
    final result = await getReceptionInfo(event.id);
    result.fold(
      (failure) => emit(ReceptionError(failure.message)),
      (data) => emit(ReceptionInfoLoaded(data)),
    );
  }

  Future<void> _onGetReceptionsListEvent(
    GetReceptionsListEvent event,
    Emitter<ReceptionState> emit,
  ) async {
    emit(ReceptionLoading());
    final result = await getReceptionList(event.id);
    result.fold(
      (failure) => emit(ReceptionError(failure.message)),
      (data) => emit(ReceptionListLoaded(data)),
    );
  }
}
