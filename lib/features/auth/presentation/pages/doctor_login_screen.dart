import 'package:clinic/core/constants/color_constants.dart';
import 'package:clinic/core/di/export/di_export.dart';
import 'package:clinic/core/di/injection_container.dart';
import 'package:clinic/core/extension/spacing_extension.dart';
import 'package:clinic/core/local/storage_keys.dart';
import 'package:clinic/core/role_management/role_manager.dart';
import 'package:clinic/core/routes/route_paths.dart';
import 'package:clinic/core/ui/widgets/buttons/custom_button.dart';
import 'package:clinic/core/ui/widgets/inputs/custom_text_feild.dart';
import 'package:clinic/core/ui/widgets/snackbars/custom_snackbar.dart';
import 'package:clinic/features/auth/domain/entities/doctor_login_request_entity.dart';
import 'package:clinic/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:clinic/features/auth/presentation/bloc/auth_event.dart';
import 'package:clinic/features/auth/presentation/bloc/auth_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

class DoctorLoginScreen extends StatefulWidget {
  const DoctorLoginScreen({super.key});

  @override
  State<DoctorLoginScreen> createState() => _DoctorLoginScreenState();
}

class _DoctorLoginScreenState extends State<DoctorLoginScreen>
    with SingleTickerProviderStateMixin {
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  final _usernameFocusNode = FocusNode();
  final _passwordFocusNode = FocusNode();

  // Animations
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _setupAnimations();
  }

  void _setupAnimations() {
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.0, 0.8, curve: Curves.easeOut),
      ),
    );

    _slideAnimation = Tween<double>(begin: 50.0, end: 0.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.2, 1.0, curve: Curves.easeOutCubic),
      ),
    );

    _animationController.forward();
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    _usernameFocusNode.dispose();
    _passwordFocusNode.dispose();
    _animationController.dispose();
    super.dispose();
  }

  String? _validateUsername(String? value) {
    if (value == null || value.isEmpty) {
      return 'Введите имя пользователя';
    }
    if (value.length < 3) {
      return 'Имя пользователя должно содержать минимум 3 символа';
    }
    return null;
  }

  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Введите пароль';
    }
    if (value.length < 6) {
      return 'Пароль должен содержать минимум 6 символов';
    }
    return null;
  }

  void _handleLogin() {
    if (_formKey.currentState!.validate()) {
      FocusScope.of(context).unfocus();

      final request = DoctorLoginRequest(
        username: _usernameController.text.trim(),
        password: _passwordController.text,
      );

      context.read<AuthBloc>().add(DoctorLoginEvent(request));
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is DoctorLoginAuthenticated) {
          CustomSnackbar.showSuccess(
            context: context,
            message: "Добро пожаловать, доктор!",
          );
          sl<LocalStorageService>().setString(StorageKeys.userRole, UserRole.doctor.name);
          context.go(RoutePaths.doctorHome);
        } else if (state is DoctorLoginFailure) {
          CustomSnackbar.showError(
            context: context,
            message: state.message,
          );
          // Паролни очистка qilish
          _passwordController.clear();
          _usernameFocusNode.requestFocus();
        }
      },
      child: Scaffold(
        backgroundColor: ColorConstants.backgroundColor,
        body: Stack(
          children: [
            _buildBackgroundElements(),

            // Main content
            SafeArea(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24.0),
                child: AnimatedBuilder(
                  animation: _animationController,
                  builder: (context, child) {
                    return FadeTransition(
                      opacity: _fadeAnimation,
                      child: Transform.translate(
                        offset: Offset(0, _slideAnimation.value),
                        child: Form(
                          key: _formKey,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              60.h,
                              _buildHeader(),
                              50.h,
                              _buildLoginForm(),
                              20.h,
                              _buildBackToPatientLogin(),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBackgroundElements() {
    return Stack(
      children: [
        // Top right circle
        Positioned(
          top: -100,
          right: -80,
          child: Container(
            width: 200,
            height: 200,
            decoration: BoxDecoration(
              color: ColorConstants.primaryColor.withOpacity(0.15),
              shape: BoxShape.circle,
            ),
          ),
        ),
        // Bottom left circle
        Positioned(
          bottom: -80,
          left: -40,
          child: Container(
            width: 180,
            height: 180,
            decoration: BoxDecoration(
              color: ColorConstants.accentGreen.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
          ),
        ),
        // Medical cross pattern
        Positioned(
          top: 100,
          left: 30,
          child: Icon(
            Icons.medical_services_outlined,
            size: 20,
            color: ColorConstants.primaryColor.withOpacity(0.1),
          ),
        ),
        Positioned(
          bottom: 200,
          right: 50,
          child: Icon(
            Icons.local_hospital_outlined,
            size: 24,
            color: ColorConstants.primaryColor.withOpacity(0.08),
          ),
        ),
      ],
    );
  }

  Widget _buildHeader() {
    return Column(
      children: [
        // Doctor logo
        Container(
          width: 100,
          height: 100,
          decoration: BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: ColorConstants.shadowColor.withOpacity(0.05),
                blurRadius: 10,
                spreadRadius: 1,
              ),
            ],
          ),
          child: Container(
            margin: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  ColorConstants.primaryColor,
                  ColorConstants.primaryColor.withOpacity(0.7),
                ],
              ),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.medical_services_rounded,
              size: 32,
              color: Colors.white,
            ),
          ),
        ),
        20.h,

        // Title
        const Text(
          'Вход для врачей',
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: ColorConstants.textColor,
          ),
        ),
        8.h,

        // Subtitle
        Text(
          'Панель управления медицинского персонала',
          style: TextStyle(
            fontSize: 16,
            color: ColorConstants.secondaryTextColor,
            fontWeight: FontWeight.w500,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildLoginForm() {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) {
        final isLoading = state is DoctorLoginLoading;

        return Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Username field
              _buildFieldLabel('Имя пользователя'),
              8.h,
              CustomTextField(
                controller: _usernameController,
                focusNode: _usernameFocusNode,
                hint: 'Введите ваш логин',
                prefixIcon: const Icon(
                  Icons.person_outline_rounded,
                  color: ColorConstants.primaryColor,
                ),
                keyboardType: TextInputType.text,
                textInputAction: TextInputAction.next,
                validator: _validateUsername,
                enabled: !isLoading,
                onSubmitted: (_) => _passwordFocusNode.requestFocus(),
                autocorrect: false,
                enableSuggestions: false,
              ),
              20.h,

              // Password field
              _buildFieldLabel('Пароль'),
              8.h,
              CustomTextField(
                controller: _passwordController,
                focusNode: _passwordFocusNode,
                hint: 'Введите ваш пароль',
                obscureText: true,
                prefixIcon: const Icon(
                  Icons.lock_outline_rounded,
                  color: ColorConstants.primaryColor,
                ),
                keyboardType: TextInputType.visiblePassword,
                textInputAction: TextInputAction.done,
                validator: _validatePassword,
                enabled: !isLoading,
                onSubmitted: (_) => _handleLogin(),
                toggleObscureText: true,
                autocorrect: false,
                enableSuggestions: false,
              ),
              30.h,

              // Login button
              CustomButton(
                text: 'Войти в систему',
                onPressed: _handleLogin,
                isLoading: isLoading,
                fullWidth: true,
                height: 45,
                backgroundColor: ColorConstants.primaryColor,
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildFieldLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(left: 4),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: ColorConstants.textColor,
        ),
      ),
    );
  }

  Widget _buildBackToPatientLogin() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 1),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.8),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: ColorConstants.borderColor.withOpacity(0.5),
          width: 1,
        ),
      ),
      child: GestureDetector(
        onTap: () => context.go('/auth'),
        child: Center(
          child: Text(
            'Вернуться к входу для пациентов',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ),
    );
  }
}
