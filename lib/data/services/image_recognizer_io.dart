import 'image_recognizer.dart';
import 'mlkit_image_recognizer.dart';

/// Android/iOS (and any `dart:io` host): use the real on-device ML Kit engine.
ImageRecognizer createImageRecognizer() => MlKitImageRecognizer();
