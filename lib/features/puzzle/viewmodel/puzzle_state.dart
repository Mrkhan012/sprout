import 'package:equatable/equatable.dart';

import '../model/puzzle_round.dart';

enum PuzzleStatus { playing, complete }

/// State for the "Find the …" Puzzle game.
class PuzzleState extends Equatable {
  const PuzzleState({
    this.rounds = const [],
    this.index = 0,
    this.solved = 0,
    this.status = PuzzleStatus.playing,
    this.wrongId,
  });

  final List<PuzzleRound> rounds;
  final int index;

  /// How many rounds the child has solved (drives the progress stars).
  final int solved;

  final PuzzleStatus status;

  /// The option the child just tapped wrongly, so the View can wobble it.
  final int? wrongId;

  PuzzleRound? get current =>
      index >= 0 && index < rounds.length ? rounds[index] : null;

  int get total => rounds.length;

  PuzzleState copyWith({
    List<PuzzleRound>? rounds,
    int? index,
    int? solved,
    PuzzleStatus? status,
    int? wrongId,
    bool clearWrong = false,
  }) {
    return PuzzleState(
      rounds: rounds ?? this.rounds,
      index: index ?? this.index,
      solved: solved ?? this.solved,
      status: status ?? this.status,
      wrongId: clearWrong ? null : (wrongId ?? this.wrongId),
    );
  }

  @override
  List<Object?> get props => [rounds, index, solved, status, wrongId];
}
