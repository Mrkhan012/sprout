import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/constants/app_routes.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/utils/responsive.dart';
import '../../../data/models/reward.dart';
import '../../../data/models/story.dart';
import '../../../data/repositories/activity_repository.dart';
import '../../../shared/widgets/app_back_button.dart';
import '../../../shared/widgets/bouncy_tap.dart';
import '../../../shared/widgets/celebration_overlay.dart';
import '../../../shared/widgets/gradient_scaffold.dart';
import '../../../shared/widgets/pill.dart';
import '../../../shared/widgets/primary_button.dart';
import '../../../shared/widgets/progress_dots.dart';
import '../../rewards/viewmodel/rewards_cubit.dart';
import '../viewmodel/story_cubit.dart';
import '../viewmodel/story_state.dart';

/// Story Time — a read-aloud picture book. The child turns pages while a
/// friendly text-to-speech voice narrates each one, then earns the Story Star.
class StoryScreen extends StatelessWidget {
  const StoryScreen({super.key});

  static const _reward = Reward(
    id: 'story_star',
    label: 'Story Star',
    emoji: '⭐',
    color: AppColors.indigo,
  );

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => StoryCubit(const ActivityRepository())..load(),
      child: BlocListener<StoryCubit, StoryState>(
        listenWhen: (prev, curr) => !prev.finished && curr.finished,
        listener: (context, _) => context.read<RewardsCubit>().award(_reward),
        child: const _StoryView(),
      ),
    );
  }
}

class _StoryView extends StatelessWidget {
  const _StoryView();

  @override
  Widget build(BuildContext context) {
    final r = context.r;
    return GradientScaffold(
      blobs: false,
      padding:
          EdgeInsets.symmetric(horizontal: r.scale(16), vertical: r.scale(8)),
      child: BlocBuilder<StoryCubit, StoryState>(
        builder: (context, state) {
          final page = state.current;
          if (page == null) {
            return const Center(
              child: CircularProgressIndicator(color: AppColors.indigo),
            );
          }
          return Stack(
            children: [
              Column(
                children: [
                  const _TopBar(),
                  SizedBox(height: r.scale(12)),
                  ProgressDots(total: state.total, completed: state.index + 1),
                  SizedBox(height: r.scale(12)),
                  Expanded(child: _StoryPageCard(page: page)),
                  SizedBox(height: r.scale(12)),
                  _Controls(state: state),
                  SizedBox(height: r.scale(4)),
                ],
              ),
              if (state.finished)
                Positioned.fill(
                  child: CelebrationOverlay(
                    emoji: '⭐',
                    title: AppStrings.storyTheEnd,
                    message:
                        'You finished the story! You earned the Story Star.',
                    accent: AppColors.indigo,
                    buttonLabel: 'Read again',
                    onButton: () => context.read<StoryCubit>().restart(),
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
    return BlocBuilder<StoryCubit, StoryState>(
      buildWhen: (p, c) => p.voiceOn != c.voiceOn,
      builder: (context, state) {
        return Row(
          children: [
            const AppBackButton(),
            const Spacer(),
            const Pill(
              text: AppStrings.storyTitle,
              background: AppColors.indigo,
              foreground: AppColors.onDark,
              icon: Icons.menu_book_rounded,
            ),
            const Spacer(),
            // Mute / unmute the narration voice.
            _RoundIconButton(
              icon: state.voiceOn
                  ? Icons.volume_up_rounded
                  : Icons.volume_off_rounded,
              tooltip: state.voiceOn ? 'Turn voice off' : 'Turn voice on',
              onTap: () => context.read<StoryCubit>().toggleVoice(),
            ),
          ],
        );
      },
    );
  }
}

/// The big picture card: a huge emoji on the page's accent colour. Tapping it
/// re-reads the page aloud.
class _StoryPageCard extends StatelessWidget {
  const _StoryPageCard({required this.page});

  final StoryPage page;

  @override
  Widget build(BuildContext context) {
    final r = context.r;
    return BouncyTap(
      onTap: () => context.read<StoryCubit>().replay(),
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 350),
        child: Column(
          key: ValueKey(page),
          children: [
            Expanded(
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(r.scale(28)),
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Color.lerp(page.color, Colors.white, 0.25)!,
                      page.color,
                    ],
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: page.color.withValues(alpha: 0.45),
                      blurRadius: 24,
                      offset: const Offset(0, 12),
                    ),
                  ],
                ),
                alignment: Alignment.center,
                child: Text(page.emoji, style: TextStyle(fontSize: r.font(110))),
              ),
            ),
            SizedBox(height: r.scale(16)),
            Text(
              page.text,
              textAlign: TextAlign.center,
              style: AppTextStyles.title(
                color: AppColors.onDark,
                size: r.font(20),
              ),
            ),
            SizedBox(height: r.scale(6)),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.touch_app_rounded,
                    color: AppColors.onDarkSoft, size: r.font(14)),
                SizedBox(width: r.scale(6)),
                Text(
                  AppStrings.storyTapToHear,
                  style: AppTextStyles.body(
                    color: AppColors.onDarkSoft,
                    size: r.font(12),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _Controls extends StatelessWidget {
  const _Controls({required this.state});

  final StoryState state;

  @override
  Widget build(BuildContext context) {
    final r = context.r;
    final cubit = context.read<StoryCubit>();
    return Row(
      children: [
        if (!state.isFirst)
          _RoundIconButton(
            icon: Icons.chevron_left_rounded,
            tooltip: 'Previous page',
            onTap: cubit.previous,
          ),
        if (!state.isFirst) SizedBox(width: r.scale(12)),
        Expanded(
          child: PrimaryButton(
            label: state.isLast ? AppStrings.storyFinish : AppStrings.storyNext,
            icon: state.isLast
                ? Icons.celebration_rounded
                : Icons.chevron_right_rounded,
            color: AppColors.gold,
            foreground: AppColors.navy,
            expand: true,
            onPressed: state.isLast ? cubit.finish : cubit.next,
          ),
        ),
      ],
    );
  }
}

/// A small round icon button matching the app's chunky, kid-friendly style.
class _RoundIconButton extends StatelessWidget {
  const _RoundIconButton({
    required this.icon,
    required this.onTap,
    this.tooltip,
  });

  final IconData icon;
  final VoidCallback onTap;
  final String? tooltip;

  @override
  Widget build(BuildContext context) {
    final button = BouncyTap(
      onTap: onTap,
      child: Container(
        width: 52,
        height: 52,
        decoration: BoxDecoration(
          color: AppColors.onDark.withValues(alpha: 0.12),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: AppColors.onDark, size: 28),
      ),
    );
    return tooltip == null ? button : Tooltip(message: tooltip!, child: button);
  }
}
