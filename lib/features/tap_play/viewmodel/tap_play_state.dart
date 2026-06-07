import 'package:equatable/equatable.dart';

import '../model/bubble.dart';

/// State for the Pop the Bubbles activity.
class TapPlayState extends Equatable {
  const TapPlayState({this.bubbles = const []});

  final List<Bubble> bubbles;

  int get total => bubbles.length;
  int get popped => bubbles.where((b) => b.popped).length;
  bool get isComplete => total > 0 && popped == total;

  TapPlayState copyWith({List<Bubble>? bubbles}) =>
      TapPlayState(bubbles: bubbles ?? this.bubbles);

  @override
  List<Object?> get props => [bubbles];
}
