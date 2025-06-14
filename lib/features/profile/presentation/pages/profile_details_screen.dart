// lib/features/profile/presentation/pages/profile_details_screen.dart
import 'package:clinic/core/constants/color_constants.dart';
import 'package:clinic/core/extension/spacing_extension.dart';
import 'package:clinic/core/ui/widgets/buttons/custom_button.dart';
import 'package:clinic/core/ui/widgets/inputs/custom_text_feild.dart';
import 'package:clinic/core/ui/widgets/snackbars/custom_snackbar.dart';
import 'package:clinic/features/profile/data/model/profile_model.dart';
import 'package:clinic/features/profile/domain/entities/profile_entities.dart';
import 'package:clinic/features/profile/presentation/bloc/profile_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

class ProfileDetailsScreen extends StatefulWidget {
  final ProfileEntities user;

  const ProfileDetailsScreen({
    super.key,
    required this.user,
  });

  @override
  State<ProfileDetailsScreen> createState() => _ProfileDetailsScreenState();
}

class _ProfileDetailsScreenState extends State<ProfileDetailsScreen>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();

  // Controllers
  late TextEditingController _nameController;
  late TextEditingController _birthDateController;
  late TextEditingController _genderController;

  // Ma'lumotlar
  String? _selectedGender;
  DateTime? _selectedDate;
  bool _hasChanges = false;

  // Date formatter - ISO 8601 format (yyyy-MM-dd)
  static final DateFormat _isoDateFormat = DateFormat('yyyy-MM-dd');
  // Display formatter - user-friendly format
  static final DateFormat _displayDateFormat = DateFormat('dd.MM.yyyy');

  // Gender options
  final List<Map<String, String>> _genderOptions = [
    {'value': 'M', 'label': 'Мужской'},
    {'value': 'F', 'label': 'Женский'},
  ];

  // Animation
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _initializeControllers();
    _setupAnimations();
  }

  void _setupAnimations() {
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
    );
    _animationController.forward();
  }

  void _initializeControllers() {
    _nameController = TextEditingController(text: widget.user.name);

    // Display formatida ko'rsatish, lekin internal storage ISO formatida
    _birthDateController = TextEditingController(
      text: widget.user.dateOfBirth != null
          ? _displayDateFormat.format(widget.user.dateOfBirth!)
          : '',
    );

    _genderController = TextEditingController(
      text: _getGenderLabel(widget.user.gender),
    );

    _selectedGender = widget.user.gender;
    _selectedDate = widget.user.dateOfBirth;

    // Controllerlarni kuzatish
    _nameController.addListener(_checkForChanges);
  }

  String _getGenderLabel(String? value) {
    if (value == null) return '';
    final option = _genderOptions.firstWhere(
      (opt) => opt['value'] == value,
      orElse: () => {'label': ''},
    );
    return option['label'] ?? '';
  }

  void _checkForChanges() {
    final hasChanges = _nameController.text.trim() != widget.user.name ||
        _selectedGender != widget.user.gender ||
        _selectedDate != widget.user.dateOfBirth;

    if (_hasChanges != hasChanges) {
      setState(() {
        _hasChanges = hasChanges;
      });
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _birthDateController.dispose();
    _genderController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  String? _validateName(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Имя обязательно для заполнения';
    }
    if (value.trim().length < 2) {
      return 'Имя должно содержать минимум 2 символа';
    }
    return null;
  }

  /// Sanani ISO 8601 formatida qaytaradi (yyyy-MM-dd)
  String? get formattedDateForSubmission {
    return _selectedDate != null ? _isoDateFormat.format(_selectedDate!) : null;
  }

  /// Debug maqsadida - konsol uchun
  void _logDateFormats() {
    if (_selectedDate != null) {
      debugPrint(
          'Display format: ${_displayDateFormat.format(_selectedDate!)}');
      debugPrint('ISO format: ${_isoDateFormat.format(_selectedDate!)}');
      debugPrint('DateTime object: $_selectedDate');
    }
  }

  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ??
          DateTime.now().subtract(const Duration(days: 365 * 25)),
      firstDate: DateTime(1920),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: ColorConstants.primaryColor,
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: ColorConstants.textColor,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        _selectedDate = picked;
        // Foydalanuvchiga display formatida ko'rsatish
        _birthDateController.text = _displayDateFormat.format(picked);
        _checkForChanges();
      });

      // Debug maqsadida
      _logDateFormats();
    }
  }

  void _selectGender() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: 16.verticalTop,
        ),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
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
                Text(
                  'Выберите пол',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: ColorConstants.textColor,
                  ),
                ),
                16.h,
                ..._genderOptions.map((option) => ListTile(
                      title: Text(option['label']!),
                      leading: Radio<String>(
                        value: option['value']!,
                        groupValue: _selectedGender,
                        activeColor: ColorConstants.primaryColor,
                        onChanged: (value) {
                          setState(() {
                            _selectedGender = value;
                            _genderController.text = option['label']!;
                            _checkForChanges();
                          });
                          Navigator.pop(context);
                        },
                      ),
                      onTap: () {
                        setState(() {
                          _selectedGender = option['value'];
                          _genderController.text = option['label']!;
                          _checkForChanges();
                        });
                        Navigator.pop(context);
                      },
                    )),
                16.h,
              ],
            ),
          ),
        ]),
      ),
    );
  }

  void _saveChanges() {
    if (_formKey.currentState!.validate()) {
      final currentModel = ProfileModel.fromEntity(widget.user);

      // ISO formatda saqlash
      final updatedModel = currentModel.copyWith(
        name: _nameController.text.trim(),
        gender: _selectedGender,
        dateOfBirth: _selectedDate,
      );

      context.read<ProfileBloc>().add(UpdateProfileEvent(updatedModel));
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<ProfileBloc, ProfileState>(
      listener: (context, state) {
        if (state is ProfileUpdateSuccess) {
          CustomSnackbar.showSuccess(
            context: context,
            message: 'Профиль успешно обновлен!',
          );
          Navigator.of(context).pop(true);
        } else if (state is ProfileUpdateError) {
          CustomSnackbar.showError(
            context: context,
            message: state.message,
          );
        }
      },
      child: Scaffold(
        backgroundColor: ColorConstants.backgroundColor,
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios,
                color: ColorConstants.textColor),
            onPressed: () => Navigator.of(context).pop(),
          ),
          title: const Text(
            'Детали профиля',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: ColorConstants.textColor,
            ),
          ),
          centerTitle: true,
        ),
        body: FadeTransition(
          opacity: _fadeAnimation,
          child: SafeArea(
            child: Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(20),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildPersonalInfoSection(),
                        ],
                      ),
                    ),
                  ),
                ),
                _buildSaveButton(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPersonalInfoSection() {
    return _buildSection(
      title: 'Личная информация',
      children: [
        _buildField(
          label: 'Имя',
          controller: _nameController,
          hint: 'Введите ваше имя',
          icon: Icons.person_outline,
          validator: _validateName,
        ),
        16.h,
        _buildField(
          label: 'Дата рождения',
          controller: _birthDateController,
          hint: 'Выберите дату',
          icon: Icons.calendar_today_outlined,
          readOnly: true,
          onTap: _selectDate,
          suffixIcon: const Icon(Icons.keyboard_arrow_down),
        ),
        16.h,
        _buildField(
          label: 'Пол',
          controller: _genderController,
          hint: 'Выберите пол',
          icon: Icons.wc_outlined,
          readOnly: true,
          onTap: _selectGender,
          suffixIcon: const Icon(Icons.keyboard_arrow_down),
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

  Widget _buildField({
    required String label,
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    String? Function(String?)? validator,
    bool enabled = true,
    bool readOnly = false,
    VoidCallback? onTap,
    TextInputType? keyboardType,
    Widget? suffixIcon,
    Color? fillColor,
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
          prefixIcon: Icon(icon,
              color: enabled
                  ? ColorConstants.primaryColor
                  : ColorConstants.secondaryTextColor),
          validator: validator,
          enabled: enabled,
          readOnly: readOnly,
          onTap: onTap,
          keyboardType: keyboardType,
          suffixIcon: suffixIcon,
          fillColor: fillColor,
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
              text: 'Сохранить изменения',
              onPressed: _hasChanges ? _saveChanges : () {},
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
