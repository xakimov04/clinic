part of 'illness_bloc.dart';

sealed class IllnessEvent extends Equatable {
  const IllnessEvent();

  @override
  List<Object> get props => [];
}

final class IllnessGetAll extends IllnessEvent {
  const IllnessGetAll();

  @override
  List<Object> get props => [];
}

final class IllnessGetAllNotLoading extends IllnessEvent {
  const IllnessGetAllNotLoading();

  @override
  List<Object> get props => [];
}

final class IllnessGetDetails extends IllnessEvent {
  final int id;

  const IllnessGetDetails(this.id);

  @override
  List<Object> get props => [id];
}
