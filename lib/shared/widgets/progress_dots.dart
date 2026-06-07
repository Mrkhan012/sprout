import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/utils/responsive.dart';

/// A row of star "pips" showing progress toward a goal (e.g. 3 of 5 found).
/// Filled stars animate in as [completed] grows. Reusable across activities.
class ProgressDots extends StatelessWidget {
  const ProgressDots({
    super.key,
    required this.total,
    required this.completed,
    this.activeColor = AppColors.gold,
    this.inactiveColor = AppColors.onDarkSoft,
  });

  final int total;
  final int completed;
  final Color activeColor;
  final Color inactiveColor;

  @override
  Widget build(BuildContext context) {
    final r = context.r;
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(total, (i) {
        final filled = i < completed;
        return Padding(
          padding: EdgeInsets.symmetric(horizontal: r.scale(4)),
          child: AnimatedScale(
            duration: const Duration(milliseconds: 300),
            curve: Curves.elasticOut,
            scale: filled ? 1.0 : 0.8,
            child: Icon(
              filled ? Icons.star_rounded : Icons.star_outline_rounded,
              color: filled ? activeColor : inactiveColor.withValues(alpha: 0.5),
              size: r.font(30),
            ),
          ),
        );
      }),
    );
  }
}
