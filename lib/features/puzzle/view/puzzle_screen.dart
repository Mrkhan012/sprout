import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/constants/app_routes.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/utils/responsive.dart';
import '../../../data/models/reward.dart';
import '../../../data/repositories/activity_repository.dart';
import '../../../shared/widgets/app_back_button.dart';
import '../../../shared/widgets/bouncy_tap.dart';
import '../../../shared/widgets/celebration_overlay.dart';
import '../../../shared/widgets/gradient_scaffold.dart';
import '../../../shared/widgets/pill.dart';
import '../../../shared/widgets/progress_dots.dart';
import '../../rewards/viewmodel/rewards_cubit.dart';
import '../model/puzzle_round.dart';
import '../viewmodel/puzzle_bloc.dart';
import '../viewmodel/puzzle_event.dart';
import '../viewmodel/puzzle_state.dart';

/// Puzzle — a "Find the …" matching game with voice prompts. The child hears and
/// reads a target, taps the right tile across several rounds, and earns the
/// Puzzle Pro sticker.
class PuzzleScreen extends StatelessWidget {
  const PuzzleScreen({super.key});

  static const _reward = Reward(
    id: 'puzzle_pro',
    label: 'Puzzle Pro',
    emoji: '🧩',
    color: AppColors.sky,
  );

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => PuzzleBloc(const ActivityRepository())
        ..add(const PuzzleStarted()),
      child: MultiBlocListener(
        listeners: [
          BlocListener<PuzzleBloc, PuzzleState>(
            listenWhen: (prev, curr) =>
                prev.status != PuzzleStatus.complete &&
                curr.status == PuzzleStatus.complete,
            listener: (context, _) =>
                context.read<RewardsCubit>().award(_reward),
          ),
          // Buzz when a wrong tile is tapped.
          BlocListener<PuzzleBloc, PuzzleState>(
            listenWhen: (prev, curr) =>
                curr.wrongId != null && curr.wrongId != prev.wrongId,
            listener: (context, _) => HapticFeedback.mediumImpact(),
          ),
        ],
        child: const _PuzzleView(),
      ),
    );
  }
}

class _PuzzleView extends StatelessWidget {
  const _PuzzleView();

  @override
  Widget build(BuildContext context) {
    final r = context.r;
    return GradientScaffold(
      blobs: false,
      padding:
          EdgeInsets.symmetric(horizontal: r.scale(16), vertical: r.scale(8)),
      child: BlocBuilder<PuzzleBloc, PuzzleState>(
        builder: (context, state) {
          final round = state.current;
          if (round == null) {
            return const Center(
              child: CircularProgressIndicator(color: AppColors.sky),
            );
          }
          return Stack(
            children: [
              Column(
                children: [
                  const _TopBar(),
                  SizedBox(height: r.scale(12)),
                  ProgressDots(total: state.total, completed: state.solved),
                  SizedBox(height: r.scale(16)),
                  _Prompt(round: round),
                  SizedBox(height: r.scale(20)),
                  Expanded(child: _OptionsGrid(state: state, round: round)),
                ],
              ),
              if (state.status == PuzzleStatus.complete)
                Positioned.fill(
                  child: CelebrationOverlay(
                    emoji: '🧩',
                    title: AppStrings.puzzleDone,
                    message: 'You matched them all! You earned the Puzzle Pro '
                        'sticker.',
                    accent: AppColors.sky,
                    buttonLabel: 'Play again',
                    onButton: () =>
                        context.read<PuzzleBloc>().add(const PuzzleReset()),
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
  const _TopBar();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: const [
        AppBackButton(),
        Spacer(),
        Pill(
          text: AppStrings.puzzleGoal,
          background: AppColors.sky,
          foreground: AppColors.navy,
          icon: Icons.extension_rounded,
        ),
        Spacer(),
        SizedBox(width: 48),
      ],
    );
  }
}

/// The "Find the 🍎 Apple!" banner. Tapping the speaker re-reads the prompt.
class _Prompt extends StatelessWidget {
  const _Prompt({required this.round});

  final PuzzleRound round;

  @override
  Widget build(BuildContext context) {
    final r = context.r;
    return Column(
      children: [
        Text(
          AppStrings.puzzleFind,
          style: AppTextStyles.label(color: AppColors.onDarkSoft, size: r.font(13)),
        ),
        SizedBox(height: r.scale(8)),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(round.targetEmoji, style: TextStyle(fontSize: r.font(40))),
            SizedBox(width: r.scale(10)),
            Text(
              round.targetLabel,
              style: AppTextStyles.heading(
                  color: AppColors.onDark, size: r.font(30)),
            ),
            SizedBox(width: r.scale(12)),
            const _SpeakerButton(),
          ],
        ),
      ],
    );
  }
}

/// Re-reads the current target aloud via the Bloc.
class _SpeakerButton extends StatelessWidget {
  const _SpeakerButton();

  @override
  Widget build(BuildContext context) {
    return BouncyTap(
      onTap: () =>
          context.read<PuzzleBloc>().add(const PuzzlePromptReplayed()),
      child: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: AppColors.onDark.withValues(alpha: 0.12),
          shape: BoxShape.circle,
        ),
        child: const Icon(Icons.volume_up_rounded, color: AppColors.onDark),
      ),
    );
  }
}

class _OptionsGrid extends StatelessWidget {
  const _OptionsGrid({required this.state, required this.round});

  final PuzzleState state;
  final PuzzleRound round;

  @override
  Widget build(BuildContext context) {
    final r = context.r;
    return Center(
      child: Wrap(
        alignment: WrapAlignment.center,
        spacing: r.scale(16),
        runSpacing: r.scale(16),
        children: [
          for (final option in round.options)
            _OptionTile(
              option: option,
              isWrong: state.wrongId == option.id,
              onTap: () => context
                  .read<PuzzleBloc>()
                  .add(PuzzleOptionTapped(option.id)),
            ),
        ],
      ),
    );
  }
}

class _OptionTile extends StatelessWidget {
  const _OptionTile({
    required this.option,
    required this.isWrong,
    required this.onTap,
  });

  final PuzzleOption option;
  final bool isWrong;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final r = context.r;
    final size = (r.width * 0.34).clamp(110.0, 180.0);
    return BouncyTap(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: isWrong
              ? AppColors.coral.withValues(alpha: 0.25)
              : AppColors.onDark.withValues(alpha: 0.10),
          borderRadius: BorderRadius.circular(r.scale(24)),
          border: Border.all(
            color: isWrong ? AppColors.coral : AppColors.onDark.withValues(alpha: 0.18),
            width: isWrong ? 3 : 1.5,
          ),
        ),
        alignment: Alignment.center,
        child: Text(option.emoji, style: TextStyle(fontSize: size * 0.5)),
      ),
    );
  }
}
