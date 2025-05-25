import 'package:clinic/core/constants/color_constants.dart';
import 'package:clinic/core/extension/spacing_extension.dart';
import 'package:clinic/core/ui/widgets/buttons/custom_button.dart';
import 'package:clinic/core/ui/widgets/inputs/custom_text_feild.dart';
import 'package:clinic/core/ui/widgets/snackbars/custom_snackbar.dart';
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

class _ProfileDetailsScreenState extends State<ProfileDetailsScreen> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _nameController;
  late TextEditingController _phoneController;
  late TextEditingController _emailController;
  late TextEditingController _birthDateController;

  String? _selectedGender;
  DateTime? _selectedDate;

  final List<String> _genderOptions = ['Erkak', 'Ayol'];

  bool _hasChanges = false;

  @override
  void initState() {
    super.initState();
    _initializeControllers();
  }

  void _initializeControllers() {
    _nameController = TextEditingController(text: widget.user.name);
    _phoneController =
        TextEditingController(text: widget.user.phoneNumber ?? '');
    _emailController = TextEditingController(text: widget.user.email);
    _birthDateController = TextEditingController(
      text: widget.user.dateOfBirth != null
          ? DateFormat('dd.MM.yyyy').format(widget.user.dateOfBirth!)
          : '',
    );

    _selectedGender = widget.user.gender;
    _selectedDate = widget.user.dateOfBirth;

    // Controllerlarni kuzatish - o'zgarishlarni aniqlash uchun
    _nameController.addListener(_checkForChanges);
    _phoneController.addListener(_checkForChanges);
    _birthDateController.addListener(_checkForChanges);
  }

  void _checkForChanges() {
    setState(() {
      _hasChanges = _nameController.text != widget.user.name ||
          _phoneController.text != (widget.user.phoneNumber ?? '') ||
          _selectedGender != widget.user.gender ||
          _selectedDate != widget.user.dateOfBirth;
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _birthDateController.dispose();
    super.dispose();
  }

  String? _validateName(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Ism kiritilishi shart';
    }
    if (value.trim().length < 2) {
      return 'Ism kamida 2 ta belgi bo\'lishi kerak';
    }
    return null;
  }

  String? _validatePhone(String? value) {
    if (value != null && value.isNotEmpty) {
      final phoneRegex = RegExp(r'^\+998\d{9}$');
      if (!phoneRegex.hasMatch(value.replaceAll(RegExp(r'[\s\-\(\)]'), ''))) {
        return 'Noto\'g\'ri telefon raqam formati';
      }
    }
    return null;
  }

  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ??
          DateTime.now().subtract(const Duration(days: 365 * 20)),
      firstDate: DateTime(1920),
      lastDate: DateTime.now(),
      locale: const Locale('uz', 'UZ'),
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
        _birthDateController.text = DateFormat('dd.MM.yyyy').format(picked);
        _checkForChanges();
      });
    }
  }

  void _saveChanges() {
    context.read<ProfileBloc>().add(UpdateProfileEvent(widget.user));
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<ProfileBloc, ProfileState>(
      listener: (context, state) {
        if (state is ProfileUpdateSuccess) {
          CustomSnackbar.showSuccess(
            context: context,
            message: 'Profil muvaffaqiyatli yangilandi!',
          );
          Navigator.of(context)
              .pop(true); // true qaytarish - yangilanganini bildirish
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
            'Profil tafsilotlari',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: ColorConstants.textColor,
            ),
          ),
          centerTitle: true,
        ),
        body: SafeArea(
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
                        _buildProfileCard(),
                        24.h,
                        _buildPersonalInfoCard(),
                        24.h,
                        _buildContactInfoCard(),
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
    );
  }

  Widget _buildProfileCard() {
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
        children: [
          // Avatar
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  ColorConstants.primaryColor,
                  ColorConstants.primaryColor.withOpacity(0.7),
                ],
              ),
            ),
            child: Center(
              child: Text(
                widget.user.name.isNotEmpty
                    ? widget.user.name[0].toUpperCase()
                    : 'U',
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ),
          16.h,
          Text(
            widget.user.fullName,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: ColorConstants.textColor,
            ),
          ),
          4.h,
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: widget.user.isDoctor
                  ? ColorConstants.primaryColor.withOpacity(0.1)
                  : ColorConstants.accentGreen.withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              widget.user.isDoctor ? 'Shifokor' : 'Bemor',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: widget.user.isDoctor
                    ? ColorConstants.primaryColor
                    : ColorConstants.accentGreen,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPersonalInfoCard() {
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
          const Text(
            'Shaxsiy ma\'lumotlar',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: ColorConstants.textColor,
            ),
          ),
          20.h,

          // Ism
          _buildFieldLabel('To\'liq ism'),
          8.h,
          CustomTextField(
            controller: _nameController,
            hint: 'Ismingizni kiriting',
            validator: _validateName,
            prefixIcon: const Icon(Icons.person_outline,
                color: ColorConstants.primaryColor),
          ),
          16.h,

          // Tug'ilgan sana
          _buildFieldLabel('Tug\'ilgan sana'),
          8.h,
          CustomTextField(
            controller: _birthDateController,
            hint: 'Sanani tanlang',
            readOnly: true,
            onTap: _selectDate,
            prefixIcon: const Icon(Icons.calendar_today_outlined,
                color: ColorConstants.primaryColor),
            suffixIcon: const Icon(Icons.keyboard_arrow_down,
                color: ColorConstants.secondaryTextColor),
          ),
          16.h,

          // Jins
          _buildFieldLabel('Jins'),
          8.h,
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: ColorConstants.borderColor),
            ),
            child: DropdownButtonFormField<String>(
              value: _selectedGender,
              decoration: const InputDecoration(
                border: InputBorder.none,
                contentPadding:
                    EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                prefixIcon:
                    Icon(Icons.wc_outlined, color: ColorConstants.primaryColor),
              ),
              hint: const Text('Jinsni tanlang'),
              items: _genderOptions.map((String gender) {
                return DropdownMenuItem<String>(
                  value: gender,
                  child: Text(gender),
                );
              }).toList(),
              onChanged: (String? newValue) {
                setState(() {
                  _selectedGender = newValue;
                  _checkForChanges();
                });
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContactInfoCard() {
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
          const Text(
            'Aloqa ma\'lumotlari',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: ColorConstants.textColor,
            ),
          ),
          20.h,

          // Email (o'zgartirib bo'lmaydi)
          _buildFieldLabel('Email manzil'),
          8.h,
          CustomTextField(
            controller: _emailController,
            enabled: false,
            prefixIcon: const Icon(Icons.email_outlined,
                color: ColorConstants.secondaryTextColor),
            fillColor: ColorConstants.backgroundColor,
          ),
          16.h,

          // Telefon raqam
          _buildFieldLabel('Telefon raqam'),
          8.h,
          CustomTextField(
            controller: _phoneController,
            hint: '+998 XX XXX XX XX',
            keyboardType: TextInputType.phone,
            validator: _validatePhone,
            prefixIcon: const Icon(Icons.phone_outlined,
                color: ColorConstants.primaryColor),
          ),
        ],
      ),
    );
  }

  Widget _buildFieldLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(left: 4),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: ColorConstants.textColor,
        ),
      ),
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
              text: 'O\'zgarishlarni saqlash',
              onPressed: _saveChanges,
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
