import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/constants/app_colors.dart';

class AppTheme {
  // ==========================================
  // LIGHT MODE CONFIGURATION
  // ==========================================
  static ThemeData get lightTheme {
    final baseTextTheme = GoogleFonts.plusJakartaSansTextTheme();

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      scaffoldBackgroundColor: AppColors.bgPaper,

      colorScheme: const ColorScheme.light(
        primary: AppColors.primary,
        secondary: AppColors.accent,
        surface: AppColors.surface,
        onSurface: AppColors.inkText,
        error: AppColors.dangerText,
      ),

      textTheme: baseTextTheme.copyWith(
        displayLarge: GoogleFonts.fraunces(
          color: AppColors.inkText,
          fontWeight: FontWeight.w700,
        ),
        bodyLarge: baseTextTheme.bodyLarge?.copyWith(color: AppColors.inkText),
        bodyMedium: baseTextTheme.bodyMedium?.copyWith(
          color: AppColors.inkText,
        ),
      ),

      cardTheme: CardThemeData(
        color: AppColors.surface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: const BorderSide(color: AppColors.borderCard, width: 0.5),
        ),
      ),

      inputDecorationTheme: InputDecorationTheme(
        fillColor: AppColors.surface,
        filled: true,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: AppColors.borderCard, width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
        ),
      ),
    );
  }

  // ==========================================
  // DARK MODE CONFIGURATION
  // ==========================================
  static ThemeData get darkTheme {
    final baseTextTheme = GoogleFonts.plusJakartaSansTextTheme(
      ThemeData.dark().textTheme,
    );

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      // Kertas gelap kehijauan (#1B1E17) untuk latar layar
      scaffoldBackgroundColor: AppColors.darkBgPaper,

      colorScheme: const ColorScheme.dark(
        primary: AppColors.primary,
        secondary: AppColors.accent, // Aksen amber tetap dipertahankan
        surface: AppColors.darkSurface, // Kartu/Form menggunakan #242920
        onSurface: AppColors
            .bgPaper, // Teks menggunakan warna krem terang agar kontras
        error: AppColors.dangerText,
      ),

      textTheme: baseTextTheme.copyWith(
        displayLarge: GoogleFonts.fraunces(
          color: AppColors.bgPaper,
          fontWeight: FontWeight.w700,
        ),
        bodyLarge: baseTextTheme.bodyLarge?.copyWith(color: AppColors.bgPaper),
        bodyMedium: baseTextTheme.bodyMedium?.copyWith(
          color: AppColors.bgPaper,
        ),
      ),

      cardTheme: CardThemeData(
        color: AppColors.darkSurface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          // Menggunakan opacity tipis agar border kartu di dark mode tidak terlalu mencolok
          side: BorderSide(
            color: AppColors.bgPaper.withValues(alpha: 0.1),
            width: 0.5,
          ),
        ),
      ),

      inputDecorationTheme: InputDecorationTheme(
        fillColor: AppColors.darkSurface,
        filled: true,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(
            color: AppColors.bgPaper.withValues(alpha: 0.1),
            width: 1,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: AppColors.accent, width: 1.5),
        ),
      ),
    );
  }
}
