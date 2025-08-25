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
      _phoneController.text = '+7 ';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 8,
      child: Container(
        constraints: const BoxConstraints(maxWidth: 480, maxHeight: 700),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildHeader(),
            Flexible(
              child: _buildFilterFields(),
            ),
            _buildActionButtons(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 20, 20, 16),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(16),
          topRight: Radius.circular(16),
        ),
        border: Border(
          bottom: BorderSide(
            color: Colors.grey.shade200,
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: ColorConstants.primaryColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(
              Icons.tune,
              color: ColorConstants.primaryColor,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          const Expanded(
            child: Text(
              'Фильтры поиска',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
          ),
          Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () => Navigator.of(context).pop(),
              borderRadius: BorderRadius.circular(8),
              child: Container(
                padding: const EdgeInsets.all(8),
                child: Icon(
                  Icons.close,
                  size: 20,
                  color: Colors.grey.shade600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterFields() {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Column(
        children: [
          _buildFormField(
            controller: _createdAtController,
            label: 'Дата создания записи',
            hint: 'Выберите дату создания',
            isDateField: true,
          ),
          const SizedBox(height: 20),
          _buildFormField(
            controller: _birthDateController,
            label: 'Дата рождения пациента',
            hint: 'Выберите дату рождения',
            isDateField: true,
          ),
          const SizedBox(height: 20),
          _buildFormField(
            controller: _firstNameController,
            label: 'Имя пациента',
            hint: 'Введите имя',
          ),
          const SizedBox(height: 20),
          _buildFormField(
            controller: _lastNameController,
            label: 'Фамилия пациента',
            hint: 'Введите фамилию',
          ),
          const SizedBox(height: 20),
          _buildPhoneField(),
        ],
      ),
    );
  }

  Widget _buildFormField({
    required TextEditingController controller,
    required String label,
    required String hint,
    bool isDateField = false,
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
            letterSpacing: 0.1,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.02),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: TextField(
            controller: controller,
            readOnly: isDateField,
            onTap: isDateField ? () => _selectDate(controller) : null,
            textCapitalization: isDateField
                ? TextCapitalization.none
                : TextCapitalization.words,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w500,
              color: Colors.black87,
            ),
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: TextStyle(
                color: Colors.grey.shade500,
                fontWeight: FontWeight.w400,
                fontSize: 15,
              ),
              filled: true,
              fillColor: Colors.white,
              suffixIcon: controller.text.isNotEmpty
                  ? Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: () => setState(() => controller.clear()),
                        borderRadius: BorderRadius.circular(20),
                        child: Container(
                          padding: const EdgeInsets.all(12),
                          child: Icon(
                            Icons.clear,
                            size: 18,
                            color: Colors.grey.shade500,
                          ),
                        ),
                      ),
                    )
                  : isDateField
                      ? Container(
                          padding: const EdgeInsets.all(12),
                          child: Icon(
                            Icons.calendar_today_outlined,
                            size: 18,
                            color: Colors.grey.shade500,
                          ),
                        )
                      : null,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.grey.shade300, width: 1),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.grey.shade300, width: 1),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(
                    color: ColorConstants.primaryColor, width: 2),
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 16,
              ),
            ),
            onChanged: isDateField ? null : (value) => setState(() {}),
          ),
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
            letterSpacing: 0.1,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.02),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: TextField(
            controller: _phoneController,
            keyboardType: TextInputType.phone,
            inputFormatters: [
              FilteringTextInputFormatter.allow(RegExp(r'[\d\s\+]')),
              _RussianPhoneFormatter(),
            ],
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w500,
              color: Colors.black87,
            ),
            decoration: InputDecoration(
              hintText: '+7 XXX XXX XX XX',
              hintStyle: TextStyle(
                color: Colors.grey.shade500,
                fontWeight: FontWeight.w400,
                fontSize: 15,
              ),
              filled: true,
              fillColor: Colors.white,
              suffixIcon: _phoneController.text.length > 3
                  ? Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: () =>
                            setState(() => _phoneController.text = '+7 '),
                        borderRadius: BorderRadius.circular(20),
                        child: Container(
                          padding: const EdgeInsets.all(12),
                          child: Icon(
                            Icons.clear,
                            size: 18,
                            color: Colors.grey.shade500,
                          ),
                        ),
                      ),
                    )
                  : Container(
                      padding: const EdgeInsets.all(12),
                      child: Icon(
                        Icons.phone_outlined,
                        size: 18,
                        color: Colors.grey.shade500,
                      ),
                    ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.grey.shade300, width: 1),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.grey.shade300, width: 1),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(
                    color: ColorConstants.primaryColor, width: 2),
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 16,
              ),
            ),
            onChanged: (value) => setState(() {}),
          ),
        ),
      ],
    );
  }

  Widget _buildActionButtons() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(16),
          bottomRight: Radius.circular(16),
        ),
        border: Border(
          top: BorderSide(
            color: Colors.grey.shade200,
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Container(
              height: 48,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: Colors.grey.shade300,
                  width: 1,
                ),
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: _clearAllFilters,
                  borderRadius: BorderRadius.circular(12),
                  child: const Center(
                    child: Text(
                      'Очистить всё',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                        letterSpacing: 0.1,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Container(
              height: 48,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    ColorConstants.primaryColor,
                    ColorConstants.primaryColor.withOpacity(0.9),
                  ],
                ),
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: ColorConstants.primaryColor.withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: _applyFilters,
                  borderRadius: BorderRadius.circular(12),
                  child: const Center(
                    child: Text(
                      'Применить',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                        letterSpacing: 0.1,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
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

    if (text.isEmpty) {
      return const TextEditingValue(
        text: '+7 ',
        selection: TextSelection.collapsed(offset: 3),
      );
    }

    if (!text.startsWith('+7')) {
      return const TextEditingValue(
        text: '+7 ',
        selection: TextSelection.collapsed(offset: 3),
      );
    }

    String digitsOnly = text.substring(2).replaceAll(RegExp(r'[^\d]'), '');

    if (digitsOnly.length > 10) {
      digitsOnly = digitsOnly.substring(0, 10);
    }

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
