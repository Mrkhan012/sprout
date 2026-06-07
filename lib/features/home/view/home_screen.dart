import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/constants/app_routes.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/utils/responsive.dart';
import '../../../data/repositories/activity_repository.dart';
import '../../../shared/widgets/activity_card.dart';
import '../../rewards/viewmodel/rewards_cubit.dart';
import '../../rewards/viewmodel/rewards_state.dart';
import '../viewmodel/home_cubit.dart';
import '../viewmodel/home_state.dart';

/// Home: a friendly greeting and a responsive grid of activity cards.
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => HomeCubit(const ActivityRepository())..load(),
      child: const _HomeView(),
    );
  }
}

class _HomeView extends StatelessWidget {
  const _HomeView();

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
                  const _HomeHeader(),
                  SizedBox(height: r.scale(20)),
                  Text(
                    AppStrings.homeGreeting,
                    style: AppTextStyles.heading(size: r.font(30)),
                  ),
                  SizedBox(height: r.scale(4)),
                  Text(
                    AppStrings.homeSub,
                    style: AppTextStyles.body(size: r.font(16)),
                  ),
                  SizedBox(height: r.scale(18)),
                  const Expanded(child: _ActivityGrid()),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _HomeHeader extends StatelessWidget {
  const _HomeHeader();

  @override
  Widget build(BuildContext context) {
    final r = context.r;
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            const Icon(Icons.eco_rounded, color: AppColors.indigo, size: 26),
            SizedBox(width: r.scale(6)),
            Text(
              AppStrings.appName,
              style: AppTextStyles.title(color: AppColors.ink, size: r.font(22)),
            ),
          ],
        ),
        // Live sticker count, tappable to the rewards screen.
        BlocBuilder<RewardsCubit, RewardsState>(
          builder: (context, state) {
            return GestureDetector(
              onTap: () =>
                  Navigator.of(context).pushNamed(AppRoutes.rewards),
              child: Container(
                padding: EdgeInsets.symmetric(
                  horizontal: r.scale(14),
                  vertical: r.scale(8),
                ),
                decoration: BoxDecoration(
                  color: AppColors.tintGold,
                  borderRadius: BorderRadius.circular(r.scale(30)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.star_rounded,
                        color: AppColors.goldDeep, size: 22),
                    SizedBox(width: r.scale(6)),
                    Text(
                      '${state.count}',
                      style: AppTextStyles.title(
                        color: AppColors.goldDeep,
                        size: r.font(18),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ],
    );
  }
}

class _ActivityGrid extends StatelessWidget {
  const _ActivityGrid();

  @override
  Widget build(BuildContext context) {
    final r = context.r;
    return BlocBuilder<HomeCubit, HomeState>(
      builder: (context, state) {
        // Taller cards on phones so content never clips on narrow screens;
        // a touch wider on larger form factors.
        final aspect = r.isPhone ? 0.82 : 1.05;
        return GridView.builder(
          padding: EdgeInsets.only(bottom: r.scale(20)),
          physics: const BouncingScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: r.gridColumns,
            mainAxisSpacing: r.scale(16),
            crossAxisSpacing: r.scale(16),
            childAspectRatio: aspect,
          ),
          itemCount: state.activities.length,
          itemBuilder: (context, i) {
            final activity = state.activities[i];
            return ActivityCard(
              activity: activity,
              onTap: () => Navigator.of(context).pushNamed(activity.route),
            );
          },
        );
      },
    );
  }
}
