import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import 'bouncy_tap.dart';

/// A round, chunky back button sized for little fingers. Reused on activity
/// screens. Pops the current route by default.
class AppBackButton extends StatelessWidget {
  const AppBackButton({
    super.key,
    this.onTap,
    this.color = AppColors.onDark,
    this.background,
  });

  final VoidCallback? onTap;
  final Color color;
  final Color? background;

  @override
  Widget build(BuildContext context) {
    return BouncyTap(
      onTap: onTap ?? () => Navigator.of(context).maybePop(),
      child: Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          color: background ?? AppColors.onDark.withValues(alpha: 0.12),
          shape: BoxShape.circle,
        ),
        child: Icon(Icons.arrow_back_rounded, color: color, size: 26),
      ),
    );
  }
}
