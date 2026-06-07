import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/utils/responsive.dart';

/// The framed "value over label" chips from the deck's hero
/// (e.g. "3–8 yrs / Target age"). Reusable stat pill on dark backgrounds.
class StatChip extends StatelessWidget {
  const StatChip({
    super.key,
    required this.value,
    required this.label,
    this.accent = AppColors.gold,
  });

  final String value;
  final String label;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    final r = context.r;
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: r.scale(16),
        vertical: r.scale(14),
      ),
      decoration: BoxDecoration(
        color: AppColors.onDark.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(r.scale(16)),
        border: Border.all(color: accent.withValues(alpha: 0.5), width: 1.4),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            value,
            textAlign: TextAlign.center,
            style: AppTextStyles.title(color: AppColors.onDark, size: r.font(17)),
          ),
          SizedBox(height: r.scale(4)),
          Text(
            label,
            textAlign: TextAlign.center,
            style: AppTextStyles.body(
              color: AppColors.onDarkSoft,
              size: r.font(12),
            ),
          ),
        ],
      ),
    );
  }
}
