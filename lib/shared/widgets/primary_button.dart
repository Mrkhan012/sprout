import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/utils/responsive.dart';
import 'bouncy_tap.dart';

/// The big, chunky, child-friendly call-to-action button used across the app.
///
/// A reusable widget: pass a [label], an optional [icon] and a [color]; it
/// handles the bounce, the drop-shadow "pillow" look and a disabled state.
class PrimaryButton extends StatelessWidget {
  const PrimaryButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon,
    this.color = AppColors.indigo,
    this.foreground = AppColors.onDark,
    this.expand = false,
  });

  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final Color color;
  final Color foreground;
  final bool expand;

  @override
  Widget build(BuildContext context) {
    final r = context.r;
    final enabled = onPressed != null;

    final button = AnimatedOpacity(
      duration: const Duration(milliseconds: 150),
      opacity: enabled ? 1 : 0.5,
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: r.scale(28),
          vertical: r.scale(16),
        ),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(r.scale(22)),
          boxShadow: [
            BoxShadow(
              color: color.withValues(alpha: 0.45),
              blurRadius: 18,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: expand ? MainAxisSize.max : MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (icon != null) ...[
              Icon(icon, color: foreground, size: r.font(24)),
              SizedBox(width: r.scale(10)),
            ],
            Flexible(
              child: Text(
                label,
                textAlign: TextAlign.center,
                style: AppTextStyles.button(
                  color: foreground,
                  size: r.font(18),
                ),
              ),
            ),
          ],
        ),
      ),
    );

    return BouncyTap(
      onTap: enabled ? onPressed : null,
      child: button,
    );
  }
}
