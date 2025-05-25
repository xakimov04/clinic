// lib/features/auth/presentation/widgets/uzbek_phone_input_formatter.dart
import 'package:flutter/services.dart';

class UzbekPhoneInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    // Agar foydalanuvchi o'chirayotgan bo'lsa, ruxsat berish
    if (oldValue.text.length > newValue.text.length) {
      // +998 prefiksini saqlash
      if (!newValue.text.startsWith('+998')) {
        return const TextEditingValue(
          text: '+998 ',
          selection: TextSelection.collapsed(offset: 5),
        );
      }
      return newValue;
    }

    // Faqat raqamlar va + belgisini qoldirish
    String digitsOnly = newValue.text.replaceAll(RegExp(r'[^\d+]'), '');

    // Bir nechta + belgisini olib tashlash
    if (digitsOnly.indexOf('+') != digitsOnly.lastIndexOf('+')) {
      digitsOnly = '+${digitsOnly.replaceAll('+', '')}';
    }

    // +998 bilan boshlanishini ta'minlash
    if (!digitsOnly.startsWith('+')) {
      digitsOnly = '+$digitsOnly';
    }
    if (digitsOnly.length > 1 && !digitsOnly.startsWith('+998')) {
      // Agar 998 bilan boshlanmasa, uni qo'shish
      if (digitsOnly.startsWith('+')) {
        String numbers = digitsOnly.substring(1);
        if (!numbers.startsWith('998')) {
          // Agar raqam 998 bilan boshlanmasa, uni qo'shish
          digitsOnly = '+998$numbers';
        }
      }
    }

    // Uzunlikni cheklash (+ va 12 raqam)
    if (digitsOnly.length > 13) {
      digitsOnly = digitsOnly.substring(0, 13);
    }

    // Formatni qo'llash: +998 (XX) XXX-XX-XX
    String formattedValue = '';

    if (digitsOnly.length <= 4) {
      formattedValue = '+998 ';
    } else if (digitsOnly.length <= 6) {
      formattedValue = '+998 (${digitsOnly.substring(4)}';
    } else if (digitsOnly.length <= 9) {
      formattedValue =
          '+998 (${digitsOnly.substring(4, 6)}) ${digitsOnly.substring(6)}';
    } else if (digitsOnly.length <= 11) {
      formattedValue =
          '+998 (${digitsOnly.substring(4, 6)}) ${digitsOnly.substring(6, 9)}-${digitsOnly.substring(9)}';
    } else {
      formattedValue =
          '+998 (${digitsOnly.substring(4, 6)}) ${digitsOnly.substring(6, 9)}-${digitsOnly.substring(9, 11)}-${digitsOnly.substring(11)}';
    }

    return TextEditingValue(
      text: formattedValue,
      selection: TextSelection.collapsed(offset: formattedValue.length),
    );
  }
}