import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // ── Brand palette ────────────────────────────────────────────────────────
  static const Color creamColor     = Color(0xFFF5F1E8);
  static const Color goldColor      = Color(0xFFD4AF37);
  static const Color goldLight      = Color(0xFFF0E4A8);
  static const Color darkGreen      = Color(0xFF1A4D2E);
  static const Color darkGreenLight = Color(0xFF2A6B42);
  static const Color blackText      = Color(0xFF2D2D2D);
  static const Color greyText       = Color(0xFF757575);

  // ── Dark palette ──────────────────────────────────────────────────────────
  static const Color darkBackground = Color(0xFF0F0F0F);
  static const Color darkSurface    = Color(0xFF1A1A1A);
  static const Color darkCard       = Color(0xFF222222);
  static const Color darkElevated   = Color(0xFF2A2A2A);
  static const Color darkText       = Color(0xFFEDE8DC);
  static const Color darkSubtitle   = Color(0xFF9E9E9E);

  // ── Typography ────────────────────────────────────────────────────────────
  static TextStyle get arabicText => const TextStyle(
    fontFamily: 'KFGQPC Uthmanic Script HAFS',
    fontSize: 28,
    color: blackText,
    height: 2.0,
  );

  static TextStyle get displayStyle => GoogleFonts.poppins(
    fontSize: 26,
    fontWeight: FontWeight.bold,
    color: blackText,
  );

  static TextStyle get headingStyle => GoogleFonts.poppins(
    fontSize: 22,
    fontWeight: FontWeight.bold,
    color: blackText,
  );

  static TextStyle get titleStyle => GoogleFonts.poppins(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    color: blackText,
  );

  static TextStyle get bodyStyle => GoogleFonts.poppins(
    fontSize: 14,
    color: blackText,
    height: 1.5,
  );

  static TextStyle get subtitleStyle => GoogleFonts.poppins(
    fontSize: 12,
    color: greyText,
  );

  static TextStyle get labelStyle => GoogleFonts.poppins(
    fontSize: 11,
    fontWeight: FontWeight.w500,
    color: greyText,
    letterSpacing: 0.4,
  );

  // ── Light theme ───────────────────────────────────────────────────────────
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
      textTheme: GoogleFonts.poppinsTextTheme().copyWith(
        displayLarge: headingStyle,
        titleLarge: titleStyle,
        bodyLarge: bodyStyle,
        bodyMedium: subtitleStyle,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        scrolledUnderElevation: 0,
        iconTheme: const IconThemeData(color: blackText),
        titleTextStyle: GoogleFonts.poppins(
          fontSize: 18,
          fontWeight: FontWeight.w700,
          color: blackText,
        ),
        systemOverlayStyle: SystemUiOverlayStyle.dark,
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: Colors.white,
        indicatorColor: goldColor.withOpacity(0.15),
        iconTheme: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return const IconThemeData(color: goldColor, size: 24);
          }
          return IconThemeData(color: greyText.withOpacity(0.8), size: 22);
        }),
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return GoogleFonts.poppins(
              fontSize: 11, fontWeight: FontWeight.w600, color: goldColor);
          }
          return GoogleFonts.poppins(
            fontSize: 11, fontWeight: FontWeight.w500, color: greyText);
        }),
        height: 64,
        elevation: 0,
        shadowColor: Colors.black26,
        surfaceTintColor: Colors.transparent,
      ),
      cardTheme: CardThemeData(
        color: Colors.white,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: goldColor.withOpacity(0.18), width: 1),
        ),
        margin: const EdgeInsets.symmetric(vertical: 5, horizontal: 16),
      ),
      dividerTheme: DividerThemeData(
        color: Colors.grey.shade200,
        thickness: 1,
        space: 1,
      ),
      listTileTheme: ListTileThemeData(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        titleTextStyle: bodyStyle,
        subtitleTextStyle: subtitleStyle,
        iconColor: goldColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
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
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: goldColor,
          foregroundColor: Colors.white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          textStyle: GoogleFonts.poppins(fontWeight: FontWeight.w600, fontSize: 14),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: goldColor,
          textStyle: GoogleFonts.poppins(fontWeight: FontWeight.w600, fontSize: 14),
        ),
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        contentTextStyle: GoogleFonts.poppins(fontSize: 13),
      ),
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
    );
  }

  // ── Dark theme ────────────────────────────────────────────────────────────
  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      scaffoldBackgroundColor: darkBackground,
      primaryColor: goldColor,
      colorScheme: ColorScheme.fromSeed(
        seedColor: goldColor,
        brightness: Brightness.dark,
        primary: goldColor,
        secondary: darkGreenLight,
        surface: darkSurface,
        onPrimary: Colors.black,
        onSurface: darkText,
      ),
      textTheme: GoogleFonts.poppinsTextTheme(ThemeData.dark().textTheme).copyWith(
        displayLarge: headingStyle.copyWith(color: darkText),
        titleLarge: titleStyle.copyWith(color: darkText),
        bodyLarge: bodyStyle.copyWith(color: darkText),
        bodyMedium: subtitleStyle.copyWith(color: darkSubtitle),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        scrolledUnderElevation: 0,
        iconTheme: const IconThemeData(color: darkText),
        titleTextStyle: GoogleFonts.poppins(
          fontSize: 18,
          fontWeight: FontWeight.w700,
          color: darkText,
        ),
        systemOverlayStyle: SystemUiOverlayStyle.light,
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: darkSurface,
        indicatorColor: goldColor.withOpacity(0.2),
        iconTheme: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return const IconThemeData(color: goldColor, size: 24);
          }
          return const IconThemeData(color: darkSubtitle, size: 22);
        }),
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return GoogleFonts.poppins(
              fontSize: 11, fontWeight: FontWeight.w600, color: goldColor);
          }
          return GoogleFonts.poppins(
            fontSize: 11, fontWeight: FontWeight.w500, color: darkSubtitle);
        }),
        height: 64,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
      ),
      cardTheme: CardThemeData(
        color: darkCard,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: goldColor.withOpacity(0.12), width: 1),
        ),
        margin: const EdgeInsets.symmetric(vertical: 5, horizontal: 16),
      ),
      dividerTheme: const DividerThemeData(
        color: Color(0xFF2E2E2E),
        thickness: 1,
        space: 1,
      ),
      listTileTheme: ListTileThemeData(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        textColor: darkText,
        iconColor: goldColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
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
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: goldColor,
          foregroundColor: Colors.black,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          textStyle: GoogleFonts.poppins(fontWeight: FontWeight.w600, fontSize: 14),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: goldColor,
          textStyle: GoogleFonts.poppins(fontWeight: FontWeight.w600, fontSize: 14),
        ),
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: darkElevated,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        contentTextStyle: GoogleFonts.poppins(fontSize: 13, color: darkText),
      ),
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
    );
  }
}
