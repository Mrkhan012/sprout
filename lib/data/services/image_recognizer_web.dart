import 'image_recognizer.dart';

/// Web (no `dart:io`, no on-device model): the hunt falls back to a manual
/// picker so the app still builds and runs in Chrome for review.
ImageRecognizer createImageRecognizer() => const UnavailableImageRecognizer();
