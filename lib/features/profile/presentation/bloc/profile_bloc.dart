import 'package:clinic/core/di/export/di_export.dart';
import 'package:clinic/core/di/modules/receptions_module.dart';
import 'package:clinic/core/local/storage_keys.dart';
import 'package:clinic/features/profile/domain/entities/profile_entities.dart';
import 'package:clinic/features/profile/domain/usecase/get_user_profile.dart';
import 'package:clinic/features/profile/domain/usecase/logout.dart';
import 'package:clinic/features/profile/domain/usecase/update_profile.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:clinic/core/usecase/usecase.dart';
part 'profile_event.dart';
part 'profile_state.dart';

class ProfileBloc extends Bloc<ProfileEvent, ProfileState> {
  final GetUserProfile getUserProfile;
  final UpdateProfile updateProfile;

  final Logout logout;

  ProfileBloc({
    required this.getUserProfile,
    required this.updateProfile,
    required this.logout,
  }) : super(ProfileInitial()) {
    on<GetProfileEvent>(_onGetProfile);
    on<UpdateProfileEvent>(_onUpdateProfile);
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
      (user) {
        if (user.phoneNumber!.isEmpty) {
          sl<LocalStorageService>().setBool(StorageKeys.isprofileFill, true);
        } else {
          sl<LocalStorageService>().setBool(StorageKeys.isprofileFill, false);
        }
        return ProfileLoaded(user);
      },
    ));
  }

  Future<void> _onUpdateProfile(
    UpdateProfileEvent event,
    Emitter<ProfileState> emit,
  ) async {
    emit(ProfileUpdating());
    final result = await updateProfile(event.request);

    result.fold(
      (failure) => emit(ProfileUpdateError(failure.message)),
      (updatedUser) {
        emit(ProfileUpdateSuccess(updatedUser));
        emit(ProfileLoaded(updatedUser));
      },
    );
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
