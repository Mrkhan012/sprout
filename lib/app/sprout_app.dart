import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../core/constants/app_routes.dart';
import '../core/constants/app_strings.dart';
import '../core/theme/app_theme.dart';
import '../features/rewards/viewmodel/rewards_cubit.dart';
import 'app_router.dart';

/// Root of the app.
///
/// The [RewardsCubit] is provided here — above the [Navigator] — so the sticker
/// collection is shared across every screen (earned in an activity, shown on the
/// Rewards screen, counted in the Home header).
class SproutApp extends StatelessWidget {
  const SproutApp({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<RewardsCubit>(
      create: (_) => RewardsCubit(),
      child: MaterialApp(
        title: AppStrings.appName,
        debugShowCheckedModeBanner: false,
        theme: AppTheme.light,
        initialRoute: AppRoutes.splash,
        onGenerateRoute: AppRouter.onGenerateRoute,
      ),
    );
  }
}
