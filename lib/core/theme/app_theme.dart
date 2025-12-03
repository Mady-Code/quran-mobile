import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // Colors
  static const Color primaryColor = Color(0xFF00695C); // Deep Teal
  static const Color secondaryColor = Color(0xFFB2DFDB); // Light Teal
  static const Color accentColor = Color(0xFFD4AF37); // Gold
  static const Color backgroundColor = Color(0xFFF8F5F2); // Cream/Off-white
  static const Color surfaceColor = Colors.white;
  static const Color errorColor = Color(0xFFB00020);

  // Text Styles
  static TextStyle get arabicText => const TextStyle(
        fontFamily: 'KFGQPC Uthmanic Script HAFS',
        fontSize: 24,
        color: Colors.black,
        height: 1.5,
      );

  static TextStyle get headingStyle => GoogleFonts.outfit(
        fontSize: 24,
        fontWeight: FontWeight.bold,
        color: primaryColor,
      );

  static TextStyle get bodyStyle => GoogleFonts.outfit(
        fontSize: 16,
        color: Colors.black87,
      );

  static TextStyle get subtitleStyle => GoogleFonts.outfit(
        fontSize: 14,
        color: Colors.black54,
      );

  // Theme Data
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      primaryColor: primaryColor,
      scaffoldBackgroundColor: backgroundColor,
      colorScheme: ColorScheme.fromSeed(
        seedColor: primaryColor,
        primary: primaryColor,
        secondary: secondaryColor,
        surface: surfaceColor,
        background: backgroundColor,
        error: errorColor,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: backgroundColor,
        elevation: 0,
        centerTitle: true,
        iconTheme: const IconThemeData(color: primaryColor),
        titleTextStyle: headingStyle.copyWith(fontSize: 20),
      ),
      cardTheme: CardTheme(
        color: surfaceColor,
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      ),
      textTheme: TextTheme(
        displayLarge: headingStyle,
        bodyLarge: bodyStyle,
        bodyMedium: subtitleStyle,
      ),
    );
  }
}
