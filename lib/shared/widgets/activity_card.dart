import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/utils/responsive.dart';
import '../../data/models/activity.dart';
import 'bouncy_tap.dart';

/// A Home activity tile, styled after the deck's "What we're looking for" cards:
/// a white rounded card with a coloured left accent bar and a soft-tinted icon
/// circle. Reusable — give it an [Activity] model and an [onTap].
class ActivityCard extends StatelessWidget {
  const ActivityCard({
    super.key,
    required this.activity,
    required this.onTap,
  });

  final Activity activity;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final r = context.r;
    final accent = activity.accent;
    final enabled = activity.enabled;

    final card = Opacity(
      opacity: enabled ? 1 : 0.55,
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(r.scale(24)),
          boxShadow: [
            BoxShadow(
              color: AppColors.ink.withValues(alpha: 0.08),
              blurRadius: 18,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(r.scale(24)),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Coloured accent bar (deck signature).
              Container(width: r.scale(8), color: accent),
              Expanded(
                child: Padding(
                  padding: EdgeInsets.all(r.scale(16)),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        width: r.scale(54),
                        height: r.scale(54),
                        decoration: BoxDecoration(
                          color: AppColors.tintFor(accent),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          activity.icon,
                          color: accent,
                          size: r.font(28),
                        ),
                      ),
                      SizedBox(height: r.scale(12)),
                      Text(
                        activity.title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppTextStyles.title(size: r.font(18)),
                      ),
                      SizedBox(height: r.scale(2)),
                      Text(
                        enabled ? activity.subtitle : 'Coming soon',
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: AppTextStyles.body(size: r.font(13)),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );

    return BouncyTap(
      onTap: enabled ? onTap : null,
      child: card,
    );
  }
}
