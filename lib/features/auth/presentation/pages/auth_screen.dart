import 'package:clinic/core/constants/color_constants.dart';
import 'package:clinic/core/extension/spacing_extension.dart';
import 'package:clinic/core/ui/widgets/buttons/custom_button.dart';
import 'package:clinic/core/ui/widgets/inputs/custom_text_feild.dart';
import 'package:clinic/core/ui/widgets/snackbars/custom_snackbar.dart';
import 'package:clinic/features/auth/domain/entities/auth_request_entities.dart';
import 'package:clinic/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:clinic/features/auth/presentation/bloc/auth_event.dart';
import 'package:clinic/features/auth/presentation/bloc/auth_state.dart';
import 'package:clinic/features/auth/presentation/widgets/input_formatter.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:vkid_flutter_sdk/library_vkid.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen>
    with SingleTickerProviderStateMixin {
  final _phoneController = TextEditingController(text: "+7");
  final _codeController = TextEditingController();
  final _codeFocusNode = FocusNode();
  final _phoneFormKey = GlobalKey<FormState>();
  bool _isLoading = false;
  bool _codeSent = false;
  final bool _isObscureText = true;

  // Анимация для плавных переходов
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    _animationController.forward();
  }

  String? _validatePhone(String? value) {
    if (value == null || value.isEmpty) {
      return 'Введите номер телефона';
    }

    // Проверка, что номер содержит достаточно цифр
    final digitsCount = value.replaceAll(RegExp(r'\D'), '').length;

    // В России мобильные номера должны содержать 11 цифр (с кодом страны)
    if (digitsCount < 11) {
      return 'Введите полный номер телефона';
    }

    return null;
  }

  void _requestCode() {
    if (_phoneFormKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      // Имитация отправки кода (в реальном приложении здесь будет API запрос)
      Future.delayed(const Duration(seconds: 1), () {
        setState(() {
          _isLoading = false;
          _codeSent = true;
        });
        _codeFocusNode.requestFocus();
        CustomSnackbar.showSuccess(
          context: context,
          message: 'Код отправлен на номер телефона',
        );
      });
    }
  }

  //

  void _onVkAuth(AuthData data) {
    final requestData = AuthRequest(
      accessToken: data.token,
      vkId: data.userID,
      firstName: data.userData.firstName,
      lastName: data.userData.lastName,
    );
    // Dispatch event to the auth bloc
    context.read<AuthBloc>().add(
          LoginWithVKEvent(requestData),
        );
  }

  @override
  void dispose() {
    _phoneController.dispose();
    _codeController.dispose();
    _codeFocusNode.dispose();
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is AuthAuthenticated) {
          CustomSnackbar.showSuccess(
            context: context,
            message: "Успешная авторизация",
          );
          // Navigate to home screen
          context.go('/home');
        } else if (state is AuthFailure) {
          CustomSnackbar.showError(
            context: context,
            message: state.message,
          );
        }
      },
      child: Scaffold(
        backgroundColor: ColorConstants.backgroundColor,
        body: Stack(
          children: [
            // Фоновые элементы дизайна
            Positioned(
              top: -100,
              right: -80,
              child: Container(
                width: 200,
                height: 200,
                decoration: BoxDecoration(
                  color: ColorConstants.primaryColor.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
              ),
            ),
            Positioned(
              bottom: -80,
              left: -40,
              child: Container(
                width: 180,
                height: 180,
                decoration: BoxDecoration(
                  color: ColorConstants.accentGreen.withOpacity(0.08),
                  shape: BoxShape.circle,
                ),
              ),
            ),

            // Основной контент
            SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Form(
                  key: _phoneFormKey,
                  child: FadeTransition(
                    opacity: _fadeAnimation,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        const Spacer(flex: 1),

                        // Логотип и название
                        _buildCompactHeader(theme),

                        const Spacer(flex: 1),

                        // Форма авторизации
                        AnimatedSwitcher(
                          duration: const Duration(milliseconds: 300),
                          child: _codeSent
                              ? _buildCodeForm(theme)
                              : _buildPhoneForm(theme),
                        ),

                        20.h,

                        // Разделитель и VK авторизация
                        if (!_codeSent) ...[
                          _buildDivider(),
                          16.h,
                          _buildSocialAuth(),
                        ],

                        const Spacer(flex: 1),

                        // Условия использования (небольшой текст)
                        Text(
                          'Продолжая, вы соглашаетесь с условиями использования',
                          style: TextStyle(
                            color: ColorConstants.secondaryTextColor,
                            fontSize: 12,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCompactHeader(ThemeData theme) {
    return Column(
      children: [
        // Логотип
        Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: ColorConstants.shadowColor.withOpacity(0.2),
                blurRadius: 10,
                spreadRadius: 2,
              ),
            ],
          ),
          child: Container(
            margin: const EdgeInsets.all(15),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  ColorConstants.primaryColor,
                  ColorConstants.primaryColor.withOpacity(0.8),
                ],
              ),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.local_hospital_rounded,
              size: 30,
              color: Colors.white,
            ),
          ),
        ),
        12.h,

        // Название клиники
        Text(
          'МедЦентр',
          style: theme.textTheme.headlineMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: ColorConstants.primaryColor,
          ),
        ),
        4.h,

        // Подзаголовок
        Text(
          'Вход в личный кабинет',
          style: theme.textTheme.bodyMedium?.copyWith(
            color: ColorConstants.secondaryTextColor,
          ),
        ),
      ],
    );
  }

  Widget _buildPhoneForm(ThemeData theme) {
    return Container(
      key: const ValueKey('phone_form'),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: 16.circular,
        boxShadow: [
          BoxShadow(
            color: ColorConstants.shadowColor.withOpacity(0.1),
            blurRadius: 8,
            spreadRadius: 0,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Текст с описанием
          Padding(
            padding: const EdgeInsets.only(left: 4, bottom: 8),
            child: Text(
              'Номер телефона',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: ColorConstants.textColor,
              ),
            ),
          ),

          // Поле для ввода номера
          CustomTextField(
            controller: _phoneController,
            hint: '(000) 000-00-00',
            keyboardType: TextInputType.phone,
            prefixIcon: const Icon(
              Icons.phone_outlined,
              color: ColorConstants.primaryColor,
            ),
            inputFormatters: [
              RussianPhoneInputFormatter(),
            ],
            validator: _validatePhone,
            onSubmitted: (_) => _requestCode(),
          ),
          16.h,

          // Кнопка для получения кода
          CustomButton(
            text: 'Получить код',
            onPressed: _requestCode,
            isLoading: _isLoading,
            fullWidth: true,
            height: 50,
            backgroundColor: ColorConstants.primaryColor,
            boxShadow: BoxShadow(
              color: ColorConstants.primaryColor.withOpacity(0.3),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCodeForm(ThemeData theme) {
    // Получаем форматированный номер для отображения
    final displayPhone = _phoneController.text;

    return Container(
      key: const ValueKey('code_form'),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: 16.circular,
        boxShadow: [
          BoxShadow(
            color: ColorConstants.shadowColor.withOpacity(0.1),
            blurRadius: 8,
            spreadRadius: 0,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Заголовок с указанием номера
          Center(
            child: RichText(
              textAlign: TextAlign.center,
              text: TextSpan(
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: ColorConstants.textColor,
                ),
                children: [
                  const TextSpan(text: 'Введите код из СМС на номер\n'),
                  TextSpan(
                    text: displayPhone,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),
          20.h,

          // Поле для ввода кода
          Padding(
            padding: const EdgeInsets.only(left: 4, bottom: 8),
            child: Text(
              'Код из СМС',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: ColorConstants.textColor,
              ),
            ),
          ),

          // Поле для ввода кода
          CustomTextField(
            controller: _codeController,
            focusNode: _codeFocusNode,
            hint: '••••••',
            keyboardType: TextInputType.number,
            textAlign: TextAlign.center,
            obscureText: _isObscureText,
            prefixIcon: const Icon(
              Icons.lock_outline,
              color: ColorConstants.primaryColor,
            ),
            maxLength: 6,
            toggleObscureText: true,
            inputFormatters: [
              FilteringTextInputFormatter.digitsOnly,
              LengthLimitingTextInputFormatter(6),
            ],
            onSubmitted: (_) {},
          ),
          16.h,

          // Кнопка входа
          CustomButton(
            text: 'Войти',
            onPressed: () {},
            isLoading: _isLoading,
            fullWidth: true,
            height: 50,
            backgroundColor: ColorConstants.primaryColor,
            boxShadow: BoxShadow(
              color: ColorConstants.primaryColor.withOpacity(0.3),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ),
          12.h,

          // Кнопка "Изменить номер"
          Center(
            child: TextButton(
              onPressed: () {
                setState(() {
                  _codeSent = false;
                  _codeController.clear();
                });
              },
              child: Text(
                'Изменить номер',
                style: TextStyle(
                  color: ColorConstants.secondaryTextColor,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDivider() {
    return Row(
      children: [
        const Expanded(child: Divider(thickness: 1)),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Text(
            'или',
            style: TextStyle(
              color: ColorConstants.secondaryTextColor,
              fontSize: 14,
            ),
          ),
        ),
        const Expanded(child: Divider(thickness: 1)),
      ],
    );
  }

  Widget _buildSocialAuth() {
    return SizedBox(
      width: double.infinity,
      child: OAuthWidget(
        key: GlobalKey(),
        oAuths: const {
          OAuth.vk,
        },
        authParams:
            UIAuthParamsBuilder().withScopes(const {'email', 'phone'}).build(),
        onAuth: (provider, data) {
          _onVkAuth(data);
        },
        onError: (provider, error) {
          setState(() {});
          CustomSnackbar.showError(
            context: context,
            message: 'Ошибка авторизации через ВКонтакте',
          );
        },
        buttonConfig: const OAuthButtonConfiguration(
          cornersStyle: OneTapCornersRounded(),
        ),
        theme: OAuthWidgetTheme.light,
      ),
    );
  }
}
