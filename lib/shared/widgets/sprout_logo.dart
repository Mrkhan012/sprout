import 'package:flutter/material.dart';

import '../../core/constants/app_strings.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';

/// The Sprout wordmark: a gold sprouting-leaf glyph beside the gold "Sprout"
/// name, matching the deck's hero. Reusable at any [size]; optionally compact
/// (icon + small text) for app bars.
class SproutLogo extends StatelessWidget {
  const SproutLogo({
    super.key,
    this.size = 48,
    this.color = AppColors.gold,
    this.showWordmark = true,
  });

  /// A small horizontal lockup for app bars.
  const SproutLogo.compact({super.key})
      : size = 24,
        color = AppColors.gold,
        showWordmark = true;

  final double size;
  final Color color;
  final bool showWordmark;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(Icons.eco_rounded, color: color, size: size),
        if (showWordmark) ...[
          SizedBox(width: size * 0.22),
          Text(
            AppStrings.appName,
            style: AppTextStyles.display(color: color, size: size * 0.95),
          ),
        ],
      ],
    );
  }
}
