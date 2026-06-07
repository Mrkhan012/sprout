import 'dart:math' as math;

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../data/repositories/activity_repository.dart';
import '../../../data/services/speech_service.dart';
import '../model/puzzle_round.dart';
import 'puzzle_event.dart';
import 'puzzle_state.dart';

/// ViewModel for the "Find the …" Puzzle game.
///
/// A full event Bloc (like the other interactive activities): [PuzzleStarted]
/// lays out shuffled rounds, each [PuzzleOptionTapped] checks the answer and
/// either advances or marks the tap wrong, and the [SpeechService] voices the
/// prompt ("Find the apple!") and praise.
class PuzzleBloc extends Bloc<PuzzleEvent, PuzzleState> {
  PuzzleBloc(
    this._repository, {
    SpeechService? speech,
    math.Random? random,
  })  : _speech = speech ?? SpeechService(),
        _random = random ?? math.Random(),
        super(const PuzzleState()) {
    on<PuzzleStarted>(_onStarted);
    on<PuzzleOptionTapped>(_onTapped);
    on<PuzzlePromptReplayed>((_, _) => _promptCurrent());
    on<PuzzleReset>(_onReset);
  }

  final ActivityRepository _repository;
  final SpeechService _speech;
  final math.Random _random;

  static const List<String> _praises = [
    'Yes!', 'Well done!', 'Great job!', 'You found it!', 'Hooray!',
  ];

  void _onStarted(PuzzleStarted event, Emitter<PuzzleState> emit) {
    emit(PuzzleState(rounds: _buildRounds()));
    _promptCurrent();
  }

  void _onTapped(PuzzleOptionTapped event, Emitter<PuzzleState> emit) {
    final round = state.current;
    if (round == null || state.status != PuzzleStatus.playing) return;

    if (event.optionId != round.answerId) {
      // Wrong: mark the tapped tile and gently encourage another try.
      _speech.speak('Oops, try again!');
      emit(state.copyWith(wrongId: event.optionId));
      return;
    }

    final solved = state.solved + 1;
    final isLast = state.index >= state.rounds.length - 1;
    if (isLast) {
      emit(state.copyWith(
        solved: solved,
        status: PuzzleStatus.complete,
        clearWrong: true,
      ));
      _speech.speak('You did it! You finished the puzzle!');
    } else {
      emit(state.copyWith(
        index: state.index + 1,
        solved: solved,
        clearWrong: true,
      ));
      // State now points at the next round — voice praise + the new prompt in
      // one line so they don't cut each other off.
      final next = state.current;
      if (next != null) {
        _speech.speak('${_praise()} Now find the ${next.targetLabel}!');
      }
    }
  }

  void _onReset(PuzzleReset event, Emitter<PuzzleState> emit) {
    emit(PuzzleState(rounds: _buildRounds()));
    _promptCurrent();
  }

  /// Copy the repository rounds, shuffling each round's options so the correct
  /// tile isn't always in the same spot.
  List<PuzzleRound> _buildRounds() {
    return [
      for (final round in _repository.getPuzzleRounds())
        PuzzleRound(
          targetLabel: round.targetLabel,
          targetEmoji: round.targetEmoji,
          options: [...round.options]..shuffle(_random),
        ),
    ];
  }

  void _promptCurrent() {
    final round = state.current;
    if (round != null) _speech.speak('Find the ${round.targetLabel}!');
  }

  String _praise() => _praises[_random.nextInt(_praises.length)];

  @override
  Future<void> close() async {
    await _speech.dispose();
    return super.close();
  }
}
