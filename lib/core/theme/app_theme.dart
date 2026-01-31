import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // Colors
  static const Color primary = Color(0xFFF97316); // Vibrant Orange
  static const Color secondary = Color(0xFFFDBA74); // Soft Orange/Yellow
  static const Color cta = Color(0xFF2563EB); // Royal Blue
  static const Color background = Color(0xFFFFF7ED); // Warm Beige
  static const Color text = Color(0xFF1F2937); // Dark Grey/Brown
  static const Color inputBorder = Color(0xFFE2E8F0);
  static const Color white = Colors.white;

  // Spacing
  static const double spaceXS = 4.0;
  static const double spaceSM = 8.0;
  static const double spaceMD = 16.0;
  static const double spaceLG = 24.0;
  static const double spaceXL = 32.0;
  static const double space2XL = 48.0;

  // Shadows
  static List<BoxShadow> get shadowSM => [
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.05),
          offset: const Offset(0, 1),
          blurRadius: 2,
        ),
      ];

  static List<BoxShadow> get shadowMD => [
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.1),
          offset: const Offset(0, 4),
          blurRadius: 6,
        ),
      ];

  static List<BoxShadow> get shadowLG => [
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.1),
          offset: const Offset(0, 10),
          blurRadius: 15,
        ),
      ];

  static ThemeData get theme {
    return ThemeData(
      useMaterial3: true,
      scaffoldBackgroundColor: background,
      primaryColor: primary,
      colorScheme: ColorScheme.fromSeed(
        seedColor: primary,
        primary: primary,
        secondary: secondary,
        surface: white,
        onSurface: text,
      ),
      textTheme: TextTheme(
        displayLarge: GoogleFonts.varelaRound(
          fontSize: 32,
          fontWeight: FontWeight.bold,
          color: text,
        ),
        displayMedium: GoogleFonts.varelaRound(
          fontSize: 28,
          fontWeight: FontWeight.bold,
          color: text,
        ),
        displaySmall: GoogleFonts.varelaRound(
          fontSize: 24,
          fontWeight: FontWeight.bold,
          color: text,
        ),
        headlineMedium: GoogleFonts.varelaRound(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: text,
        ),
        bodyLarge: GoogleFonts.nunitoSans(
          fontSize: 16,
          color: text,
        ),
        bodyMedium: GoogleFonts.nunitoSans(
          fontSize: 14,
          color: text,
        ),
        labelLarge: GoogleFonts.nunitoSans(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: white,
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: white,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: inputBorder, width: 2),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: inputBorder, width: 2),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: primary, width: 3),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: Colors.red, width: 2),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: cta,
          foregroundColor: white,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          textStyle: GoogleFonts.nunitoSans(
            fontWeight: FontWeight.w600,
            fontSize: 16,
          ),
          elevation: 4,
          shadowColor: cta.withValues(alpha: 0.4),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: cta,
          textStyle: GoogleFonts.nunitoSans(
            fontWeight: FontWeight.w600,
            fontSize: 14,
          ),
        ),
      ),
    );
  }
}
