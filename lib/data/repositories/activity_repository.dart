import 'package:flutter/material.dart';

import '../../core/constants/app_routes.dart';
import '../../core/constants/app_strings.dart';
import '../../core/theme/app_colors.dart';
import '../models/activity.dart';
import '../models/hunt_item.dart';

/// Single source of truth for the app's content.
///
/// In a production build this would talk to Firebase/Supabase (as the deck
/// mentions); here it serves curated in-memory content. Keeping it behind a
/// repository means the ViewModels (Cubits/Blocs) never hard-code data and can
/// later be pointed at a real backend without touching the UI.
class ActivityRepository {
  const ActivityRepository();

  /// The activity cards shown on Home, in deck-accent order.
  List<Activity> getActivities() => const [
        Activity(
          id: 'tap_play',
          title: AppStrings.tapPlayTitle,
          subtitle: AppStrings.tapPlaySub,
          icon: Icons.bubble_chart_rounded,
          accent: AppColors.coral,
          route: AppRoutes.tapPlay,
        ),
        Activity(
          id: 'camera_hunt',
          title: AppStrings.huntTitle,
          subtitle: AppStrings.huntSub,
          icon: Icons.photo_camera_rounded,
          accent: AppColors.teal,
          route: AppRoutes.cameraHunt,
        ),
        Activity(
          id: 'rewards',
          title: AppStrings.rewardsTitle,
          subtitle: AppStrings.rewardsSub,
          icon: Icons.star_rounded,
          accent: AppColors.gold,
          route: AppRoutes.rewards,
        ),
        Activity(
          id: 'story',
          title: AppStrings.storyTitle,
          subtitle: AppStrings.storySub,
          icon: Icons.menu_book_rounded,
          accent: AppColors.indigo,
          route: '',
          enabled: false, // a "coming soon" tile to show the roadmap
        ),
      ];

  /// The five things a child hunts for in the Nature Hunt (Task 4).
  List<HuntItem> getHuntTargets() => const [
        HuntItem(label: 'Something green', emoji: '🌿'),
        HuntItem(label: 'Something round', emoji: '⚪'),
        HuntItem(label: 'A toy', emoji: '🧸'),
        HuntItem(label: 'Something soft', emoji: '☁️'),
        HuntItem(label: 'A book', emoji: '📚'),
      ];

  /// The friendly labels a child can choose from after snapping a photo
  /// (the "simple kid-friendly labeling" recognition approach).
  List<String> getLabelChoices() => const [
        '🌳 Plant',
        '🧸 Toy',
        '📚 Book',
        '🍎 Food',
        '🐾 Animal',
        '🚗 Vehicle',
        '👕 Clothes',
        '✨ Other',
      ];
}
