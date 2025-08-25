// reception_state.dart
part of 'reception_bloc.dart';

abstract class ReceptionState {}

class ReceptionInitial extends ReceptionState {}

class ReceptionLoading extends ReceptionState {}

class ReceptionLoaded extends ReceptionState {
  final List<ReceptionClientEntity> receptions;
  ReceptionLoaded(this.receptions);
}

// Reception list uchun alohida state lar
class ReceptionListLoading extends ReceptionState {}

class ReceptionListLoaded extends ReceptionState {
  final List<ReceptionListEntity> receptionList;
  ReceptionListLoaded(this.receptionList);
}

// Reception info loading holatlari
class ReceptionInfoLoading extends ReceptionState {
  final String receptionId;
  ReceptionInfoLoading(this.receptionId);
}

class ReceptionInfoLoaded extends ReceptionState {
  final String receptionId;
  final List<ReceptionInfoEntity> info;
  ReceptionInfoLoaded(this.receptionId, this.info);
}

class ReceptionError extends ReceptionState {
  final String message;
  final String? errorType; // Qaysi action da error bo'lganini aniqlash uchun
  ReceptionError(this.message, {this.errorType});
}

// Composite state - multiple ma'lumotlarni birga saqlash uchun
class ReceptionCombinedState extends ReceptionState {
  final List<ReceptionListEntity>? receptionList;
  final Map<String, List<ReceptionInfoEntity>> receptionInfos;
  final Set<String> loadingInfoIds;
  final String? error;

  ReceptionCombinedState({
    this.receptionList,
    this.receptionInfos = const {},
    this.loadingInfoIds = const {},
    this.error,
  });

  ReceptionCombinedState copyWith({
    List<ReceptionListEntity>? receptionList,
    Map<String, List<ReceptionInfoEntity>>? receptionInfos,
    Set<String>? loadingInfoIds,
    String? error,
  }) {
    return ReceptionCombinedState(
      receptionList: receptionList ?? this.receptionList,
      receptionInfos: receptionInfos ?? this.receptionInfos,
      loadingInfoIds: loadingInfoIds ?? this.loadingInfoIds,
      error: error ?? this.error,
    );
  }
}