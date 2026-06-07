import 'image_recognizer.dart';
// Pick the platform implementation at compile time: ML Kit on mobile (the
// default, `dart:io`), a no-op fallback on web. This keeps the ML Kit plugin —
// and its `dart:io` dependency — out of the web build so the app still compiles
// for Chrome.
import 'image_recognizer_io.dart'
    if (dart.library.html) 'image_recognizer_web.dart' as platform;

/// The right [ImageRecognizer] for the current platform.
ImageRecognizer createImageRecognizer() => platform.createImageRecognizer();
