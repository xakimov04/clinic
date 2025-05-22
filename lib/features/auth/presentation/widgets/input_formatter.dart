import 'package:flutter/services.dart';

class RussianPhoneInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    // Если пользователь удаляет символы, позволяем это делать
    if (oldValue.text.length > newValue.text.length) {
      // Сохраняем только префикс +7, если пользователь пытается его удалить
      if (!newValue.text.startsWith('+7')) {
        return const TextEditingValue(
          text: '+7 ',
          selection: TextSelection.collapsed(offset: 3),
        );
      }
      return newValue;
    }

    // Удаляем все нецифровые символы, кроме +
    String digitsOnly = newValue.text.replaceAll(RegExp(r'[^\d+]'), '');

    // Удаляем все символы + кроме первого
    if (digitsOnly.indexOf('+') != digitsOnly.lastIndexOf('+')) {
      digitsOnly = '+${digitsOnly.replaceAll('+', '')}';
    }

    // Обеспечиваем, чтобы номер начинался с +7
    if (!digitsOnly.startsWith('+')) {
      digitsOnly = '+$digitsOnly';
    }
    if (digitsOnly.length > 1 && digitsOnly[1] != '7') {
      digitsOnly = '+7${digitsOnly.substring(1).replaceFirst('7', '')}';
    }

    // Ограничиваем длину до 12 символов (+ и 11 цифр)
    if (digitsOnly.length > 12) {
      digitsOnly = digitsOnly.substring(0, 12);
    }

    // Форматируем номер: +7 (xxx) xxx-xx-xx
    String formattedValue = '';

    if (digitsOnly.length <= 2) {
      formattedValue = '+7 ';
    } else if (digitsOnly.length <= 5) {
      formattedValue = '+7 (${digitsOnly.substring(2)}';
    } else if (digitsOnly.length <= 8) {
      formattedValue =
          '+7 (${digitsOnly.substring(2, 5)}) ${digitsOnly.substring(5)}';
    } else if (digitsOnly.length <= 10) {
      formattedValue =
          '+7 (${digitsOnly.substring(2, 5)}) ${digitsOnly.substring(5, 8)}-${digitsOnly.substring(8)}';
    } else {
      formattedValue =
          '+7 (${digitsOnly.substring(2, 5)}) ${digitsOnly.substring(5, 8)}-${digitsOnly.substring(8, 10)}-${digitsOnly.substring(10)}';
    }

    return TextEditingValue(
      text: formattedValue,
      selection: TextSelection.collapsed(offset: formattedValue.length),
    );
  }
}
