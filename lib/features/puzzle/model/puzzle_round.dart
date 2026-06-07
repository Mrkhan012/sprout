import 'package:equatable/equatable.dart';

/// One choice tile in a Puzzle round.
class PuzzleOption extends Equatable {
  const PuzzleOption({
    required this.id,
    required this.emoji,
    required this.label,
  });

  final int id;
  final String emoji;
  final String label;

  @override
  List<Object?> get props => [id, emoji, label];
}

/// One "Find the …" round: a target the child must spot among [options].
///
/// Exactly one option's [PuzzleOption.label] matches [targetLabel]; the rest are
/// playful distractors. Position is decided by the View/Bloc (options are
/// shuffled) so the answer isn't always in the same place.
class PuzzleRound extends Equatable {
  const PuzzleRound({
    required this.targetLabel,
    required this.targetEmoji,
    required this.options,
  });

  final String targetLabel;
  final String targetEmoji;
  final List<PuzzleOption> options;

  /// The id of the correct option (the one whose label is the target).
  int get answerId =>
      options.firstWhere((o) => o.label == targetLabel).id;

  @override
  List<Object?> get props => [targetLabel, targetEmoji, options];
}
