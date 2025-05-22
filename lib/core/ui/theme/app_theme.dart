// lib/core/theme/app_theme.dart
import 'package:flutter/material.dart';
import 'package:clinic/core/constants/color_constants.dart';

class AppTheme {
  // Singleton pattern
  static final AppTheme _instance = AppTheme._internal();

  factory AppTheme() {
    return _instance;
  }

  AppTheme._internal();

  // Light tema
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      primaryColor: ColorConstants.primaryColor,
      scaffoldBackgroundColor: ColorConstants.backgroundColor,
      fontFamily: 'Roboto',
      pageTransitionsTheme: PageTransitionsTheme(
        builders: {
          TargetPlatform.android: const FadeUpwardsPageTransitionsBuilder(),
          TargetPlatform.iOS: FadeForwardsPageTransitionsBuilder(),
        },
      ),
      // AppBar tema
      appBarTheme: const AppBarTheme(
        backgroundColor: ColorConstants.backgroundColor,
        elevation: 0,
        centerTitle: true,
        iconTheme: IconThemeData(
          color: ColorConstants.textColor,
        ),
        titleTextStyle: TextStyle(
          color: ColorConstants.textColor,
          fontSize: 18,
          fontWeight: FontWeight.w600,
        ),
      ),

      // Buttonlar temasi
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: ColorConstants.primaryColor,
          foregroundColor: Colors.white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 24),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),

      // Text buttonlar
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: ColorConstants.primaryColor,
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),

      // Input dekoratsiyasi
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(
            width: 1,
            color: ColorConstants.borderColor,
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(
            width: 1,
            color: ColorConstants.borderColor,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(
            width: 1.5,
            color: ColorConstants.primaryColor,
          ),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(
            width: 1,
            color: ColorConstants.errorColor,
          ),
        ),
        hintStyle: const TextStyle(
          color: ColorConstants.hintColor,
          fontSize: 14,
        ),
      ),

      // Card temasi
      cardTheme: CardTheme(
        color: Colors.white,
        elevation: 2,
        shadowColor: ColorConstants.shadowColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),

      // Bottom Navigation Bar
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: Colors.white,
        selectedItemColor: ColorConstants.primaryColor,
        unselectedItemColor: ColorConstants.inactiveColor,
        selectedLabelStyle: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
        unselectedLabelStyle: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w400,
        ),
        elevation: 8,
      ),

      // Chip dizayni
      chipTheme: ChipThemeData(
        backgroundColor: ColorConstants.secondaryColor.withValues(alpha: 0.1),
        selectedColor: ColorConstants.primaryColor,
        disabledColor: ColorConstants.disabledColor,
        labelStyle: const TextStyle(
          color: ColorConstants.textColor,
          fontSize: 14,
        ),
        secondaryLabelStyle: const TextStyle(
          color: Colors.white,
          fontSize: 14,
        ),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),

      // Switch dizayni
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return ColorConstants.primaryColor;
          }
          return ColorConstants.inactiveColor;
        }),
        trackColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return ColorConstants.primaryColor.withValues(alpha: 0.5);
          }
          return ColorConstants.inactiveColor.withValues(alpha: 0.3);
        }),
      ),

      // Dialog dizayni
      dialogTheme: DialogTheme(
        backgroundColor: Colors.white,
        elevation: 8,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),

      // Divider ranggi
      dividerTheme: const DividerThemeData(
        color: ColorConstants.borderColor,
        thickness: 1,
        space: 24,
      ),

      // Text temasi
      textTheme: const TextTheme(
        displayLarge: TextStyle(
          fontSize: 32,
          fontWeight: FontWeight.bold,
          color: ColorConstants.textColor,
        ),
        displayMedium: TextStyle(
          fontSize: 28,
          fontWeight: FontWeight.bold,
          color: ColorConstants.textColor,
        ),
        displaySmall: TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.bold,
          color: ColorConstants.textColor,
        ),
        headlineMedium: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: ColorConstants.textColor,
        ),
        titleLarge: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: ColorConstants.textColor,
        ),
        titleMedium: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: ColorConstants.textColor,
        ),
        titleSmall: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: ColorConstants.textColor,
        ),
        bodyLarge: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.normal,
          color: ColorConstants.textColor,
        ),
        bodyMedium: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.normal,
          color: ColorConstants.textColor,
        ),
        bodySmall: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.normal,
          color: ColorConstants.secondaryTextColor,
        ),
      ),

      // Tooltip dizayni
      tooltipTheme: TooltipThemeData(
        decoration: BoxDecoration(
          color: ColorConstants.textColor,
          borderRadius: BorderRadius.circular(8),
        ),
        textStyle: const TextStyle(
          color: Colors.white,
          fontSize: 12,
        ),
      ),
    );
  }
}
