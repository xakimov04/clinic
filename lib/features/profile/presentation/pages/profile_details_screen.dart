// lib/features/profile/presentation/pages/profile_details_screen.dart
import 'package:clinic/core/constants/color_constants.dart';
import 'package:clinic/core/di/modules/receptions_module.dart';
import 'package:clinic/core/extension/spacing_extension.dart';
import 'package:clinic/core/local/local_storage_service.dart';
import 'package:clinic/core/local/storage_keys.dart';
import 'package:clinic/core/ui/widgets/buttons/custom_button.dart';
import 'package:clinic/core/ui/widgets/inputs/custom_text_feild.dart';
import 'package:clinic/core/ui/widgets/snackbars/custom_snackbar.dart';
import 'package:clinic/features/auth/presentation/widgets/input_formatter.dart';
import 'package:clinic/features/profile/data/model/profile_model.dart';
import 'package:clinic/features/profile/domain/entities/profile_entities.dart';
import 'package:clinic/features/profile/presentation/bloc/profile_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

class ProfileDetailsScreen extends StatefulWidget {
  final ProfileEntities? user;
  final bool isFromBooking;

  const ProfileDetailsScreen({
    super.key,
    this.user,
    this.isFromBooking = false,
  });

  @override
  State<ProfileDetailsScreen> createState() => _ProfileDetailsScreenState();
}

class _ProfileDetailsScreenState extends State<ProfileDetailsScreen>
    with SingleTickerProviderStateMixin {
  // Form калити
  final _formKey = GlobalKey<FormState>();

  // Контроллерлар
  late final TextEditingController _firstNameController;
  late final TextEditingController _lastNameController;
  late final TextEditingController _middleNameController;
  late final TextEditingController _phoneController;
  late final TextEditingController _birthDateController;
  late final TextEditingController _genderController;

  // Ҳолатни кузатиш учун
  String? _selectedGender;
  DateTime? _selectedDate;
  bool _hasChanges = false;

  // Сана форматлаш
  static final DateFormat _displayDateFormat = DateFormat('dd.MM.yyyy');

  // Жинс танлови
  static const List<({String value, String label})> _genderOptions = [
    (value: 'M', label: 'Мужской'),
    (value: 'F', label: 'Женский'),
  ];

  // Анимация
  late final AnimationController _animationController;
  late final Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _initializeControllers();
    _setupAnimations();
    _setupChangeListeners();
  }

  @override
  void dispose() {
    _disposeControllers();
    _animationController.dispose();
    super.dispose();
  }

  void _setupAnimations() {
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOut,
    ));
    _animationController.forward();
  }

  void _initializeControllers() {
    _firstNameController =
        TextEditingController(text: widget.user?.firstName ?? '');
    _lastNameController =
        TextEditingController(text: widget.user?.lastName ?? '');
    _middleNameController =
        TextEditingController(text: widget.user?.middleName ?? '');

    _phoneController = TextEditingController(
      text: _formatToRussianPhone(widget.user?.phoneNumber ?? ''),
    );

    _birthDateController = TextEditingController(
      text: widget.user?.dateOfBirth != null
          ? _displayDateFormat.format(widget.user!.dateOfBirth!)
          : '',
    );

    _genderController = TextEditingController(
      text: _getGenderLabel(widget.user?.gender),
    );

    _selectedGender = widget.user?.gender;
    _selectedDate = widget.user?.dateOfBirth;
  }

  void _setupChangeListeners() {
    final controllers = [
      _firstNameController,
      _lastNameController,
      _middleNameController,
      _phoneController,
    ];

    for (final controller in controllers) {
      controller.addListener(_checkForChanges);
    }
  }

  void _disposeControllers() {
    final controllers = [
      _firstNameController,
      _lastNameController,
      _middleNameController,
      _phoneController,
      _birthDateController,
      _genderController,
    ];

    for (final controller in controllers) {
      controller.dispose();
    }
  }

  // Телефон рақамини форматлаш
  String _formatToRussianPhone(String rawPhone) {
    final digits = rawPhone.replaceAll(RegExp(r'\D'), '');

    if (digits.isEmpty) return '+7 ';

    final cleanedDigits = digits.length == 11 && digits.startsWith('7')
        ? digits
        : digits.length == 10
            ? '7$digits'
            : digits;

    if (cleanedDigits.length == 11) {
      return '+7 (${cleanedDigits.substring(1, 4)}) '
          '${cleanedDigits.substring(4, 7)}-'
          '${cleanedDigits.substring(7, 9)}-'
          '${cleanedDigits.substring(9)}';
    }

    return '+7 ';
  }

  // Жинс лабелини олиш
  String _getGenderLabel(String? value) {
    if (value == null) return '';

    try {
      return _genderOptions.firstWhere((option) => option.value == value).label;
    } catch (e) {
      return '';
    }
  }

  // Ўзгаришларни текшириш
  void _checkForChanges() {
    // Янги маълумотлар билан default қийматларни солиштириш
    final originalFirstName = widget.user?.firstName ?? '';
    final originalLastName = widget.user?.lastName ?? '';
    final originalMiddleName = widget.user?.middleName ?? '';
    final originalPhone = _formatToRussianPhone(widget.user?.phoneNumber ?? '');
    final originalGender = widget.user?.gender;
    final originalBirthDate = widget.user?.dateOfBirth;

    final hasChanges = _firstNameController.text.trim() != originalFirstName ||
        _lastNameController.text.trim() != originalLastName ||
        _middleNameController.text.trim() != originalMiddleName ||
        _phoneController.text != originalPhone ||
        _selectedGender != originalGender ||
        _selectedDate != originalBirthDate;

    // Booking режимида faqat telefon majburiy
    final shouldShowChanges =
        widget.isFromBooking ? _phoneController.text.isNotEmpty : hasChanges;

    if (_hasChanges != shouldShowChanges) {
      setState(() => _hasChanges = shouldShowChanges);
    }
  }

  // Валидаторлар - faqat telefon uchun majburiy
  String? _validateRequired(String? value, String fieldName) {
    if (value == null || value.trim().isEmpty) {
      return null; // Optional qilindi
    }
    if (value.trim().length < 2) {
      return '$fieldName должно содержать минимум 2 символа';
    }
    return null;
  }

  String? _validatePhone(String? value) {
    if (value?.isEmpty ?? true) {
      return 'Введите номер телефона';
    }

    final digitsCount = value!.replaceAll(RegExp(r'\D'), '').length;
    if (digitsCount < 11) {
      return 'Введите полный номер телефона';
    }

    return null;
  }

  String? _validateSelection(String? value, String fieldName) {
    // Optional qilindi - faqat telefon majburiy
    return null;
  }

  // Сана танлаш
  Future<void> _selectDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ??
          DateTime.now().subtract(const Duration(days: 365 * 25)),
      firstDate: DateTime(1920),
      lastDate: DateTime.now(),
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(
          colorScheme: ColorScheme.light(
            primary: ColorConstants.primaryColor,
            onPrimary: Colors.white,
            surface: Colors.white,
            onSurface: ColorConstants.textColor,
          ),
        ),
        child: child!,
      ),
    );

    if (picked != null) {
      setState(() {
        _selectedDate = picked;
        _birthDateController.text = _displayDateFormat.format(picked);
      });
      _checkForChanges();
    }
  }

  // Жинс танлаш
  void _selectGender() {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: 16.verticalTop,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Handle
            Container(
              width: 40,
              height: 4,
              margin: 8.v,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: 2.circular,
              ),
            ),
            Padding(
              padding: 16.a,
              child: Column(
                children: [
                  const Text(
                    'Выберите пол',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: ColorConstants.textColor,
                    ),
                  ),
                  16.h,
                  ..._genderOptions.map((option) => ListTile(
                        title: Text(option.label),
                        leading: Radio<String>(
                          value: option.value,
                          groupValue: _selectedGender,
                          activeColor: ColorConstants.primaryColor,
                          onChanged: (value) => _onGenderSelected(option),
                        ),
                        onTap: () => _onGenderSelected(option),
                      )),
                  16.h,
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _onGenderSelected(({String value, String label}) option) {
    setState(() {
      _selectedGender = option.value;
      _genderController.text = option.label;
    });
    _checkForChanges();
    Navigator.pop(context);
  }

  // Ўзгаришларни сақлаш
  Future<void> _saveChanges() async {
    if (!_formKey.currentState!.validate()) return;

    final rawPhone = _phoneController.text.replaceAll(RegExp(r'\D'), '');

    final ProfileModel updatedModel;
    if (widget.user != null) {
      final currentModel = ProfileModel.fromEntity(widget.user!);
      updatedModel = currentModel.copyWith(
        firstName: _firstNameController.text.trim(),
        lastName: _lastNameController.text.trim(),
        middleName: _middleNameController.text.trim(),
        phoneNumber: rawPhone,
        gender: _selectedGender,
        dateOfBirth: _selectedDate,
      );
    } else {
      updatedModel = ProfileModel(
        id: 0,
        username: _firstNameController.text.trim(),
        email: '',
        firstName: _firstNameController.text.trim(),
        lastName: _lastNameController.text.trim(),
        middleName: _middleNameController.text.trim(),
        phoneNumber: rawPhone,
        gender: _selectedGender,
        dateOfBirth: _selectedDate,
        verified: false,
        agreedToTerms: true,
        biometricEnabled: false,
        userType: 'patient',
        avatar: null,
        isAvailable: true,
      );
    }

    context.read<ProfileBloc>().add(UpdateProfileEvent(updatedModel));
  }

  // Орқага қайтиш логикаси
  Future<bool> _handleBackPress() async {
    if (_hasChanges && widget.isFromBooking) {
      return await _showUnsavedChangesDialog() ?? false;
    }

    if (widget.isFromBooking) {
      context.pop(false);
      return false;
    }
    context.pop();

    return true;
  }

  // Сақланмаган ўзгаришлар диалоги
  Future<bool?> _showUnsavedChangesDialog() {
    return showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: const Text(
          'Несохраненные изменения',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: ColorConstants.textColor,
          ),
        ),
        content: const Text(
          'У вас есть несохраненные изменения. Вы уверены, что хотите выйти без сохранения?',
          style: TextStyle(
            fontSize: 14,
            color: ColorConstants.secondaryTextColor,
            height: 1.4,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(
              'Отмена',
              style: TextStyle(
                color: ColorConstants.primaryColor,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop(true);
              context.pop(false); // Booking'га false қайтариш
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text(
              'Выйти',
              style: TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvoked: (didPop) async {
        if (!didPop) {
          final shouldPop = await _handleBackPress();
          if (shouldPop && mounted) {
            Navigator.of(context).pop();
          }
        }
      },
      child: BlocListener<ProfileBloc, ProfileState>(
        listener: _handleProfileStateChanges,
        child: Scaffold(
          backgroundColor: ColorConstants.backgroundColor,
          appBar: _buildAppBar(),
          body: FadeTransition(
            opacity: _fadeAnimation,
            child: SafeArea(
              child: Column(
                children: [
                  Expanded(child: _buildForm()),
                  _buildSaveButton(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _handleProfileStateChanges(BuildContext context, ProfileState state) {
    switch (state) {
      case ProfileUpdateSuccess():
        _handleProfileUpdateSuccess();
      case ProfileUpdateError():
        CustomSnackbar.showError(
          context: context,
          message: state.message,
        );
    }
  }

  /// Профиль муваффақиятли янгиланганда
  Future<void> _handleProfileUpdateSuccess() async {
    try {
      // LocalStorage'да профиль тўлдирилганини белгилаш
      await sl<LocalStorageService>().setBool(StorageKeys.isprofileFill, false);

      CustomSnackbar.showSuccess(
        context: context,
        message: 'Профиль успешно обновлен!',
      );

      if (mounted) {
        context.pop(true);
      }
    } catch (e) {
      debugPrint('Error updating profile fill status: $e');
      CustomSnackbar.showError(
        context: context,
        message: 'Ошибка при сохранении статуса профиля',
      );
    }
  }

  AppBar _buildAppBar() {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      leading: IconButton(
        icon: const Icon(
          Icons.arrow_back_ios,
          color: ColorConstants.textColor,
        ),
        onPressed: () => _handleBackPress(),
      ),
      title: Text(
        widget.isFromBooking ? 'Заполнить профиль' : 'Детали профиля',
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: ColorConstants.textColor,
        ),
      ),
      centerTitle: true,
    );
  }

  Widget _buildForm() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Form(
        key: _formKey,
        child: Column(
          children: [
            // Booking'дан келган бўлса, маълумот кўрсатиш
            if (widget.isFromBooking) _buildBookingInfoBanner(),

            if (widget.isFromBooking) 16.h,

            _buildPersonalInfoSection(),
          ],
        ),
      ),
    );
  }

  /// Booking маълумот баннери
  Widget _buildBookingInfoBanner() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            ColorConstants.primaryColor.withOpacity(0.05),
            ColorConstants.primaryColor.withOpacity(0.02),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: ColorConstants.primaryColor.withOpacity(0.1),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: ColorConstants.primaryColor.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.info_outline,
              color: ColorConstants.primaryColor,
              size: 20,
            ),
          ),
          12.w,
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Завершение записи',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: ColorConstants.primaryColor,
                  ),
                ),
                4.h,
                Text(
                  'Заполните телефон для завершения записи на прием',
                  style: TextStyle(
                    fontSize: 12,
                    color: ColorConstants.primaryColor.withOpacity(0.8),
                    height: 1.3,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPersonalInfoSection() {
    return _buildSection(
      title: 'Личная информация',
      children: [
        _buildTextField(
          label: 'Имя',
          controller: _firstNameController,
          hint: 'Введите ваше имя',
          icon: Icons.person_outline,
          validator: (value) => _validateRequired(value, 'Имя'),
          textCapitalization: TextCapitalization.words,
        ),
        16.h,
        _buildTextField(
          label: 'Фамилия',
          controller: _lastNameController,
          hint: 'Введите вашу фамилию',
          icon: Icons.person_outline,
          validator: (value) => _validateRequired(value, 'Фамилия'),
          textCapitalization: TextCapitalization.words,
        ),
        16.h,
        _buildTextField(
          label: 'Отчество',
          controller: _middleNameController,
          hint: 'Введите ваше отчество',
          icon: Icons.person_outline,
          validator: (value) => _validateRequired(value, 'Отчество'),
          textCapitalization: TextCapitalization.words,
        ),
        16.h,
        _buildTextField(
          label: 'Дата рождения',
          controller: _birthDateController,
          hint: 'Выберите дату рождения',
          icon: Icons.calendar_today_outlined,
          readOnly: true,
          onTap: _selectDate,
          suffixIcon: const Icon(Icons.keyboard_arrow_down),
          validator: (value) => _validateSelection(value, 'Дата рождения'),
        ),
        16.h,
        _buildTextField(
          label: 'Пол',
          controller: _genderController,
          hint: 'Выберите пол',
          icon: Icons.wc_outlined,
          readOnly: true,
          onTap: _selectGender,
          suffixIcon: const Icon(Icons.keyboard_arrow_down),
          validator: (value) => _validateSelection(value, 'Пол'),
        ),
        16.h,
        _buildPhoneField(),
      ],
    );
  }

  Widget _buildPhoneField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.only(left: 4, bottom: 8),
          child: Text(
            'Номер телефона *',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: ColorConstants.textColor,
            ),
          ),
        ),
        CustomTextField(
          controller: _phoneController,
          hint: '(XX) XXX-XX-XX',
          keyboardType: TextInputType.phone,
          prefixIcon: const Icon(
            Icons.phone_outlined,
            color: ColorConstants.primaryColor,
          ),
          inputFormatters: [RussianPhoneInputFormatter()],
          validator: _validatePhone,
        ),
      ],
    );
  }

  Widget _buildSection({
    required String title,
    required List<Widget> children,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: ColorConstants.textColor,
            ),
          ),
          20.h,
          ...children,
        ],
      ),
    );
  }

  Widget _buildTextField({
    required String label,
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    String? Function(String?)? validator,
    bool readOnly = false,
    VoidCallback? onTap,
    Widget? suffixIcon,
    TextCapitalization textCapitalization = TextCapitalization.none,
    List<TextInputFormatter>? inputFormatters,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 8),
          child: Text(
            label,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: ColorConstants.textColor,
            ),
          ),
        ),
        CustomTextField(
          controller: controller,
          hint: hint,
          prefixIcon: Icon(
            icon,
            color: ColorConstants.primaryColor,
          ),
          validator: validator,
          readOnly: readOnly,
          onTap: onTap,
          suffixIcon: suffixIcon,
          textCapitalization: textCapitalization,
          inputFormatters: inputFormatters,
        ),
      ],
    );
  }

  Widget _buildSaveButton() {
    return BlocBuilder<ProfileBloc, ProfileState>(
      builder: (context, state) {
        final isLoading = state is ProfileUpdating;

        return Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, -2),
              ),
            ],
          ),
          child: SafeArea(
            child: CustomButton(
              text: widget.isFromBooking
                  ? 'Сохранить и продолжить'
                  : 'Сохранить изменения',
              onPressed: () {
                if (_hasChanges && !isLoading) {
                  _saveChanges();
                }
              },
              isLoading: isLoading,
              fullWidth: true,
              height: 50,
              backgroundColor: _hasChanges
                  ? ColorConstants.primaryColor
                  : ColorConstants.secondaryTextColor,
              disableOnLoading: true,
            ),
          ),
        );
      },
    );
  }
}
