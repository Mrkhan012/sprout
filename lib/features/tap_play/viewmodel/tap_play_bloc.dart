import 'dart:math' as math;

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/theme/app_colors.dart';
import '../../../data/services/speech_service.dart';
import '../model/bubble.dart';
import 'tap_play_event.dart';
import 'tap_play_state.dart';

/// ViewModel for Pop the Bubbles, written as a full event-driven Bloc to show
/// the events→state pattern: [TapPlayStarted] lays out the field, each
/// [BubblePopped] flips one bubble, and [TapPlayReset] starts over.
///
/// Each pop also names the animal aloud via the [SpeechService] (a playful way
/// to learn words), and clearing the field is cheered.
class TapPlayBloc extends Bloc<TapPlayEvent, TapPlayState> {
  TapPlayBloc({int bubbleCount = 6, SpeechService? speech})
      : _bubbleCount = bubbleCount,
        _speech = speech ?? SpeechService(),
        super(const TapPlayState()) {
    on<TapPlayStarted>(_onStarted);
    on<BubblePopped>(_onPopped);
    on<TapPlayReset>(_onReset);
  }

  final int _bubbleCount;
  final SpeechService _speech;

  static const List<String> _faces = [
    '🐻', '🐰', '🦊', '🐸', '🐱', '🐤', '🐼', '🐧'
  ];

  /// Emoji → the word the voice says when that bubble pops.
  static const Map<String, String> _animalNames = {
    '🐻': 'Bear', '🐰': 'Rabbit', '🦊': 'Fox', '🐸': 'Frog',
    '🐱': 'Cat', '🐤': 'Chick', '🐼': 'Panda', '🐧': 'Penguin',
  };

  void _onStarted(TapPlayStarted event, Emitter<TapPlayState> emit) {
    emit(TapPlayState(bubbles: _generate()));
  }

  void _onPopped(BubblePopped event, Emitter<TapPlayState> emit) {
    final popped = state.bubbles.where((b) => b.id == event.id);
    final updated = [
      for (final b in state.bubbles)
        b.id == event.id ? b.copyWith(popped: true) : b,
    ];
    emit(state.copyWith(bubbles: updated));

    if (state.isComplete) {
      _speech.speak('You popped them all! Great job!');
    } else if (popped.isNotEmpty) {
      _speech.speak(_animalNames[popped.first.emoji] ?? 'Pop!');
    }
  }

  void _onReset(TapPlayReset event, Emitter<TapPlayState> emit) {
    emit(TapPlayState(bubbles: _generate()));
  }

  @override
  Future<void> close() async {
    await _speech.dispose();
    return super.close();
  }

  /// Lay bubbles out on a jittered grid so they never overlap badly, regardless
  /// of count, while still feeling scattered and playful.
  List<Bubble> _generate() {
    final rng = math.Random();
    final cols = _bubbleCount <= 4 ? 2 : 3;
    final rows = (_bubbleCount / cols).ceil();

    final bubbles = <Bubble>[];
    for (var i = 0; i < _bubbleCount; i++) {
      final col = i % cols;
      final row = i ~/ cols;
      // Cell centre with a little jitter inside the cell.
      final dx = (col + 0.5) / cols + (rng.nextDouble() - 0.5) * 0.18;
      final dy = (row + 0.5) / rows + (rng.nextDouble() - 0.5) * 0.16;
      bubbles.add(Bubble(
        id: i,
        dx: dx.clamp(0.12, 0.88),
        dy: dy.clamp(0.10, 0.90),
        diameter: 78 + rng.nextDouble() * 26,
        color: AppColors.playful[i % AppColors.playful.length],
        emoji: _faces[i % _faces.length],
      ));
    }
    return bubbles;
  }
}
