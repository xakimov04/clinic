import 'package:clinic/core/local/storage_keys.dart';
import 'package:clinic/di/export/di_export.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:clinic/features/auth/domain/usecases/login_with_vk.dart';
import 'package:clinic/features/auth/presentation/bloc/auth_event.dart';
import 'package:clinic/features/auth/presentation/bloc/auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final LoginWithVK loginWithVKUseCase;
  final AuthRepository authRepository;
  final LocalStorageService localStorageService;

  AuthBloc({
    required this.localStorageService,
    required this.loginWithVKUseCase,
    required this.authRepository,
  }) : super(AuthInitial()) {
    on<LoginWithVKEvent>(_onLoginWithVK);
  }

  Future<void> _onLoginWithVK(
    LoginWithVKEvent event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());

    final params = event.authRequestEntities;

    final result = await loginWithVKUseCase(params);

    result.fold(
      (failure) => emit(AuthFailure(failure.message)),
      (data) {
        localStorageService.setString(StorageKeys.accesToken, data.accessToken);
        localStorageService.setBool(StorageKeys.isLoggedIn, true);
        localStorageService.setString(
            StorageKeys.refreshToken, data.refreshToken);
        localStorageService.setString(
            StorageKeys.userId, data.user.id.toString());
        emit(AuthAuthenticated(data));
      },
    );
  }
}
