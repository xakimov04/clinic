import 'package:clinic/core/local/storage_keys.dart';
import 'package:clinic/core/di/export/di_export.dart';
import 'package:clinic/core/role_management/role_manager.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:clinic/features/auth/presentation/bloc/auth_event.dart';
import 'package:clinic/features/auth/presentation/bloc/auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final LoginWithVK loginWithVKUseCase;
  final SendOtp sendOtpUseCase;
  final VerifyOtp verifyOtpUseCase;
  final AuthRepository authRepository;
  final LocalStorageService localStorageService;
  final DoctorLogin doctorLoginUseCase;

  AuthBloc({
    required this.localStorageService,
    required this.loginWithVKUseCase,
    required this.sendOtpUseCase,
    required this.verifyOtpUseCase,
    required this.authRepository,
    required this.doctorLoginUseCase,
  }) : super(AuthInitial()) {
    on<LoginWithVKEvent>(_onLoginWithVK);
    on<SendOtpEvent>(_onSendOtp);
    on<VerifyOtpEvent>(_onVerifyOtp);
    on<DoctorLoginEvent>(_onDoctorLogin);
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
        localStorageService.setString(
            StorageKeys.userRole, UserRole.client.name);
        emit(AuthAuthenticated(data));
      },
    );
  }

  Future<void> _onSendOtp(
    SendOtpEvent event,
    Emitter<AuthState> emit,
  ) async {
    emit(OtpSending());

    final result = await sendOtpUseCase(event.sendOtpEntity);

    result.fold(
      (failure) => emit(OtpFailure(failure.message)),
      (message) => emit(OtpSent(message)),
    );
  }

  Future<void> _onVerifyOtp(
    VerifyOtpEvent event,
    Emitter<AuthState> emit,
  ) async {
    emit(OtpVerifying());

    final result = await verifyOtpUseCase(event.verifyOtpEntity);

    result.fold(
      (failure) => emit(OtpFailure(failure.message)),
      (otpResponse) {
        // Token ni saqlash
        localStorageService.setString(
            StorageKeys.accesToken, otpResponse.token);
        localStorageService.setBool(StorageKeys.isLoggedIn, true);
        localStorageService.setString(
            StorageKeys.userId, otpResponse.userId.toString());

        emit(OtpVerified(otpResponse));
      },
    );
  }

  Future<void> _onDoctorLogin(
    DoctorLoginEvent event,
    Emitter<AuthState> emit,
  ) async {
    emit(DoctorLoginLoading());

    final result = await doctorLoginUseCase(event.doctorLoginRequest);

    result.fold(
      (failure) => emit(DoctorLoginFailure(failure.message)),
      (data) {
        localStorageService.setString(StorageKeys.accesToken, data.accessToken);
        localStorageService.setBool(StorageKeys.isLoggedIn, true);
        localStorageService.setString(
            StorageKeys.refreshToken, data.refreshToken);
        localStorageService.setString(
            StorageKeys.userId, data.userId.toString());
        localStorageService.setString(
            StorageKeys.userRole, UserRole.doctor.name);

        emit(DoctorLoginAuthenticated(data));
      },
    );
  }
}
