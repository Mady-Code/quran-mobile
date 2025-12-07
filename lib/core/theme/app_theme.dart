import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // Premium Colors
  static const Color creamColor = Color(0xFFF5F1E8); // Background base
  static const Color goldColor = Color(0xFFD4AF37);  // Primary Accent
  static const Color darkGreen = Color(0xFF1A4D2E);  // Secondary Accent (optional, for depth)
  static const Color blackText = Color(0xFF2D2D2D);  // Soft Black
  static const Color greyText = Color(0xFF757575);   // Subtitles

  // Typography
  static TextStyle get arabicText => const TextStyle(
        fontFamily: 'KFGQPC Uthmanic Script HAFS',
        fontSize: 28,
        color: blackText,
        height: 2.0, // Better line height for reading
      );

  static TextStyle get headingStyle => const TextStyle(
        fontSize: 24,
        fontWeight: FontWeight.bold,
        color: blackText,
      );
      
  static TextStyle get titleStyle => const TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        color: blackText,
      );

  static TextStyle get bodyStyle => const TextStyle(
        fontSize: 16,
        color: blackText,
        height: 1.5,
      );

  static TextStyle get subtitleStyle => const TextStyle(
        fontSize: 14,
        color: greyText,
      );

  // Theme Data
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      scaffoldBackgroundColor: creamColor,
      primaryColor: goldColor,
      colorScheme: ColorScheme.fromSeed(
        seedColor: goldColor,
        primary: goldColor,
        secondary: darkGreen,
        surface: Colors.white,
        background: creamColor,
        onPrimary: Colors.white,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: creamColor,
        elevation: 0,
        centerTitle: true,
        iconTheme: const IconThemeData(color: blackText),
        titleTextStyle: headingStyle.copyWith(fontSize: 20),
        systemOverlayStyle: SystemUiOverlayStyle.dark,
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: Colors.white,
        selectedItemColor: goldColor,
        unselectedItemColor: Colors.grey, // Handled implicitly
        selectedLabelStyle: TextStyle(fontWeight: FontWeight.w600, fontSize: 12),
        unselectedLabelStyle: TextStyle(fontWeight: FontWeight.w500, fontSize: 12),
        elevation: 10,
      ),
      cardTheme: CardTheme(
        color: Colors.white,
        elevation: 0, // Flat premium look
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(color: goldColor.withOpacity(0.2), width: 1), // Subtle border
        ),
        margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 16),
      ),
      textTheme: TextTheme(
        displayLarge: headingStyle,
        titleLarge: titleStyle,
        bodyLarge: bodyStyle,
        bodyMedium: subtitleStyle,
      ),
    );
  }
}
