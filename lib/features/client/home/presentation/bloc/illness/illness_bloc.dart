import 'package:bloc/bloc.dart';
import 'package:clinic/core/usecase/usecase.dart';
import 'package:clinic/features/client/home/domain/illness/entities/illness_entities.dart';
import 'package:clinic/features/client/home/domain/illness/usecase/get_illness_usecase.dart';
import 'package:clinic/features/client/home/domain/illness/usecase/get_illness_details_usecase.dart';
import 'package:equatable/equatable.dart';

part 'illness_event.dart';
part 'illness_state.dart';

class IllnessBloc extends Bloc<IllnessEvent, IllnessState> {
  final GetIllnessUsecase getIllnessUsecase;
  final GetIllnessDetailsUseCase getIllnessDetailsUseCase;

  IllnessBloc({
    required this.getIllnessUsecase,
    required this.getIllnessDetailsUseCase,
  }) : super(IllnessInitial()) {
    on<IllnessGetAll>(_illnessGetAll);
    on<IllnessGetAllNotLoading>(_illnessGetAllNotLoading);
    on<IllnessGetDetails>(_illnessGetDetails);
  }

  Future<void> _illnessGetAll(
    IllnessGetAll event,
    Emitter<IllnessState> emit,
  ) async {
    emit(IllnessLoading());
    final result = await getIllnessUsecase(NoParams());
    result.fold(
      (failure) {
        emit(IllnessError(failure.message));
      },
      (illnesses) {
        if (illnesses.isEmpty) {
          emit(const IllnessEmpty('Болезни не обнаружены'));
        } else {
          emit(IllnessLoaded(illnesses));
        }
      },
    );
  }

  Future<void> _illnessGetAllNotLoading(
    IllnessGetAllNotLoading event,
    Emitter<IllnessState> emit,
  ) async {
    final result = await getIllnessUsecase(NoParams());
    result.fold(
      (failure) {
        emit(IllnessError(failure.message));
      },
      (illnesses) {
        emit(IllnessLoaded(illnesses));
      },
    );
  }

  Future<void> _illnessGetDetails(
    IllnessGetDetails event,
    Emitter<IllnessState> emit,
  ) async {
    emit(IllnessDetailsLoading());
    final result = await getIllnessDetailsUseCase(event.id);
    result.fold(
      (failure) {
        emit(IllnessDetailsError(failure.message));
      },
      (illness) {
        emit(IllnessDetailsLoaded(illness));
      },
    );
  }
}
