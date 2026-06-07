import 'package:flutter/material.dart';

import '../../core/constants/app_routes.dart';
import '../../core/constants/app_strings.dart';
import '../../core/theme/app_colors.dart';
import '../../features/puzzle/model/puzzle_round.dart';
import '../models/activity.dart';
import '../models/hunt_item.dart';
import '../models/story.dart';

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
          id: 'story',
          title: AppStrings.storyTitle,
          subtitle: AppStrings.storySub,
          icon: Icons.menu_book_rounded,
          accent: AppColors.indigo,
          route: AppRoutes.storyTime,
        ),
        Activity(
          id: 'puzzle',
          title: AppStrings.puzzleTitle,
          subtitle: AppStrings.puzzleSub,
          icon: Icons.extension_rounded,
          accent: AppColors.sky,
          route: AppRoutes.puzzle,
        ),
        Activity(
          id: 'rewards',
          title: AppStrings.rewardsTitle,
          subtitle: AppStrings.rewardsSub,
          icon: Icons.star_rounded,
          accent: AppColors.gold,
          route: AppRoutes.rewards,
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
  /// (the manual fallback if the recognizer can't identify it).
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

  /// The read-aloud picture book for Story Time. An original tale that echoes
  /// the Sprout brand ("Little minds. Big adventures.").
  Story getStory() => const Story(
        title: 'Sprout the Little Seed',
        pages: [
          StoryPage(
            text: 'Once upon a time, a tiny seed named Sprout '
                'slept in the warm, dark soil.',
            emoji: '🌱',
            color: AppColors.teal,
          ),
          StoryPage(
            text: 'One morning, a raindrop went plip! '
                '"Time to wake up," giggled Sprout.',
            emoji: '🌧️',
            color: AppColors.sky,
          ),
          StoryPage(
            text: 'Sprout pushed up, up, up — and popped '
                'into the bright, happy sunshine!',
            emoji: '☀️',
            color: AppColors.gold,
          ),
          StoryPage(
            text: 'A friendly bee buzzed by. "Hello!" said Sprout, '
                'waving a little green leaf.',
            emoji: '🐝',
            color: AppColors.coral,
          ),
          StoryPage(
            text: 'Day by day, Sprout grew taller, '
                'and opened a beautiful pink flower.',
            emoji: '🌸',
            color: AppColors.pink,
          ),
          StoryPage(
            text: '"Hooray!" cheered Sprout. '
                'Little seeds can grow into big adventures!',
            emoji: '🌳',
            color: AppColors.indigo,
          ),
        ],
      );

  /// The rounds for the "Find it!" Puzzle game. Each round names a target and
  /// offers it among playful distractors (the Bloc shuffles option order).
  List<PuzzleRound> getPuzzleRounds() => const [
        PuzzleRound(
          targetLabel: 'Apple',
          targetEmoji: '🍎',
          options: [
            PuzzleOption(id: 0, emoji: '🍎', label: 'Apple'),
            PuzzleOption(id: 1, emoji: '🍌', label: 'Banana'),
            PuzzleOption(id: 2, emoji: '🐶', label: 'Dog'),
          ],
        ),
        PuzzleRound(
          targetLabel: 'Dog',
          targetEmoji: '🐶',
          options: [
            PuzzleOption(id: 0, emoji: '🐱', label: 'Cat'),
            PuzzleOption(id: 1, emoji: '🐶', label: 'Dog'),
            PuzzleOption(id: 2, emoji: '🚗', label: 'Car'),
          ],
        ),
        PuzzleRound(
          targetLabel: 'Star',
          targetEmoji: '⭐',
          options: [
            PuzzleOption(id: 0, emoji: '⭐', label: 'Star'),
            PuzzleOption(id: 1, emoji: '❤️', label: 'Heart'),
            PuzzleOption(id: 2, emoji: '🌙', label: 'Moon'),
          ],
        ),
        PuzzleRound(
          targetLabel: 'Ball',
          targetEmoji: '⚽',
          options: [
            PuzzleOption(id: 0, emoji: '🎈', label: 'Balloon'),
            PuzzleOption(id: 1, emoji: '⚽', label: 'Ball'),
            PuzzleOption(id: 2, emoji: '🍎', label: 'Apple'),
          ],
        ),
        PuzzleRound(
          targetLabel: 'Fish',
          targetEmoji: '🐟',
          options: [
            PuzzleOption(id: 0, emoji: '🐦', label: 'Bird'),
            PuzzleOption(id: 1, emoji: '🐰', label: 'Rabbit'),
            PuzzleOption(id: 2, emoji: '🐟', label: 'Fish'),
          ],
        ),
      ];
}
