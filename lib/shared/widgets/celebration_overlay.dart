import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/utils/responsive.dart';
import 'primary_button.dart';
import 'star_burst.dart';

/// A celebratory "well done!" panel shown when an activity is completed.
///
/// Reused by Tap & Play (Task 2) and Nature Hunt (Task 4): a dimmed backdrop, a
/// bursting star animation, a big emoji, a reward line and a primary action.
class CelebrationOverlay extends StatelessWidget {
  const CelebrationOverlay({
    super.key,
    required this.emoji,
    required this.title,
    required this.message,
    required this.buttonLabel,
    required this.onButton,
    this.accent = AppColors.gold,
    this.secondaryLabel,
    this.onSecondary,
  });

  final String emoji;
  final String title;
  final String message;
  final String buttonLabel;
  final VoidCallback onButton;
  final Color accent;
  final String? secondaryLabel;
  final VoidCallback? onSecondary;

  @override
  Widget build(BuildContext context) {
    final r = context.r;
    return Container(
      color: AppColors.navyDeep.withValues(alpha: 0.6),
      child: Center(
        child: TweenAnimationBuilder<double>(
          duration: const Duration(milliseconds: 450),
          curve: Curves.elasticOut,
          tween: Tween(begin: 0, end: 1),
          builder: (context, value, child) => Transform.scale(
            scale: value.clamp(0.0, 1.0),
            child: child,
          ),
          child: Stack(
            alignment: Alignment.center,
            clipBehavior: Clip.none,
            children: [
              const Positioned.fill(
                child: Center(child: StarBurst(size: 320)),
              ),
              Container(
                margin: EdgeInsets.all(r.scale(28)),
                padding: EdgeInsets.all(r.scale(28)),
                constraints: const BoxConstraints(maxWidth: 360),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(r.scale(28)),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(emoji, style: TextStyle(fontSize: r.font(64))),
                    SizedBox(height: r.scale(8)),
                    Text(
                      title,
                      textAlign: TextAlign.center,
                      style: AppTextStyles.heading(size: r.font(26)),
                    ),
                    SizedBox(height: r.scale(8)),
                    Text(
                      message,
                      textAlign: TextAlign.center,
                      style: AppTextStyles.body(size: r.font(15)),
                    ),
                    SizedBox(height: r.scale(22)),
                    PrimaryButton(
                      label: buttonLabel,
                      icon: Icons.celebration_rounded,
                      color: accent,
                      foreground: AppColors.navy,
                      expand: true,
                      onPressed: onButton,
                    ),
                    if (secondaryLabel != null && onSecondary != null) ...[
                      SizedBox(height: r.scale(10)),
                      TextButton(
                        onPressed: onSecondary,
                        child: Text(
                          secondaryLabel!,
                          style: AppTextStyles.button(
                            color: AppColors.inkSoft,
                            size: r.font(15),
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
