import 'package:flutter/material.dart';

import '../core/constants/app_routes.dart';
import '../features/camera_hunt/view/camera_hunt_screen.dart';
import '../features/home/view/home_screen.dart';
import '../features/rewards/view/rewards_screen.dart';
import '../features/splash/view/splash_screen.dart';
import '../features/tap_play/view/tap_play_screen.dart';

/// Central route table. Each feature exposes a single screen widget; the
/// per-feature Bloc/Cubit is created inside that widget, keeping ViewModels
/// scoped to their View.
class AppRouter {
  AppRouter._();

  static Route<dynamic> onGenerateRoute(RouteSettings settings) {
    final page = switch (settings.name) {
      AppRoutes.splash => const SplashScreen(),
      AppRoutes.home => const HomeScreen(),
      AppRoutes.tapPlay => const TapPlayScreen(),
      AppRoutes.cameraHunt => const CameraHuntScreen(),
      AppRoutes.rewards => const RewardsScreen(),
      _ => const SplashScreen(),
    };

    return PageRouteBuilder<dynamic>(
      settings: settings,
      transitionDuration: const Duration(milliseconds: 350),
      reverseTransitionDuration: const Duration(milliseconds: 250),
      pageBuilder: (_, _, _) => page,
      transitionsBuilder: (_, animation, _, child) {
        final curved =
            CurvedAnimation(parent: animation, curve: Curves.easeOutCubic);
        return FadeTransition(
          opacity: curved,
          child: SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(0, 0.04),
              end: Offset.zero,
            ).animate(curved),
            child: child,
          ),
        );
      },
    );
  }
}
