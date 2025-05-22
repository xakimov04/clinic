import 'package:clinic/features/profile/domain/entities/profile_entities.dart';
import 'package:clinic/features/profile/domain/usecase/get_user_profile.dart';
import 'package:clinic/features/profile/domain/usecase/logout.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:clinic/core/usecase/usecase.dart';
part 'profile_event.dart';
part 'profile_state.dart';

class ProfileBloc extends Bloc<ProfileEvent, ProfileState> {
  final GetUserProfile getUserProfile;
  final Logout logout;

  ProfileBloc({
    required this.getUserProfile,
    required this.logout,
  }) : super(ProfileInitial()) {
    on<GetProfileEvent>(_onGetProfile);
    on<LogoutEvent>(_onLogout);
  }

  Future<void> _onGetProfile(
    GetProfileEvent event,
    Emitter<ProfileState> emit,
  ) async {
    emit(ProfileLoading());
    final result = await getUserProfile(NoParams());
    emit(result.fold(
      (failure) => ProfileError(failure.message),
      (user) => ProfileLoaded(user),
    ));
  }

  Future<void> _onLogout(
    LogoutEvent event,
    Emitter<ProfileState> emit,
  ) async {
    emit(LogoutLoading());
    final result = await logout(NoParams());
    emit(result.fold(
      (failure) => LogoutError(failure.message),
      (_) => LogoutSuccess(),
    ));
  }
}