import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:clinic/features/client/appointments/data/models/appointment_filter.dart';
import 'package:clinic/core/constants/color_constants.dart';

class FilterDialog extends StatefulWidget {
  final AppointmentFilters currentFilters;

  const FilterDialog({super.key, required this.currentFilters});

  @override
  State<FilterDialog> createState() => FilterDialogState();
}

class FilterDialogState extends State<FilterDialog> {
  late final TextEditingController _createdAtController;
  late final TextEditingController _birthDateController;
  late final TextEditingController _firstNameController;
  late final TextEditingController _lastNameController;
  late final TextEditingController _phoneController;

  // YYYY-MM-DD formatida server bilan muloqot
  final DateFormat _serverDateFormat = DateFormat('yyyy-MM-dd');

  // Rus tilida sana ko'rsatish uchun
  final List<String> _russianMonths = [
    'января',
    'февраля',
    'марта',
    'апреля',
    'мая',
    'июня',
    'июля',
    'августа',
    'сентября',
    'октября',
    'ноября',
    'декабря'
  ];

  @override
  void initState() {
    super.initState();
    _initializeControllers();
  }

  void _initializeControllers() {
    _createdAtController = TextEditingController(
      text: _formatDateForDisplay(widget.currentFilters.createdAt),
    );
    _birthDateController = TextEditingController(
      text: _formatDateForDisplay(widget.currentFilters.patientBirthDate),
    );
    _firstNameController = TextEditingController(
      text: widget.currentFilters.patientFirstName ?? '',
    );
    _lastNameController = TextEditingController(
      text: widget.currentFilters.patientLastName ?? '',
    );

    // Telefon raqami uchun avtomatik +7 qo'shish
    final currentPhone = widget.currentFilters.patientPhoneNumber ?? '';
    _phoneController = TextEditingController(
      text: currentPhone.isEmpty ? '+7 ' : _formatPhoneForDisplay(currentPhone),
    );
  }

  @override
  void dispose() {
    _createdAtController.dispose();
    _birthDateController.dispose();
    _firstNameController.dispose();
    _lastNameController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  /// Server formatidagi sanani rus tilida display qilish
  String _formatDateForDisplay(String? serverDate) {
    if (serverDate == null || serverDate.isEmpty) return '';

    try {
      final parsedDate = _serverDateFormat.parse(serverDate);
      final day = parsedDate.day.toString().padLeft(2, '0');
      final monthName = _russianMonths[parsedDate.month - 1];
      final year = parsedDate.year.toString();
      return '$day $monthName $year г.';
    } catch (e) {
      return '';
    }
  }

  /// Display formatidagi sanani server formatiga o'tkazish
  String _formatDateForServer(DateTime date) {
    return _serverDateFormat.format(date);
  }

  /// Telefon raqamini ko'rsatish uchun format
  String _formatPhoneForDisplay(String? phone) {
    if (phone == null || phone.isEmpty) return '+7 ';

    String digitsOnly = phone.replaceAll(RegExp(r'[^\d]'), '');

    if (digitsOnly.startsWith('7') && digitsOnly.length >= 1) {
      return _formatRussianPhone(digitsOnly);
    } else if (digitsOnly.length >= 10) {
      // Agar 7 bilan boshlanmasa, +7 qo'shib berish
      return _formatRussianPhone('7$digitsOnly');
    }

    return '+7 ';
  }

  /// Rossiya telefon raqamini formatlash
  String _formatRussianPhone(String digits) {
    if (digits.length < 2) return '+7 ';

    String formatted = '+7';
    if (digits.length > 1) {
      formatted += ' ${digits.substring(1, digits.length.clamp(1, 4))}';
    }
    if (digits.length > 4) {
      formatted += ' ${digits.substring(4, digits.length.clamp(4, 7))}';
    }
    if (digits.length > 7) {
      formatted += ' ${digits.substring(7, digits.length.clamp(7, 9))}';
    }
    if (digits.length > 9) {
      formatted += ' ${digits.substring(9, digits.length.clamp(9, 11))}';
    }

    return formatted;
  }

  /// Telefon raqamini server uchun format
  String _formatPhoneForServer(String displayPhone) {
    if (displayPhone.trim().length <= 3) return '';

    String digitsOnly = displayPhone.replaceAll(RegExp(r'[^\d]'), '');

    if (digitsOnly.startsWith('7') && digitsOnly.length == 11) {
      return '+$digitsOnly';
    }

    return '';
  }

  /// Cupertino stil sana tanlash dialogini ochish
  Future<void> _selectDate(TextEditingController controller) async {
    DateTime? selectedDate;

    await showCupertinoModalPopup<void>(
      context: context,
      builder: (BuildContext context) {
        return Container(
          height: 300,
          padding: const EdgeInsets.only(top: 6.0),
          margin: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          color: CupertinoColors.systemBackground.resolveFrom(context),
          child: SafeArea(
            top: false,
            child: Column(
              children: [
                // Header with action buttons
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  decoration: BoxDecoration(
                    border: Border(
                      bottom: BorderSide(
                        color: CupertinoColors.separator.resolveFrom(context),
                        width: 0.5,
                      ),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      CupertinoButton(
                        padding: EdgeInsets.zero,
                        onPressed: () => Navigator.of(context).pop(),
                        child: const Text(
                          'Отмена',
                          style: TextStyle(
                            color: CupertinoColors.destructiveRed,
                          ),
                        ),
                      ),
                      CupertinoButton(
                        padding: EdgeInsets.zero,
                        onPressed: () {
                          if (selectedDate != null) {
                            final day =
                                selectedDate!.day.toString().padLeft(2, '0');
                            final monthName =
                                _russianMonths[selectedDate!.month - 1];
                            final year = selectedDate!.year.toString();
                            controller.text = '$day $monthName $year г.';
                          }
                          Navigator.of(context).pop();
                        },
                        child: const Text('Готово'),
                      ),
                    ],
                  ),
                ),
                // Date picker
                Expanded(
                  child: CupertinoDatePicker(
                    mode: CupertinoDatePickerMode.date,
                    initialDateTime: DateTime.now(),
                    minimumDate: DateTime(1900),
                    maximumDate:
                        DateTime.now().add(const Duration(days: 365 * 5)),
                    onDateTimeChanged: (DateTime newDate) {
                      selectedDate = newDate;
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _applyFilters() {
    final filters = AppointmentFilters(
      createdAt: _parseDisplayDateToServer(_createdAtController.text),
      patientBirthDate: _parseDisplayDateToServer(_birthDateController.text),
      patientFirstName: _firstNameController.text.trim().isNotEmpty
          ? _firstNameController.text.trim()
          : null,
      patientLastName: _lastNameController.text.trim().isNotEmpty
          ? _lastNameController.text.trim()
          : null,
      patientPhoneNumber: _formatPhoneForServer(_phoneController.text),
    );

    Navigator.of(context).pop(filters);
  }

  /// Display formatidagi sanani server formatiga o'tkazish
  String _parseDisplayDateToServer(String displayDate) {
    if (displayDate.trim().isEmpty) return '';

    try {
      // "25 января 2024 г." formatini parse qilish
      final parts = displayDate.trim().replaceAll(' г.', '').split(' ');
      if (parts.length >= 3) {
        final day = int.parse(parts[0]);
        final monthIndex = _russianMonths.indexOf(parts[1]) + 1;
        final year = int.parse(parts[2]);

        final date = DateTime(year, monthIndex, day);
        return _formatDateForServer(date);
      }
    } catch (e) {
      // Parse bo'lmasa bo'sh qaytarish
    }

    return '';
  }

  void _clearAllFilters() {
    setState(() {
      _createdAtController.clear();
      _birthDateController.clear();
      _firstNameController.clear();
      _lastNameController.clear();
      _phoneController.text = '+7 '; // +7 ni saqlash
    });
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 420, maxHeight: 650),
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildHeader(),
            const SizedBox(height: 20),
            _buildFilterFields(),
            const SizedBox(height: 24),
            _buildActionButtons(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        const Icon(
          Icons.filter_list,
          color: ColorConstants.primaryColor,
          size: 24,
        ),
        const SizedBox(width: 8),
        const Text(
          'Фильтры поиска',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
        const Spacer(),
        IconButton(
          onPressed: () => Navigator.of(context).pop(),
          icon: const Icon(Icons.close),
          iconSize: 20,
          splashRadius: 20,
        ),
      ],
    );
  }

  Widget _buildFilterFields() {
    return Flexible(
      child: SingleChildScrollView(
        child: Column(
          children: [
            _buildDateField(
              controller: _createdAtController,
              label: 'Дата создания записи',
              hint: 'Выберите дату',
              icon: Icons.calendar_today,
            ),
            const SizedBox(height: 16),
            _buildDateField(
              controller: _birthDateController,
              label: 'Дата рождения пациента',
              hint: 'Выберите дату',
              icon: Icons.cake,
            ),
            const SizedBox(height: 16),
            _buildTextField(
              controller: _firstNameController,
              label: 'Имя пациента',
              hint: 'Введите имя',
              icon: Icons.person,
            ),
            const SizedBox(height: 16),
            _buildTextField(
              controller: _lastNameController,
              label: 'Фамилия пациента',
              hint: 'Введите фамилию',
              icon: Icons.person_outline,
            ),
            const SizedBox(height: 16),
            _buildPhoneField(),
          ],
        ),
      ),
    );
  }

  Widget _buildDateField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 6),
        TextField(
          controller: controller,
          readOnly: true,
          onTap: () => _selectDate(controller),
          decoration: InputDecoration(
            hintText: hint,
            prefixIcon: Icon(icon, size: 20, color: Colors.grey[600]),
            suffixIcon: controller.text.isNotEmpty
                ? IconButton(
                    icon: Icon(Icons.clear, size: 18, color: Colors.grey[600]),
                    onPressed: () => setState(() => controller.clear()),
                    splashRadius: 15,
                  )
                : Icon(Icons.touch_app, size: 20, color: Colors.grey[600]),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: ColorConstants.primaryColor),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 14,
            ),
            hintStyle: TextStyle(color: Colors.grey[500]),
          ),
          style: const TextStyle(fontSize: 14),
        ),
      ],
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 6),
        TextField(
          controller: controller,
          textCapitalization: TextCapitalization.words,
          decoration: InputDecoration(
            hintText: hint,
            prefixIcon: Icon(icon, size: 20, color: Colors.grey[600]),
            suffixIcon: controller.text.isNotEmpty
                ? IconButton(
                    icon: Icon(Icons.clear, size: 18, color: Colors.grey[600]),
                    onPressed: () => setState(() => controller.clear()),
                    splashRadius: 15,
                  )
                : null,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: ColorConstants.primaryColor),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 14,
            ),
            hintStyle: TextStyle(color: Colors.grey[500]),
          ),
          style: const TextStyle(fontSize: 14),
          onChanged: (value) => setState(() {}),
        ),
      ],
    );
  }

  Widget _buildPhoneField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Номер телефона',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 6),
        TextField(
          controller: _phoneController,
          keyboardType: TextInputType.phone,
          inputFormatters: [
            FilteringTextInputFormatter.allow(RegExp(r'[\d\s\+]')),
            _RussianPhoneFormatter(),
          ],
          decoration: InputDecoration(
            hintText: '+7 XXX XXX XX XX',
            prefixIcon: Icon(Icons.phone, size: 20, color: Colors.grey[600]),
            suffixIcon: _phoneController.text.length > 3
                ? IconButton(
                    icon: Icon(Icons.clear, size: 18, color: Colors.grey[600]),
                    onPressed: () =>
                        setState(() => _phoneController.text = '+7 '),
                    splashRadius: 15,
                  )
                : null,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: ColorConstants.primaryColor),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 14,
            ),
            hintStyle: TextStyle(color: Colors.grey[500]),
          ),
          style: const TextStyle(fontSize: 14),
          onChanged: (value) => setState(() {}),
        ),
      ],
    );
  }

  Widget _buildActionButtons() {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton.icon(
            onPressed: _clearAllFilters,
            icon: const Icon(Icons.clear_all, size: 18),
            label: const Text('Очистить всё'),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              side: BorderSide(color: Colors.grey[300]!),
              foregroundColor: Colors.black87,
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: ElevatedButton.icon(
            onPressed: _applyFilters,
            icon: const Icon(Icons.check, size: 18),
            label: const Text('Применить'),
            style: ElevatedButton.styleFrom(
              backgroundColor: ColorConstants.primaryColor,
              foregroundColor: Colors.white,
              elevation: 2,
              padding: const EdgeInsets.symmetric(vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

/// Rossiya telefon raqami uchun optimallashtirilgan formatter
class _RussianPhoneFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final text = newValue.text;

    // Bo'sh bo'lsa +7 ni o'rnatish
    if (text.isEmpty) {
      return const TextEditingValue(
        text: '+7 ',
        selection: TextSelection.collapsed(offset: 3),
      );
    }

    // +7 ni o'chirishga ruxsat bermaslik
    if (!text.startsWith('+7')) {
      return const TextEditingValue(
        text: '+7 ',
        selection: TextSelection.collapsed(offset: 3),
      );
    }

    // Faqat raqamlarni ajratib olish (+7 dan keyin)
    String digitsOnly = text.substring(2).replaceAll(RegExp(r'[^\d]'), '');

    // 10 ta raqamdan ko'p kiritmaslik
    if (digitsOnly.length > 10) {
      digitsOnly = digitsOnly.substring(0, 10);
    }

    // Formatlash
    String formattedText = '+7';
    if (digitsOnly.isNotEmpty) {
      formattedText +=
          ' ${digitsOnly.substring(0, digitsOnly.length.clamp(0, 3))}';

      if (digitsOnly.length > 3) {
        formattedText +=
            ' ${digitsOnly.substring(3, digitsOnly.length.clamp(3, 6))}';
      }
      if (digitsOnly.length > 6) {
        formattedText +=
            ' ${digitsOnly.substring(6, digitsOnly.length.clamp(6, 8))}';
      }
      if (digitsOnly.length > 8) {
        formattedText +=
            ' ${digitsOnly.substring(8, digitsOnly.length.clamp(8, 10))}';
      }
    } else {
      formattedText += ' ';
    }

    return TextEditingValue(
      text: formattedText,
      selection: TextSelection.collapsed(offset: formattedText.length),
    );
  }
}
