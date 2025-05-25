part of 'clinics_bloc.dart';

sealed class ClinicsEvent extends Equatable {
  const ClinicsEvent();

  @override
  List<Object> get props => [];
}

final class GetClinicsEvent extends ClinicsEvent {
  const GetClinicsEvent();

  @override
  List<Object> get props => [];
}