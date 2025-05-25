part of 'clinics_bloc.dart';

sealed class ClinicsState extends Equatable {
  const ClinicsState();

  @override
  List<Object> get props => [];
}

final class ClinicsInitial extends ClinicsState {}

final class ClinicsLoading extends ClinicsState {}

final class ClinicsLoaded extends ClinicsState {
  final List<ClinicsEntity> clinics;

  const ClinicsLoaded(this.clinics);

  @override
  List<Object> get props => [clinics];
}

final class ClinicsError extends ClinicsState {
  final String message;

  const ClinicsError(this.message);

  @override
  List<Object> get props => [message];
}

final class ClinicsEmpty extends ClinicsState {
  final String message;

  const ClinicsEmpty(this.message);

  @override
  List<Object> get props => [message];
}

