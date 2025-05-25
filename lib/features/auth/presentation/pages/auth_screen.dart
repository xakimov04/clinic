import 'package:clinic/core/constants/color_constants.dart';
import 'package:clinic/core/extension/spacing_extension.dart';
import 'package:clinic/core/ui/widgets/buttons/custom_button.dart';
import 'package:clinic/core/ui/widgets/inputs/custom_text_feild.dart';
import 'package:clinic/core/ui/widgets/snackbars/custom_snackbar.dart';
import 'package:clinic/features/auth/domain/entities/auth_request_entities.dart';
import 'package:clinic/features/auth/domain/entities/send_otp_entity.dart';
import 'package:clinic/features/auth/domain/entities/verify_otp_entity.dart';
import 'package:clinic/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:clinic/features/auth/presentation/bloc/auth_event.dart';
import 'package:clinic/features/auth/presentation/bloc/auth_state.dart';
import 'package:clinic/features/auth/presentation/widgets/otp_input_widget.dart';
import 'package:clinic/features/auth/presentation/widgets/uzbek_phone_input_formatter.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
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
  final _phoneController = TextEditingController(text: "+998");
  final _phoneFormKey = GlobalKey<FormState>();
  final GlobalKey<OtpInputWidgetState> _otpKey =
      GlobalKey<OtpInputWidgetState>();

  bool _codeSent = false;

  // Animatsiya uchun
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _setupAnimations();
  }

  void _setupAnimations() {
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _phoneController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  String? _validatePhone(String? value) {
    if (value == null || value.isEmpty) {
      return 'Введите номер телефона';
    }

    final digitsCount = value.replaceAll(RegExp(r'\D'), '').length;

    // O'zbekiston uchun 12 raqam (998 + 9 raqam)
    if (digitsCount < 12) {
      return 'Введите полный номер телефона';
    }

    return null;
  }

  void _requestCode() {
    if (_phoneFormKey.currentState!.validate()) {
      // Raw telefon raqamini olish (faqat raqamlar)
      final rawPhone = _phoneController.text.replaceAll(RegExp(r'\D'), '');

      // Send OTP event
      context.read<AuthBloc>().add(
            SendOtpEvent(
              SendOtpEntity(phoneNumber: "+$rawPhone"),
            ),
          );
    }
  }

  void _verifyCode(String code) {
    if (code.length == 6) {
      // Raw telefon raqamini olish
      final rawPhone = _phoneController.text.replaceAll(RegExp(r'\D'), '');

      // Verify OTP event
      context.read<AuthBloc>().add(
            VerifyOtpEvent(
              VerifyOtpEntity(
                phoneNumber: "+$rawPhone",
                otp: code,
              ),
            ),
          );
    }
  }

  void _onVkAuth(AuthData data) {
    final requestData = AuthRequest(
      accessToken: data.token,
      vkId: data.userID,
      firstName: data.userData.firstName,
      lastName: data.userData.lastName,
    );

    context.read<AuthBloc>().add(
          LoginWithVKEvent(requestData),
        );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is AuthAuthenticated) {
          CustomSnackbar.showSuccess(
            context: context,
            message: "Успешная авторизация!",
          );
          context.go('/home');
        } else if (state is OtpVerified) {
          CustomSnackbar.showSuccess(
            context: context,
            message: "SMS код подтвержден!",
          );

          context.go('/home');
        } else if (state is OtpSent) {
          setState(() {
            _codeSent = true;
          });
          CustomSnackbar.showSuccess(
            context: context,
            message: state.message,
          );
        } else if (state is AuthFailure) {
          CustomSnackbar.showError(
            context: context,
            message: state.message,
          );
        } else if (state is OtpFailure) {
          CustomSnackbar.showError(
            context: context,
            message: state.message,
          );
          // OTP ni tozalash
          _otpKey.currentState?.clear();
        }
      },
      child: Scaffold(
        body: Stack(
          children: [
            // Fon elementlari
            _buildBackgroundElements(),

            // Asosiy kontent
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
                        _buildCompactHeader(theme),
                        const Spacer(flex: 1),

                        // Form content
                        BlocBuilder<AuthBloc, AuthState>(
                          builder: (context, state) {
                            return AnimatedSwitcher(
                              duration: const Duration(milliseconds: 300),
                              child: _codeSent
                                  ? _buildCodeForm(theme, state)
                                  : _buildPhoneForm(theme, state),
                            );
                          },
                        ),

                        20.h,

                        // VK authorization va Doctor login (faqat telefon kiritish paytida)
                        if (!_codeSent) ...[
                          _buildDivider(),
                          16.h,
                          _buildSocialAuth(),
                          16.h,
                          _buildDoctorLoginButton(),
                        ],

                        const Spacer(flex: 1),
                        _buildTermsText(),
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

  Widget _buildBackgroundElements() {
    return Stack(
      children: [
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
      ],
    );
  }

  Widget _buildCompactHeader(ThemeData theme) {
    return Column(
      children: [
        // Logo
        Container(
          width: 80,
          height: 80,
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

        // Klinika nomi
        Text(
          'МедЦентр',
          style: theme.textTheme.headlineMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: ColorConstants.primaryColor,
          ),
        ),
        4.h,

        // Subtitle
        Text(
          'Вход в личный кабинет',
          style: theme.textTheme.bodyMedium?.copyWith(
            color: ColorConstants.secondaryTextColor,
          ),
        ),
      ],
    );
  }

  Widget _buildPhoneForm(ThemeData theme, AuthState state) {
    final isLoading = state is OtpSending;

    return Container(
      key: const ValueKey('phone_form'),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: 16.circular,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Label
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

          // Phone input
          CustomTextField(
            controller: _phoneController,
            hint: '(XX) XXX-XX-XX',
            keyboardType: TextInputType.phone,
            prefixIcon: const Icon(
              Icons.phone_outlined,
              color: ColorConstants.primaryColor,
            ),
            inputFormatters: [
              UzbekPhoneInputFormatter(),
            ],
            validator: _validatePhone,
            onSubmitted: (_) => _requestCode(),
            enabled: !isLoading,
          ),
          16.h,

          // Send OTP button
          CustomButton(
            text: 'Получить код',
            onPressed: _requestCode,
            isLoading: isLoading,
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

  Widget _buildCodeForm(ThemeData theme, AuthState state) {
    final isLoading = state is OtpVerifying;
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
          // Header with phone number
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
          24.h,

          // OTP Input Widget
          Center(
            child: OtpInputWidget(
              key: _otpKey,
              onCompleted: _verifyCode,
              onChanged: (value) {
                setState(() {});
              },
              isLoading: isLoading,
            ),
          ),
          24.h,

          // Change number button
          Center(
            child: TextButton(
              onPressed: isLoading
                  ? null
                  : () {
                      setState(() {
                        _codeSent = false;
                      });
                    },
              child: Text(
                'Изменить номер',
                style: TextStyle(
                  color: isLoading
                      ? ColorConstants.secondaryTextColor.withOpacity(0.5)
                      : ColorConstants.secondaryTextColor,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),

          // Resend OTP option
          if (!isLoading) ...[
            Center(
              child: TextButton(
                onPressed: () {
                  _requestCode();
                },
                child: Text(
                  'Отправить код повторно',
                  style: TextStyle(
                    color: ColorConstants.primaryColor,
                    fontWeight: FontWeight.w500,
                    fontSize: 14,
                  ),
                ),
              ),
            ),
          ],
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
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) {
        final isLoading = state is AuthLoading;

        return AbsorbPointer(
          absorbing: isLoading,
          child: Opacity(
            opacity: isLoading ? 0.6 : 1.0,
            child: SizedBox(
              width: double.infinity,
              child: OAuthWidget(
                key: GlobalKey(),
                oAuths: const {OAuth.vk},
                authParams: UIAuthParamsBuilder()
                    .withScopes(const {'email', 'phone'}).build(),
                onAuth: (provider, data) {
                  _onVkAuth(data);
                },
                onError: (provider, error) {
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
            ),
          ),
        );
      },
    );
  }

  Widget _buildDoctorLoginButton() {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: ColorConstants.hintColor.withOpacity(0.5),
          width: 1,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => context.go('/doctor-login'),
          borderRadius: BorderRadius.circular(10),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  CupertinoIcons.person_crop_circle,
                ),
                8.w,
                Text(
                  'Вход для врачей',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTermsText() {
    return Text(
      'Продолжая, вы соглашаетесь с условиями использования',
      style: TextStyle(
        color: ColorConstants.secondaryTextColor,
        fontSize: 12,
      ),
      textAlign: TextAlign.center,
    );
  }
}
