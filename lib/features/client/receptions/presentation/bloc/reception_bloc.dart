// reception_bloc.dart
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
  ReceptionCombinedState _currentCombinedState = ReceptionCombinedState();

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
      (failure) => emit(ReceptionError(failure.message, errorType: 'client')),
      (data) => emit(ReceptionLoaded(data)),
    );
  }

  Future<void> _onGetReceptionsListEvent(
    GetReceptionsListEvent event,
    Emitter<ReceptionState> emit,
  ) async {
    emit(ReceptionListLoading());
    final result = await getReceptionList(event.id);
    result.fold(
      (failure) {
        emit(ReceptionError(failure.message, errorType: 'list'));
      },
      (data) {
        _currentCombinedState = _currentCombinedState.copyWith(
          receptionList: data,
        );
        emit(ReceptionListLoaded(data));
        emit(_currentCombinedState);
      },
    );
  }

  Future<void> _onGetReceptionsInfoEvent(
    GetReceptionsInfoEvent event,
    Emitter<ReceptionState> emit,
  ) async {
    // Loading holatini qo'shish
    final updatedLoadingIds =
        Set<String>.from(_currentCombinedState.loadingInfoIds)..add(event.id);

    _currentCombinedState = _currentCombinedState.copyWith(
      loadingInfoIds: updatedLoadingIds,
    );

    emit(ReceptionInfoLoading(event.id));
    emit(_currentCombinedState);

    final result = await getReceptionInfo(event.id);
    result.fold(
      (failure) {
        // Loading ni olib tashlash
        final updatedLoadingIds =
            Set<String>.from(_currentCombinedState.loadingInfoIds)
              ..remove(event.id);

        _currentCombinedState = _currentCombinedState.copyWith(
          loadingInfoIds: updatedLoadingIds,
          error: failure.message,
        );

        emit(ReceptionError(failure.message, errorType: 'info'));
        emit(_currentCombinedState);
      },
      (data) {
        // Ma'lumotlarni saqlash va loading ni olib tashlash
        final updatedInfos = Map<String, List<ReceptionInfoEntity>>.from(
            _currentCombinedState.receptionInfos);
        updatedInfos[event.id] = data;

        final updatedLoadingIds =
            Set<String>.from(_currentCombinedState.loadingInfoIds)
              ..remove(event.id);

        _currentCombinedState = _currentCombinedState.copyWith(
          receptionInfos: updatedInfos,
          loadingInfoIds: updatedLoadingIds,
        );

        emit(ReceptionInfoLoaded(event.id, data));
        emit(_currentCombinedState);
      },
    );
  }
}
