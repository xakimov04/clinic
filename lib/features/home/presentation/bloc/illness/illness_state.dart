part of 'illness_bloc.dart';

sealed class IllnessState extends Equatable {
  const IllnessState();

  @override
  List<Object> get props => [];
}

final class IllnessInitial extends IllnessState {}

final class IllnessLoading extends IllnessState {}

final class IllnessLoaded extends IllnessState {
  final List<IllnessEntities> illnesses;

  const IllnessLoaded(this.illnesses);

  @override
  List<Object> get props => [illnesses];
}

final class IllnessError extends IllnessState {
  final String message;

  const IllnessError(this.message);

  @override
  List<Object> get props => [message];
}

final class IllnessEmpty extends IllnessState {
  final String message;

  const IllnessEmpty(this.message);

  @override
  List<Object> get props => [message];
}
