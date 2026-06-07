import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'app_colors.dart';
import 'app_text_styles.dart';

/// Builds the single [ThemeData] that drives Sprout's look & feel.
class AppTheme {
  AppTheme._();

  static ThemeData get light {
    final base = ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      scaffoldBackgroundColor: AppColors.lavenderBg,
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.indigo,
        primary: AppColors.indigo,
        secondary: AppColors.gold,
        surface: AppColors.surface,
        brightness: Brightness.light,
      ),
    );

    return base.copyWith(
      textTheme: GoogleFonts.nunitoTextTheme(base.textTheme).copyWith(
        displayLarge: AppTextStyles.display(color: AppColors.ink),
        headlineMedium: AppTextStyles.heading(),
        titleLarge: AppTextStyles.title(),
        bodyLarge: AppTextStyles.body(),
        bodyMedium: AppTextStyles.body(size: 14),
        labelLarge: AppTextStyles.label(),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: true,
        iconTheme: IconThemeData(color: AppColors.onDark),
      ),
      splashColor: AppColors.indigo.withValues(alpha: 0.12),
      highlightColor: Colors.transparent,
    );
  }
}
