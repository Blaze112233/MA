import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../constants/colors.dart';

class AppTheme {
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      scaffoldBackgroundColor: const Color(0xFFF6F8FA),
      primaryColor: AppColors.primary,
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.primary,
        brightness: Brightness.light,
        surface: Colors.white,
      ),
      cardTheme: CardThemeData(
        color: Colors.white,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(color: Colors.black.withOpacity(0.05)),
        ),
      ),
      textTheme: GoogleFonts.plusJakartaSansTextTheme(ThemeData.light().textTheme),
      appBarTheme: const AppBarTheme(
        backgroundColor: Color(0xFFF6F8FA),
        elevation: 0,
        centerTitle: false,
        scrolledUnderElevation: 0,
        foregroundColor: Color(0xFF1A1C20),
      ),
    );
  }

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: const Color(0xFF101216),
      primaryColor: AppColors.primary,
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.primary,
        brightness: Brightness.dark,
        surface: const Color(0xFF181B20),
      ),
      cardTheme: CardThemeData(
        color: const Color(0xFF181B20),
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(color: Colors.white.withOpacity(0.06)),
        ),
      ),
      textTheme: GoogleFonts.plusJakartaSansTextTheme(ThemeData.dark().textTheme),
      appBarTheme: const AppBarTheme(
        backgroundColor: Color(0xFF101216),
        elevation: 0,
        centerTitle: false,
        scrolledUnderElevation: 0,
        foregroundColor: Colors.white,
      ),
    );
  }
}