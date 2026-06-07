import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/constants/app_routes.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/utils/responsive.dart';
import '../../../shared/widgets/gradient_scaffold.dart';
import '../../../shared/widgets/pill.dart';
import '../../../shared/widgets/primary_button.dart';
import '../../../shared/widgets/sprout_logo.dart';
import '../../../shared/widgets/stat_chip.dart';
import '../viewmodel/splash_cubit.dart';
import '../viewmodel/splash_state.dart';

/// The branded intro (deck page 1): badge, gold wordmark, subtitle, tagline,
/// stat chips and a "Let's play!" entry point.
class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => SplashCubit()..init(),
      child: const _SplashView(),
    );
  }
}

class _SplashView extends StatelessWidget {
  const _SplashView();

  @override
  Widget build(BuildContext context) {
    final r = context.r;

    return GradientScaffold(
      padding: EdgeInsets.symmetric(
        horizontal: r.scale(28),
        vertical: r.scale(24),
      ),
      // A simple scrollable column: content flows from the top and scrolls when
      // the screen is short — never overflows on any device size.
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(height: r.scale(40)),
            _branding(r),
            SizedBox(height: r.scale(36)),
            _StatRow(),
            SizedBox(height: r.scale(36)),
            _cta(context),
            SizedBox(height: r.scale(16)),
          ],
        ),
      ),
    );
  }

  Widget _branding(Responsive r) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        SizedBox(height: r.scale(24)),
        const Pill(text: AppStrings.badge),
        SizedBox(height: r.scale(28)),
        // Animated wordmark entrance.
        TweenAnimationBuilder<double>(
          duration: const Duration(milliseconds: 700),
          curve: Curves.easeOutBack,
          tween: Tween(begin: 0, end: 1),
          builder: (context, t, child) => Transform.scale(
            scale: 0.7 + 0.3 * t.clamp(0.0, 1.0),
            child: Opacity(opacity: t.clamp(0.0, 1.0), child: child),
          ),
          child: SproutLogo(size: r.font(64)),
        ),
        SizedBox(height: r.scale(14)),
        Text(
          AppStrings.subtitle,
          textAlign: TextAlign.center,
          style: AppTextStyles.body(color: AppColors.sky, size: r.font(17)),
        ),
        SizedBox(height: r.scale(10)),
        Text(
          AppStrings.tagline,
          textAlign: TextAlign.center,
          style: AppTextStyles.title(color: AppColors.onDark, size: r.font(18)),
        ),
      ],
    );
  }

  Widget _cta(BuildContext context) {
    final r = context.r;
    return Padding(
      padding: EdgeInsets.only(top: r.scale(24), bottom: r.scale(8)),
      child: BlocBuilder<SplashCubit, SplashState>(
        builder: (context, state) {
          return AnimatedSlide(
            duration: const Duration(milliseconds: 500),
            curve: Curves.easeOutBack,
            offset: state.isReady ? Offset.zero : const Offset(0, 1.5),
            child: AnimatedOpacity(
              duration: const Duration(milliseconds: 400),
              opacity: state.isReady ? 1 : 0,
              child: PrimaryButton(
                label: "Let's play!",
                icon: Icons.play_arrow_rounded,
                color: AppColors.gold,
                foreground: AppColors.navy,
                expand: true,
                onPressed: state.isReady
                    ? () => Navigator.of(context)
                        .pushReplacementNamed(AppRoutes.home)
                    : null,
              ),
            ),
          );
        },
      ),
    );
  }
}

class _StatRow extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final r = context.r;
    const chips = [
      StatChip(value: AppStrings.targetAge, label: 'Target age', accent: AppColors.indigo),
      StatChip(value: AppStrings.basedIn, label: 'Based in', accent: AppColors.teal),
      StatChip(value: 'Learn & Play', label: 'Every day', accent: AppColors.coral),
    ];

    // Three equal-width, equal-height chips side by side (the deck's hero stat
    // row). IntrinsicHeight gives the Row a bounded height so the chips can
    // stretch to match even inside the scroll view.
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          for (var i = 0; i < chips.length; i++) ...[
            if (i > 0) SizedBox(width: r.scale(12)),
            Expanded(child: chips[i]),
          ],
        ],
      ),
    );
  }
}
