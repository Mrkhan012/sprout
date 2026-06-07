import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/constants/app_strings.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/utils/responsive.dart';
import '../../../data/models/reward.dart';
import '../../../shared/widgets/app_back_button.dart';
import '../../../shared/widgets/primary_button.dart';
import '../viewmodel/rewards_cubit.dart';
import '../viewmodel/rewards_state.dart';

/// The sticker book. Reads the app-wide [RewardsCubit] — no local provider, so
/// stickers earned in any activity show up here instantly.
class RewardsScreen extends StatelessWidget {
  const RewardsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final r = context.r;

    return Scaffold(
      backgroundColor: AppColors.lavenderBg,
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: r.maxContentWidth),
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: r.scale(20)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: r.scale(8)),
                  Row(
                    children: [
                      const AppBackButton(
                        color: AppColors.ink,
                        background: AppColors.surface,
                      ),
                      SizedBox(width: r.scale(12)),
                      Text(
                        AppStrings.rewardsTitle,
                        style: AppTextStyles.heading(size: r.font(26)),
                      ),
                    ],
                  ),
                  SizedBox(height: r.scale(16)),
                  Expanded(
                    child: BlocBuilder<RewardsCubit, RewardsState>(
                      builder: (context, state) {
                        if (state.isEmpty) return const _EmptyState();
                        return _StickerGrid(rewards: state.rewards);
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _StickerGrid extends StatelessWidget {
  const _StickerGrid({required this.rewards});

  final List<Reward> rewards;

  @override
  Widget build(BuildContext context) {
    final r = context.r;
    return GridView.builder(
      physics: const BouncingScrollPhysics(),
      padding: EdgeInsets.only(bottom: r.scale(20)),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: r.isPhone ? 2 : 3,
        mainAxisSpacing: r.scale(16),
        crossAxisSpacing: r.scale(16),
        childAspectRatio: 0.92,
      ),
      itemCount: rewards.length,
      itemBuilder: (context, i) => _StickerTile(reward: rewards[i], index: i),
    );
  }
}

class _StickerTile extends StatelessWidget {
  const _StickerTile({required this.reward, required this.index});

  final Reward reward;
  final int index;

  @override
  Widget build(BuildContext context) {
    final r = context.r;
    return TweenAnimationBuilder<double>(
      duration: Duration(milliseconds: 350 + index * 80),
      curve: Curves.elasticOut,
      tween: Tween(begin: 0, end: 1),
      builder: (context, t, child) =>
          Transform.scale(scale: t.clamp(0.0, 1.0), child: child),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(r.scale(24)),
          boxShadow: [
            BoxShadow(
              color: reward.color.withValues(alpha: 0.25),
              blurRadius: 16,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: r.scale(72),
              height: r.scale(72),
              decoration: BoxDecoration(
                color: reward.color.withValues(alpha: 0.18),
                shape: BoxShape.circle,
              ),
              alignment: Alignment.center,
              child: Text(reward.emoji, style: TextStyle(fontSize: r.font(38))),
            ),
            SizedBox(height: r.scale(10)),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: r.scale(8)),
              child: Text(
                reward.label,
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: AppTextStyles.title(size: r.font(15)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    final r = context.r;
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('🌱', style: TextStyle(fontSize: r.font(72))),
          SizedBox(height: r.scale(16)),
          Text(
            AppStrings.rewardsEmpty,
            textAlign: TextAlign.center,
            style: AppTextStyles.body(size: r.font(17)),
          ),
          SizedBox(height: r.scale(24)),
          PrimaryButton(
            label: "Let's play",
            icon: Icons.play_arrow_rounded,
            color: AppColors.indigo,
            onPressed: () => Navigator.of(context).maybePop(),
          ),
        ],
      ),
    );
  }
}
