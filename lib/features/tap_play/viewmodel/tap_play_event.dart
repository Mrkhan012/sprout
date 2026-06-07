import 'package:equatable/equatable.dart';

/// Events for the Pop the Bubbles Bloc.
sealed class TapPlayEvent extends Equatable {
  const TapPlayEvent();

  @override
  List<Object?> get props => [];
}

/// Generate a fresh field of bubbles.
class TapPlayStarted extends TapPlayEvent {
  const TapPlayStarted();
}

/// The child popped the bubble with [id].
class BubblePopped extends TapPlayEvent {
  const BubblePopped(this.id);
  final int id;

  @override
  List<Object?> get props => [id];
}

/// Restart the activity.
class TapPlayReset extends TapPlayEvent {
  const TapPlayReset();
}
