import 'package:flutter/material.dart';

class ColorConstants {
  // Основные цвета, определённые клиентом
  static const Color primaryColor = Color(0xFF6E89DB); // Asosiy ko'k rang
  static const Color secondaryColor = Color(0xFFEBECF6); // Kulrang (yordamchi)
  static const Color accentGreen =
      Color.fromARGB(255, 134, 212, 88); // Yashil (yordamchi)
  static const Color accentRed = Color(0xFFD35A63); // Qizil (yordamchi)
  static const Color accentYellow = Color(0xFFF7BD77); // Sariq (yordamchi)

  // Общие цвета
  static const Color backgroundColor = Color(0xFFF8F9FA); // Orqa fon rangi
  static const Color cardColor = Colors.white; // Karta rangi
  static const Color shadowColor = Color(0x1A000000); // Soya rangi

  // Цвета текста
  static const Color textColor = Color(0xFF2C3E50); // Asosiy matn rangi
  static const Color secondaryTextColor =
      Color(0xFF6C757D); // Ikkilamchi matn rangi
  static const Color hintColor = Color(0xFFADB5BD); // Hint matn rangi

  // Цвета статусов (используются цвета клиента)
  static const Color successColor = accentGreen; // Muvaffaqiyat rangi (yashil)
  static const Color errorColor = accentRed; // Xatolik rangi (qizil)
  static const Color warningColor = accentYellow; // Ogohlantirish rangi (sariq)
  static const Color infoColor = primaryColor; // Ma'lumot rangi (asosiy ko'k)

  // Границы и разделители
  static const Color borderColor = Color(0xFFDEE2E6); // Chegara rangi
  static const Color dividerColor = secondaryColor; // Ajratgich rangi (kulrang)

  // Состояния
  static const Color activeColor = primaryColor; // Aktiv holat
  static const Color inactiveColor = Color(0xFFADB5BD); // Aktiv bo'lmagan holat
  static const Color disabledColor =
      secondaryColor; // O'chirilgan holat (kulrang)

  // Цвета категорий (для типов врачей)
  static const Color doctorCategory1 = primaryColor; // Asosiy ko'k
  static const Color doctorCategory2 = accentGreen; // Yashil
  static const Color doctorCategory3 = accentRed; // Qizil
  static const Color doctorCategory4 = accentYellow; // Sariq
  static const Color doctorCategory5 = secondaryColor; // Kulrang

  // Цвета для графиков
  static const List<Color> chartColors = [
    primaryColor,
    accentGreen,
    accentRed,
    accentYellow,
    secondaryColor,
  ];

  // Градиенты
  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFF6E89DB),
      Color(0xFF5870D3),
    ],
  );

  static const LinearGradient accentGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFF9EDF77),
      Color(0xFF8DD965),
    ],
  );

  // Дополнительные градиенты
  static const LinearGradient redGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFFD35A63),
      Color(0xFFCB4A53),
    ],
  );

  static const LinearGradient yellowGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFFF7BD77),
      Color(0xFFF5B265),
    ],
  );
}
