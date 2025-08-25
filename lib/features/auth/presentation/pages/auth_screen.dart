import 'dart:async';
import 'package:clinic/core/constants/color_constants.dart';
import 'package:clinic/core/extension/spacing_extension.dart';
import 'package:clinic/core/routes/route_paths.dart';
import 'package:clinic/core/ui/widgets/buttons/custom_button.dart';
import 'package:clinic/core/ui/widgets/inputs/custom_text_feild.dart';
import 'package:clinic/core/ui/widgets/snackbars/custom_snackbar.dart';
import 'package:clinic/features/auth/domain/entities/auth_request_entities.dart';
import 'package:clinic/features/auth/domain/entities/send_otp_entity.dart';
import 'package:clinic/features/auth/domain/entities/verify_otp_entity.dart';
import 'package:clinic/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:clinic/features/auth/presentation/bloc/auth_event.dart';
import 'package:clinic/features/auth/presentation/bloc/auth_state.dart';
import 'package:clinic/features/auth/presentation/pages/oauth_screen_mobile.dart';
import 'package:clinic/features/auth/presentation/widgets/input_formatter.dart';
import 'package:clinic/features/auth/presentation/widgets/otp_input_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:go_router/go_router.dart';
import 'package:vk_id/vk_id.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen>
    with SingleTickerProviderStateMixin {
  final _phoneController = TextEditingController(text: "+7");
  final _phoneFormKey = GlobalKey<FormState>();
  final GlobalKey<OtpInputWidgetState> _otpKey =
      GlobalKey<OtpInputWidgetState>();

  bool _codeSent = false;

  // OTP Timer uchun
  Timer? _otpTimer;
  int _remainingSeconds = 60;
  bool _canResendOtp = false;

  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  final _vkidController = VkIDController(clID: 53840926);
  final _redirectUriTextController = TextEditingController();
  Uri? _authorizeUri;
  final _authorizeUriTextController = TextEditingController();
  var _codeVerifier = "";

  final _apiErrNotifier = ValueNotifier<String>("");

  @override
  void initState() {
    super.initState();
    _setupAnimations();
  }

  void _generateAuthorizeLink() {
    final pair = _vkidController.generateAuthorizeLinkWithCodeVerifier(
        redirectUri: _redirectUriTextController.text);
    final uri = pair.value;
    if (uri == null) {
      return;
    }
    _authorizeUri = uri;
    _codeVerifier = pair.key;
    _authorizeUriTextController.text = uri.toString();
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

  void _startOtpTimer() {
    setState(() {
      _remainingSeconds = 60;
      _canResendOtp = false;
    });

    _otpTimer?.cancel();
    _otpTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }

      setState(() {
        if (_remainingSeconds > 0) {
          _remainingSeconds--;
        } else {
          _canResendOtp = true;
          timer.cancel();
        }
      });
    });
  }

  void _stopOtpTimer() {
    _otpTimer?.cancel();
    setState(() {
      _canResendOtp = false;
    });
  }

  String _formatTime(int seconds) {
    final minutes = seconds ~/ 60;
    final remainingSeconds = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${remainingSeconds.toString().padLeft(2, '0')}';
  }

  @override
  void dispose() {
    _phoneController.dispose();
    _animationController.dispose();
    _otpTimer?.cancel();
    super.dispose();
  }

  String? _validatePhone(String? value) {
    if (value == null || value.isEmpty) {
      return 'Введите номер телефона';
    }

    final digitsCount = value.replaceAll(RegExp(r'\D'), '').length;

    if (digitsCount < 11) {
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

  Future<void> _onVkAuth(VkOAuth data) async {
    try {
      final profileRes = await _vkidController.getProfileInfo();
      final profile = profileRes.result;
      if (profile == null) {
        var msg = "Profile info load error";
        final err = profileRes.error?.vkErr;
        if (err != null) {
          msg += ": ${err.error} - ${err.description}";
        }
        _apiErrNotifier.value = msg;
        return;
      }
      final requestData = AuthRequest(
        accessToken: data.accessToken,
        vkId: data.userId,
        firstName: profile.firstName,
        lastName: profile.lastName,
      );
      context.read<AuthBloc>().add(LoginWithVKEvent(requestData));
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is AuthAuthenticated) {
          _stopOtpTimer();
          CustomSnackbar.showSuccess(
            context: context,
            message: "Успешная авторизация!",
          );
          context.go('/home');
        } else if (state is OtpVerified) {
          _stopOtpTimer();
          CustomSnackbar.showSuccess(
            context: context,
            message: "SMS код подтвержден!",
          );

          context.go('/home');
        } else if (state is OtpSent) {
          setState(() {
            _codeSent = true;
          });
          _startOtpTimer();
          CustomSnackbar.showSuccess(
            context: context,
            message: "Смс отправлено на ваш номер телефона",
          );
        } else if (state is AuthFailure) {
          CustomSnackbar.showError(
            context: context,
            message: state.message,
          );
        } else if (state is OtpFailure) {
          CustomSnackbar.showError(
            context: context,
            message: "Не удалось отправить SMS. Пожалуйста, попробуйте позже.",
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

                        if (!_codeSent) ...[
                          _buildDivider(),
                          16.h,
                          _buildSocialAuth(),
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
        GestureDetector(
          onTap: () {
            context.go(RoutePaths.doctorLogin);
          },
          child: Container(
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
              RussianPhoneInputFormatter(),
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

    return SingleChildScrollView(
      child: Container(
        key: const ValueKey('code_form'),
        width: double.infinity,
        constraints: BoxConstraints(
          minHeight: 0,
          maxWidth: MediaQuery.of(context).size.width - 40,
        ),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
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
            const SizedBox(height: 24),

            // OTP Input Widget - Responsive wrapper
            Center(
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  maxWidth: MediaQuery.of(context).size.width * 0.8,
                ),
                child: OtpInputWidget(
                  key: _otpKey,
                  onCompleted: _verifyCode,
                  onChanged: (value) {
                    setState(() {});
                  },
                  isLoading: isLoading,
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Timer va Resend tugmasi
            Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (!_canResendOtp) ...[
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Text(
                        'Отправить код повторно через ${_formatTime(_remainingSeconds)}',
                        style: TextStyle(
                          color: ColorConstants.secondaryTextColor,
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ] else ...[
                    BlocBuilder<AuthBloc, AuthState>(
                      builder: (context, state) {
                        final isResending = state is OtpSending;

                        return TextButton(
                          onPressed: isResending
                              ? null
                              : () {
                                  _requestCode();
                                },
                          child: Wrap(
                            alignment: WrapAlignment.center,
                            crossAxisAlignment: WrapCrossAlignment.center,
                            children: [
                              if (isResending) ...[
                                SizedBox(
                                  width: 16,
                                  height: 16,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                      ColorConstants.primaryColor,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  'Отправляем...',
                                  style: TextStyle(
                                    color: ColorConstants.primaryColor,
                                    fontWeight: FontWeight.w500,
                                    fontSize: 14,
                                  ),
                                ),
                              ] else ...[
                                Icon(
                                  Icons.refresh,
                                  size: 18,
                                  color: ColorConstants.primaryColor,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  'Отправить код повторно',
                                  style: TextStyle(
                                    color: ColorConstants.primaryColor,
                                    fontWeight: FontWeight.w500,
                                    fontSize: 14,
                                  ),
                                ),
                              ],
                            ],
                          ),
                        );
                      },
                    ),
                  ],
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Change number button
            Center(
              child: TextButton(
                onPressed: isLoading
                    ? null
                    : () {
                        _stopOtpTimer();
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
          ],
        ),
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

  Future<void> _onPressedLogInButton() async {
    _apiErrNotifier.value = "";
    if (_authorizeUri == null) {
      _generateAuthorizeLink();
    }
    final uri = _authorizeUri;
    if (uri == null) {
      return;
    }
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) {
          callback(String code, String deviceId) async {
            final authRes = await _vkidController.retrieveOAuthToken(
              authorizationCode: code,
              deviceId: deviceId,
              codeVerifier: _codeVerifier,
              state: uri.queryParameters["state"] ?? "",
            );
            final auth = authRes.result;

            if (auth == null) {
              var msg = "Retrieve OAuth token error";
              final err = authRes.error?.vkErr;
              if (err != null) {
                msg += ": ${err.error} - ${err.description}";
              }
              _apiErrNotifier.value = msg;
              return;
            }
            _onVkAuth(auth);
          }

          return OAuthScreenMobile(authUri: uri, authCallback: callback);
        },
      ),
    );
  }

  Widget _buildSocialAuth() {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) {
        final isLoading = state is AuthLoading;

        return AbsorbPointer(
          absorbing: isLoading,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: ColorConstants.primaryColor, // VK rangi
              minimumSize: Size(double.infinity, 40),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            onPressed: () => _onPressedLogInButton(),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SvgPicture.asset(
                  'assets/images/vk.svg',
                  height: 24,
                  width: 24,
                  colorFilter: ColorFilter.mode(Colors.white, BlendMode.srcIn),
                ),
                SizedBox(width: 12),
                Text(
                  'Войти через VK',
                  style: TextStyle(color: Colors.white, fontSize: 16),
                ),
              ],
            ),
          ),
        );
      },
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
