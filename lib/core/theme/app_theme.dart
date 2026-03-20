import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class AppTheme {
  // ── Light palette ────────────────────────────────────────────────────────
  static const Color creamColor = Color(0xFFF5F1E8);
  static const Color goldColor  = Color(0xFFD4AF37);
  static const Color darkGreen  = Color(0xFF1A4D2E);
  static const Color blackText  = Color(0xFF2D2D2D);
  static const Color greyText   = Color(0xFF757575);

  // ── Dark palette ─────────────────────────────────────────────────────────
  static const Color darkBackground = Color(0xFF121212);
  static const Color darkSurface    = Color(0xFF1E1E1E);
  static const Color darkCard       = Color(0xFF252525);
  static const Color darkText       = Color(0xFFEDE8DC);
  static const Color darkSubtitle   = Color(0xFF9E9E9E);

  // ── Typography ───────────────────────────────────────────────────────────
  static TextStyle get arabicText => const TextStyle(
    fontFamily: 'KFGQPC Uthmanic Script HAFS',
    fontSize: 28,
    color: blackText,
    height: 2.0,
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

  // ── Light theme ──────────────────────────────────────────────────────────
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      scaffoldBackgroundColor: creamColor,
      primaryColor: goldColor,
      colorScheme: ColorScheme.fromSeed(
        seedColor: goldColor,
        brightness: Brightness.light,
        primary: goldColor,
        secondary: darkGreen,
        surface: Colors.white,
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
        unselectedItemColor: greyText,
        selectedLabelStyle: TextStyle(fontWeight: FontWeight.w600, fontSize: 12),
        unselectedLabelStyle: TextStyle(fontWeight: FontWeight.w500, fontSize: 12),
        elevation: 0, // shadow is handled in MainScreen via BoxShadow container
      ),
      cardTheme: CardThemeData(
        color: Colors.white,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(color: goldColor.withOpacity(0.2), width: 1),
        ),
        margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 16),
      ),
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith(
          (s) => s.contains(WidgetState.selected) ? goldColor : Colors.white,
        ),
        trackColor: WidgetStateProperty.resolveWith(
          (s) => s.contains(WidgetState.selected)
              ? goldColor.withOpacity(0.4)
              : Colors.grey.shade300,
        ),
      ),
      textTheme: TextTheme(
        displayLarge: headingStyle,
        titleLarge: titleStyle,
        bodyLarge: bodyStyle,
        bodyMedium: subtitleStyle,
      ),
    );
  }

  // ── Dark theme ───────────────────────────────────────────────────────────
  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      scaffoldBackgroundColor: darkBackground,
      primaryColor: goldColor,
      colorScheme: ColorScheme.fromSeed(
        seedColor: goldColor,
        brightness: Brightness.dark,
        primary: goldColor,
        secondary: const Color(0xFF4CAF82),
        surface: darkSurface,
        onPrimary: Colors.black,
        onSurface: darkText,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: darkBackground,
        elevation: 0,
        centerTitle: true,
        iconTheme: const IconThemeData(color: darkText),
        titleTextStyle: headingStyle.copyWith(fontSize: 20, color: darkText),
        systemOverlayStyle: SystemUiOverlayStyle.light,
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: darkSurface,
        selectedItemColor: goldColor,
        unselectedItemColor: darkSubtitle,
        selectedLabelStyle: TextStyle(fontWeight: FontWeight.w600, fontSize: 12),
        unselectedLabelStyle: TextStyle(fontWeight: FontWeight.w500, fontSize: 12),
        elevation: 0,
      ),
      cardTheme: CardThemeData(
        color: darkCard,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(color: goldColor.withOpacity(0.15), width: 1),
        ),
        margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 16),
      ),
      dividerTheme: const DividerThemeData(color: Color(0xFF333333)),
      listTileTheme: const ListTileThemeData(
        textColor: darkText,
        iconColor: goldColor,
      ),
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith(
          (s) => s.contains(WidgetState.selected) ? goldColor : Colors.white70,
        ),
        trackColor: WidgetStateProperty.resolveWith(
          (s) => s.contains(WidgetState.selected)
              ? goldColor.withOpacity(0.4)
              : Colors.white24,
        ),
      ),
      textTheme: TextTheme(
        displayLarge: headingStyle.copyWith(color: darkText),
        titleLarge: titleStyle.copyWith(color: darkText),
        bodyLarge: bodyStyle.copyWith(color: darkText),
        bodyMedium: subtitleStyle.copyWith(color: darkSubtitle),
      ),
    );
  }
}
