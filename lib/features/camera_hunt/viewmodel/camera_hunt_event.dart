import 'package:equatable/equatable.dart';

/// Events for the Nature Hunt Bloc.
sealed class CameraHuntEvent extends Equatable {
  const CameraHuntEvent();

  @override
  List<Object?> get props => [];
}

/// Load targets and initialise the camera.
class HuntStarted extends CameraHuntEvent {
  const HuntStarted();
}

/// Take a picture of the current target.
class HuntPhotoCaptured extends CameraHuntEvent {
  const HuntPhotoCaptured();
}

/// Tag the captured photo with a kid-friendly [label] and mark the target found.
class HuntLabelSelected extends CameraHuntEvent {
  const HuntLabelSelected(this.label);
  final String label;

  @override
  List<Object?> get props => [label];
}

/// Discard the captured photo and return to the viewfinder.
class HuntRetake extends CameraHuntEvent {
  const HuntRetake();
}

/// Start the whole hunt again.
class HuntReset extends CameraHuntEvent {
  const HuntReset();
}

/// App went to background — release the camera.
class HuntPaused extends CameraHuntEvent {
  const HuntPaused();
}

/// App returned to foreground — re-acquire the camera, keeping progress.
class HuntResumed extends CameraHuntEvent {
  const HuntResumed();
}
