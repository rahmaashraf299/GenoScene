import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

/// Semantic text styles for GenoScene.
/// Usage: `style: AppTypography.titleLarge`
abstract class AppTypography {
  // ── Display ──
  static final TextStyle displayXl = GoogleFonts.poppins(
    fontSize: 28,
    fontWeight: FontWeight.bold,
    color: AppColors.textPrimary,
    letterSpacing: -0.5,
  );

  static final TextStyle displayLarge = GoogleFonts.poppins(
    fontSize: 22,
    fontWeight: FontWeight.bold,
    color: AppColors.textPrimary,
    letterSpacing: -0.3,
  );

  static final TextStyle displaySmall = GoogleFonts.poppins(
    fontSize: 18,
    fontWeight: FontWeight.w700,
    color: AppColors.textPrimary,
  );

  // ── Titles ──
  static final TextStyle titleLarge = GoogleFonts.poppins(
    fontSize: 17,
    fontWeight: FontWeight.w700,
    color: AppColors.textPrimary,
    letterSpacing: -0.2,
  );

  static final TextStyle titleMedium = GoogleFonts.poppins(
    fontSize: 15,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
  );

  static final TextStyle titleSmall = GoogleFonts.poppins(
    fontSize: 13,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
  );

  // ── Body ──
  static final TextStyle bodyLarge = GoogleFonts.poppins(
    fontSize: 14,
    fontWeight: FontWeight.w500,
    color: AppColors.textPrimary,
    height: 1.5,
  );

  static final TextStyle bodyMedium = GoogleFonts.poppins(
    fontSize: 13,
    color: AppColors.textSecondary,
    height: 1.5,
  );

  static final TextStyle bodySmall = GoogleFonts.poppins(
    fontSize: 12,
    color: AppColors.textSecondary,
    height: 1.5,
  );

  // ── Labels ──
  static final TextStyle labelLarge = GoogleFonts.poppins(
    fontSize: 12,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
  );

  static final TextStyle labelMedium = GoogleFonts.poppins(
    fontSize: 11,
    fontWeight: FontWeight.w500,
    color: AppColors.textSecondary,
  );

  static final TextStyle labelSmall = GoogleFonts.poppins(
    fontSize: 10,
    fontWeight: FontWeight.w500,
    color: AppColors.textTertiary,
  );

  // ── Caption ──
  static final TextStyle caption = GoogleFonts.poppins(
    fontSize: 9,
    color: AppColors.textTertiary,
  );

  // ── Section header ──
  static final TextStyle sectionHeader = GoogleFonts.poppins(
    fontSize: 16,
    fontWeight: FontWeight.w700,
    color: AppColors.textPrimary,
    letterSpacing: -0.1,
  );

  // ── Mono (SNP IDs, code) ──
  static final TextStyle mono = GoogleFonts.sourceCodePro(
    fontSize: 11,
    fontWeight: FontWeight.w700,
    color: AppColors.textPrimary,
  );

  // ── Badge / Chip text ──
  static final TextStyle badge = GoogleFonts.poppins(
    fontSize: 10,
    fontWeight: FontWeight.w700,
    color: AppColors.primary,
    letterSpacing: 0.3,
  );
}
