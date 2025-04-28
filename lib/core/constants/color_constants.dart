import 'package:flutter/material.dart';

class ColorConstants {
  // Asosiy ranglar
  static const Color primaryColor =
      Color(0xFF00A3B4); // Asosiy rangi (ko'k-yashil)
  static const Color secondaryColor =
      Color(0xFF2C3E50); // Ikkilamchi rang (to'q ko'k)
  static const Color accentColor =
      Color(0xFFFF8C42); // Ajratuvchi rang (apelsin)

  // Umumiy ranglar
  static const Color backgroundColor =
      Color(0xFFF8F9FA); // Orqa fon rangi (och kul)
  static const Color cardColor = Colors.white; // Karta rangi
  static const Color shadowColor = Color(0x1A000000); // Soya rangi

  // Text ranglar
  static const Color textColor = Color(0xFF2C3E50); // Asosiy matn rangi
  static const Color secondaryTextColor =
      Color(0xFF6C757D); // Ikkilamchi matn rangi
  static const Color hintColor = Color(0xFFADB5BD); // Hint matn rangi

  // Status ranglar
  static const Color successColor = Color(0xFF28A745); // Muvaffaqiyat rangi
  static const Color errorColor = Color(0xFFDC3545); // Xatolik rangi
  static const Color warningColor = Color(0xFFFFC107); // Ogohlantirish rangi
  static const Color infoColor = Color(0xFF17A2B8); // Ma'lumot rangi

  // Chegara va ajratgich
  static const Color borderColor = Color(0xFFDEE2E6); // Chegara rangi
  static const Color dividerColor = Color(0xFFE9ECEF); // Ajratgich rangi

  // Holat ranglari
  static const Color activeColor = primaryColor; // Aktiv holat
  static const Color inactiveColor = Color(0xFFADB5BD); // Aktiv bo'lmagan holat
  static const Color disabledColor = Color(0xFFE9ECEF); // O'chirilgan holat

  // Kategoriya ranglari (doktor turlari uchun)
  static const Color doctorCategory1 = Color(0xFF4BC0C0); // Terapevt
  static const Color doctorCategory2 = Color(0xFF9966FF); // Kardiolog
  static const Color doctorCategory3 = Color(0xFFFF6384); // Xirurg
  static const Color doctorCategory4 = Color(0xFF36A2EB); // Nevrolog
  static const Color doctorCategory5 = Color(0xFFFFCE56); // Pediatr

  // Grafik ranglar
  static const List<Color> chartColors = [
    Color(0xFF4BC0C0),
    Color(0xFF9966FF),
    Color(0xFFFF6384),
    Color(0xFF36A2EB),
    Color(0xFFFFCE56),
  ];

  // Gradient ranglar
  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFF00A3B4),
      Color(0xFF0088A3),
    ],
  );

  static const LinearGradient accentGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFFFF8C42),
      Color(0xFFFF6B2B),
    ],
  );
}
