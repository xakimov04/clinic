part of 'reception_bloc.dart';

abstract class ReceptionState {}

class ReceptionInitial extends ReceptionState {}

class ReceptionLoading extends ReceptionState {}

class ReceptionLoaded extends ReceptionState {
  final List<ReceptionClientEntity> receptions;
  ReceptionLoaded(this.receptions);
}

class ReceptionInfoLoaded extends ReceptionState {
  final List<ReceptionInfoEntity> info;
  ReceptionInfoLoaded(this.info);
}

class ReceptionListLoaded extends ReceptionState {
  final List<ReceptionListEntity> receptionList;
  ReceptionListLoaded(this.receptionList);
}

class ReceptionError extends ReceptionState {
  final String message;
  ReceptionError(this.message);
}
