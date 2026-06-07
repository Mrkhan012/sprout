import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'app_colors.dart';

/// Typography for Sprout.
///
/// The deck pairs a bold display face with a clean body face. For a kids' app
/// we lean into a rounded, friendly display (Fredoka) over a highly legible
/// body (Nunito) — playful but still readable for early readers and parents.
class AppTextStyles {
  AppTextStyles._();

  static TextStyle display({Color color = AppColors.onDark, double size = 48}) =>
      GoogleFonts.fredoka(
        fontSize: size,
        fontWeight: FontWeight.w700,
        color: color,
        height: 1.05,
        letterSpacing: -0.5,
      );

  static TextStyle heading({Color color = AppColors.ink, double size = 26}) =>
      GoogleFonts.fredoka(
        fontSize: size,
        fontWeight: FontWeight.w600,
        color: color,
        height: 1.15,
      );

  static TextStyle title({Color color = AppColors.ink, double size = 20}) =>
      GoogleFonts.fredoka(
        fontSize: size,
        fontWeight: FontWeight.w600,
        color: color,
      );

  static TextStyle body({Color color = AppColors.inkSoft, double size = 16}) =>
      GoogleFonts.nunito(
        fontSize: size,
        fontWeight: FontWeight.w600,
        color: color,
        height: 1.4,
      );

  static TextStyle label({Color color = AppColors.inkSoft, double size = 13}) =>
      GoogleFonts.nunito(
        fontSize: size,
        fontWeight: FontWeight.w700,
        color: color,
        letterSpacing: 1.2,
      );

  static TextStyle button({Color color = AppColors.onDark, double size = 18}) =>
      GoogleFonts.fredoka(
        fontSize: size,
        fontWeight: FontWeight.w600,
        color: color,
        letterSpacing: 0.2,
      );
}
