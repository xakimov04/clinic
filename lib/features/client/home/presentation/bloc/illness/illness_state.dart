part of 'illness_bloc.dart';

abstract class IllnessState extends Equatable {
  const IllnessState();

  @override
  List<Object> get props => [];
}

class IllnessInitial extends IllnessState {}

class IllnessLoading extends IllnessState {}

class IllnessLoaded extends IllnessState {
  final List<IllnessEntities> illnesses;

  const IllnessLoaded(this.illnesses);

  @override
  List<Object> get props => [illnesses];
}

class IllnessEmpty extends IllnessState {
  final String message;

  const IllnessEmpty(this.message);

  @override
  List<Object> get props => [message];
}

class IllnessError extends IllnessState {
  final String message;

  const IllnessError(this.message);

  @override
  List<Object> get props => [message];
}

class IllnessDetailsLoading extends IllnessState {}

class IllnessDetailsLoaded extends IllnessState {
  final IllnessEntities illness;

  const IllnessDetailsLoaded(this.illness);

  @override
  List<Object> get props => [illness];
}

class IllnessDetailsError extends IllnessState {
  final String message;

  const IllnessDetailsError(this.message);

  @override
  List<Object> get props => [message];
}
