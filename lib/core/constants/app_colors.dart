import 'package:flutter/material.dart';

class AppColors {
  // Warna Utama (Berlaku untuk Light & Dark Mode)
  static const Color primary = Color(0xFFC48446);
  static const Color accent = Color(0xFFC48446);

  // ==========================================
  // LIGHT MODE COLORS
  // ==========================================
  static const Color bgPaper = Color(0xFFFBFBF9);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color inkText = Color(0xFF2B2B2B);
  static const Color borderCard = Color(0xFFEAEAEA);

  // ==========================================
  // DARK MODE COLORS
  // ==========================================
  static const Color darkBgPaper = Color(0xFF161618);
  static const Color darkSurface = Color(0xFF222225);
  static const Color darkBorder = Color(0xFF333336);

  // ==========================================
  // STATUS COLORS (Opsional, tetap dipertahankan dengan tone yang lebih kalem)
  // ==========================================
  static const Color successText = Color(0xFF2D7A5D);
  static const Color successBg = Color(0xFFE5F0EC);
  static const Color dangerText = Color(0xFFB34D4D);
  static const Color dangerBg = Color(0xFFF5E6E6);
}
