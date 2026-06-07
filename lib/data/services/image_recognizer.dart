import 'package:equatable/equatable.dart';

/// One thing the recognizer believes is in a photo, in kid-friendly form.
///
/// [label] is the display text (e.g. `Flower`), [emoji] a playful cue and
/// [confidence] the model's certainty from 0–1. Value type so it can live in
/// Bloc state and drive rebuilds via equality.
class RecognizedLabel extends Equatable {
  const RecognizedLabel({
    required this.label,
    required this.emoji,
    required this.confidence,
  });

  final String label;
  final String emoji;
  final double confidence;

  /// `0.92` → `92`, for a friendly "I'm 92% sure!" line.
  int get confidencePercent => (confidence * 100).round();

  /// `🌸 Flower` — the form stored against a found hunt item / sticker.
  String get display => '$emoji $label';

  @override
  List<Object?> get props => [label, emoji, confidence];
}

/// Abstraction over an image-labelling engine.
///
/// The ViewModel depends only on this interface, never on a concrete ML engine,
/// so the on-device implementation can be swapped (or faked in tests) freely.
/// The real, on-device implementation is [MlKitImageRecognizer]; pick the right
/// one per platform with `createImageRecognizer()` from
/// `image_recognizer_factory.dart`.
abstract class ImageRecognizer {
  /// Identify the contents of the JPEG at [imagePath], best guess first.
  ///
  /// An empty list means "couldn't tell" — the UI then falls back to letting the
  /// child name it themselves.
  Future<List<RecognizedLabel>> recognize(String imagePath);

  /// Release any native resources held by the engine.
  Future<void> close();
}

/// Used on platforms without an on-device model (web/desktop): always returns
/// no guesses, so the Nature Hunt gracefully falls back to a manual picker and
/// the app keeps working everywhere it builds.
class UnavailableImageRecognizer implements ImageRecognizer {
  const UnavailableImageRecognizer();

  @override
  Future<List<RecognizedLabel>> recognize(String imagePath) async => const [];

  @override
  Future<void> close() async {}
}
