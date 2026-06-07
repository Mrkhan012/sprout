import 'package:flutter/material.dart';

/// Sprout brand palette.
///
/// Every value here is sampled directly from the Sprout introduction deck so the
/// app reads as the same product: the deep-navy hero, the gold "Sprout"
/// wordmark, the lavender "what we're looking for" board and the four playful
/// activity-card accents (coral / gold / teal / indigo / pink / sky).
class AppColors {
  AppColors._();

  // ---- Brand neutrals (deck page 1 & 3 — the dark hero) ----------------------
  static const Color navyDeep = Color(0xFF1B1B44);
  static const Color navy = Color(0xFF232456);
  static const Color navySurface = Color(0xFF2E2E66);
  static const Color navyCard = Color(0xFF353574);

  // ---- Brand accents ---------------------------------------------------------
  static const Color gold = Color(0xFFF5C84B); // the "Sprout" wordmark
  static const Color goldDeep = Color(0xFFE7B431);
  static const Color coral = Color(0xFFFF6B6B);
  static const Color teal = Color(0xFF4ECEC0);
  static const Color sky = Color(0xFF7FC4E8);
  static const Color indigo = Color(0xFF5B5FE0);
  static const Color pink = Color(0xFFFF6FA5);

  // ---- Light surfaces (deck page 2 — the lavender board) ---------------------
  static const Color lavenderBg = Color(0xFFEEF1FB);
  static const Color lavenderTint = Color(0xFFE4E2F7);
  static const Color surface = Color(0xFFFFFFFF);

  // ---- Soft icon-circle tints (deck page 2 cards) ----------------------------
  static const Color tintIndigo = Color(0xFFE4E2F7);
  static const Color tintTeal = Color(0xFFD7F2EC);
  static const Color tintCoral = Color(0xFFFBE0E0);
  static const Color tintGold = Color(0xFFFBF0CF);

  // ---- Text ------------------------------------------------------------------
  static const Color ink = Color(0xFF1E2150); // navy headings on light
  static const Color inkSoft = Color(0xFF5A5E86);
  static const Color onDark = Color(0xFFFFFFFF);
  static const Color onDarkSoft = Color(0xFFB9BBE0);

  // ---- Functional ------------------------------------------------------------
  static const Color success = Color(0xFF4ECEC0);
  static const Color star = Color(0xFFFFD23F);

  /// The signature deep-navy hero gradient used on the splash & dark screens.
  static const LinearGradient heroGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [navyDeep, navy, navySurface],
    stops: [0.0, 0.55, 1.0],
  );

  /// The full set of playful accents, in deck order, for cards & avatars.
  static const List<Color> playful = [
    coral,
    gold,
    teal,
    indigo,
    pink,
    sky,
  ];

  /// A soft tint that pairs with each [playful] accent (for icon backings).
  static Color tintFor(Color accent) {
    if (accent == indigo) return tintIndigo;
    if (accent == teal) return tintTeal;
    if (accent == coral || accent == pink) return tintCoral;
    return tintGold;
  }
}
