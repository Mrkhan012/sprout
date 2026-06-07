import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/constants/app_routes.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/responsive.dart';
import '../../../data/models/reward.dart';
import '../../../shared/widgets/app_back_button.dart';
import '../../../shared/widgets/celebration_overlay.dart';
import '../../../shared/widgets/gradient_scaffold.dart';
import '../../../shared/widgets/pill.dart';
import '../../../shared/widgets/progress_dots.dart';
import '../../rewards/viewmodel/rewards_cubit.dart';
import '../model/bubble.dart';
import '../viewmodel/tap_play_bloc.dart';
import '../viewmodel/tap_play_event.dart';
import '../viewmodel/tap_play_state.dart';
import 'widgets/bubble_widget.dart';

/// Task 2 — a single interactive screen for ages 3–5: tap the bubbles to pop
/// them with animation, haptics and sound, then celebrate when the field clears.
class TapPlayScreen extends StatelessWidget {
  const TapPlayScreen({super.key});

  static const _reward = Reward(
    id: 'bubble_master',
    label: 'Bubble Master',
    emoji: '🫧',
    color: AppColors.coral,
  );

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => TapPlayBloc()..add(const TapPlayStarted()),
      child: BlocListener<TapPlayBloc, TapPlayState>(
        listenWhen: (prev, curr) => !prev.isComplete && curr.isComplete,
        listener: (context, _) =>
            context.read<RewardsCubit>().award(_reward),
        child: const _TapPlayView(),
      ),
    );
  }
}

class _TapPlayView extends StatelessWidget {
  const _TapPlayView();

  @override
  Widget build(BuildContext context) {
    final r = context.r;

    return GradientScaffold(
      padding: EdgeInsets.symmetric(horizontal: r.scale(16), vertical: r.scale(8)),
      child: BlocBuilder<TapPlayBloc, TapPlayState>(
        builder: (context, state) {
          return Stack(
            children: [
              Column(
                children: [
                  _TopBar(popped: state.popped, total: state.total),
                  SizedBox(height: r.scale(8)),
                  Expanded(child: _BubbleField(bubbles: state.bubbles)),
                ],
              ),
              if (state.isComplete)
                Positioned.fill(
                  child: CelebrationOverlay(
                    emoji: '🎉',
                    title: AppStrings.tapPlayDone,
                    message: 'You earned the Bubble Master sticker!',
                    buttonLabel: 'Play again',
                    accent: AppColors.gold,
                    onButton: () =>
                        context.read<TapPlayBloc>().add(const TapPlayReset()),
                    secondaryLabel: 'Back home',
                    onSecondary: () => Navigator.of(context)
                        .popUntil(ModalRoute.withName(AppRoutes.home)),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}

class _TopBar extends StatelessWidget {
  const _TopBar({required this.popped, required this.total});

  final int popped;
  final int total;

  @override
  Widget build(BuildContext context) {
    final r = context.r;
    return Column(
      children: [
        Row(
          children: [
            const AppBackButton(),
            const Spacer(),
            const Pill(
              text: AppStrings.tapPlayGoal,
              background: AppColors.coral,
              foreground: AppColors.onDark,
              icon: Icons.bubble_chart_rounded,
            ),
            const Spacer(),
            // Balances the back button so the pill stays centred.
            const SizedBox(width: 48),
          ],
        ),
        SizedBox(height: r.scale(12)),
        ProgressDots(total: total, completed: popped),
      ],
    );
  }
}

class _BubbleField extends StatelessWidget {
  const _BubbleField({required this.bubbles});

  final List<Bubble> bubbles;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final w = constraints.maxWidth;
        final h = constraints.maxHeight;
        // Scale bubble size against the field so it fits any screen.
        final sizeFactor = (w / 390).clamp(0.8, 1.6);

        return Stack(
          children: [
            for (final b in bubbles)
              Builder(
                builder: (context) {
                  final d = b.diameter * sizeFactor;
                  return Positioned(
                    left: (b.dx * w) - d / 2,
                    top: (b.dy * h) - d / 2,
                    child: BubbleWidget(
                      bubble: b,
                      diameter: d,
                      onPop: () => context
                          .read<TapPlayBloc>()
                          .add(BubblePopped(b.id)),
                    ),
                  );
                },
              ),
          ],
        );
      },
    );
  }
}
