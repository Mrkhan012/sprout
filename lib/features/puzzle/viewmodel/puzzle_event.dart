import 'package:equatable/equatable.dart';

/// Events for the Puzzle Bloc.
sealed class PuzzleEvent extends Equatable {
  const PuzzleEvent();

  @override
  List<Object?> get props => [];
}

/// Load the rounds and start the first one.
class PuzzleStarted extends PuzzleEvent {
  const PuzzleStarted();
}

/// The child tapped the option with [optionId] in the current round.
class PuzzleOptionTapped extends PuzzleEvent {
  const PuzzleOptionTapped(this.optionId);
  final int optionId;

  @override
  List<Object?> get props => [optionId];
}

/// Read the current target aloud again (the speaker button).
class PuzzlePromptReplayed extends PuzzleEvent {
  const PuzzlePromptReplayed();
}

/// Start the whole puzzle again.
class PuzzleReset extends PuzzleEvent {
  const PuzzleReset();
}
