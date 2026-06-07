import 'cloud_image_recognizer.dart';
import 'image_recognizer.dart';

/// The recognizer used by the app. Cloud Vision is plain HTTPS, so a single
/// implementation works on mobile and web alike. Reads its API key from the
/// `VISION_API_KEY` compile-time define (see [CloudImageRecognizer]).
ImageRecognizer createImageRecognizer() => CloudImageRecognizer();
