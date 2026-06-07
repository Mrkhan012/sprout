import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/utils/responsive.dart';

/// A small rounded label pill (e.g. the deck's "EARLY STAGE STARTUP" badge or
/// an activity goal banner). Reusable, colour-configurable.
class Pill extends StatelessWidget {
  const Pill({
    super.key,
    required this.text,
    this.background = AppColors.gold,
    this.foreground = AppColors.navy,
    this.icon,
  });

  final String text;
  final Color background;
  final Color foreground;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    final r = context.r;
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: r.scale(16),
        vertical: r.scale(8),
      ),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(r.scale(30)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: r.font(16), color: foreground),
            SizedBox(width: r.scale(6)),
          ],
          Text(
            text,
            style: AppTextStyles.label(color: foreground, size: r.font(12)),
          ),
        ],
      ),
    );
  }
}
