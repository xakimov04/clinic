part of 'doctor_bloc.dart';

sealed class DoctorEvent extends Equatable {
  const DoctorEvent();

  @override
  List<Object> get props => [];
}

final class GetDoctorEvent extends DoctorEvent {
  const GetDoctorEvent();

  @override
  List<Object> get props => [];
}