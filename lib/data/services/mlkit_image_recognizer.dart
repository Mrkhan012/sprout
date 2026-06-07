import 'package:google_mlkit_image_labeling/google_mlkit_image_labeling.dart';

import 'image_recognizer.dart';
import 'label_catalog.dart';

/// Real, on-device image recognition powered by Google ML Kit's bundled image
/// labelling model.
///
/// Runs entirely on the phone — no network, no API key, and the child's photos
/// never leave the device (important for a kids' app). Available on Android &
/// iOS; other platforms use [UnavailableImageRecognizer] via the factory.
class MlKitImageRecognizer implements ImageRecognizer {
  MlKitImageRecognizer({double confidenceThreshold = 0.5})
      : _labeler = ImageLabeler(
          options: ImageLabelerOptions(confidenceThreshold: confidenceThreshold),
        );

  final ImageLabeler _labeler;

  @override
  Future<List<RecognizedLabel>> recognize(String imagePath) async {
    final input = InputImage.fromFilePath(imagePath);
    final labels = await _labeler.processImage(input);
    labels.sort((a, b) => b.confidence.compareTo(a.confidence));
    return [
      for (final l in labels) LabelCatalog.present(l.label, l.confidence),
    ];
  }

  @override
  Future<void> close() => _labeler.close();
}
