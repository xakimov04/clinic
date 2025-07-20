part of 'reception_bloc.dart';

abstract class ReceptionEvent {}

class GetReceptionsClientEvent extends ReceptionEvent {}

class GetReceptionsInfoEvent extends ReceptionEvent {
  final String id;
  GetReceptionsInfoEvent(this.id);
}

class GetReceptionsListEvent extends ReceptionEvent {
  final String id;
  GetReceptionsListEvent(this.id);
}
