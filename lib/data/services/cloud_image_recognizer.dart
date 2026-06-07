import 'dart:convert';
import 'dart:typed_data';

import 'package:http/http.dart' as http;

import 'image_recognizer.dart';
import 'label_catalog.dart';

/// Real image recognition via the Google Cloud Vision API (label detection).
///
/// Far more accurate than the on-device base model — it reliably names everyday
/// things like "Laptop", "Keyboard" or "Dog". Works on every platform (it's just
/// HTTPS), so the same engine powers mobile and the web build.
///
/// The API key is read from the `VISION_API_KEY` compile-time define so it never
/// lives in source:
///
/// ```
/// flutter run --dart-define=VISION_API_KEY=your_key_here
/// ```
///
/// With no key configured, [recognize] returns no guesses and the hunt falls
/// back to the manual picker, so the app still runs.
class CloudImageRecognizer implements ImageRecognizer {
  CloudImageRecognizer({
    String? apiKey,
    double confidenceThreshold = 0.6,
    int maxResults = 10,
    http.Client? client,
  })  : _apiKey = apiKey ?? const String.fromEnvironment('VISION_API_KEY'),
        _confidenceThreshold = confidenceThreshold,
        _maxResults = maxResults,
        _client = client ?? http.Client();

  static const String _endpoint =
      'https://vision.googleapis.com/v1/images:annotate';

  final String _apiKey;
  final double _confidenceThreshold;
  final int _maxResults;
  final http.Client _client;

  /// Whether an API key is present. The UI can use this to explain setup.
  bool get isConfigured => _apiKey.isNotEmpty;

  @override
  Future<List<RecognizedLabel>> recognize(Uint8List imageBytes) async {
    if (_apiKey.isEmpty) return const [];

    final uri = Uri.parse('$_endpoint?key=$_apiKey');
    final payload = jsonEncode({
      'requests': [
        {
          'image': {'content': base64Encode(imageBytes)},
          'features': [
            {'type': 'LABEL_DETECTION', 'maxResults': _maxResults},
          ],
        },
      ],
    });

    try {
      final response = await _client.post(
        uri,
        headers: const {'Content-Type': 'application/json'},
        body: payload,
      );
      if (response.statusCode != 200) return const [];
      return _parse(response.body);
    } catch (_) {
      // Network/parse failure → no guesses; the UI offers the manual picker.
      return const [];
    }
  }

  /// Turn a Vision `images:annotate` response into kid-friendly labels.
  List<RecognizedLabel> _parse(String body) {
    final decoded = jsonDecode(body);
    if (decoded is! Map<String, dynamic>) return const [];
    final responses = decoded['responses'];
    if (responses is! List || responses.isEmpty) return const [];
    final first = responses.first;
    if (first is! Map<String, dynamic>) return const [];
    final annotations = first['labelAnnotations'];
    if (annotations is! List) return const [];

    final results = <RecognizedLabel>[];
    for (final annotation in annotations) {
      if (annotation is! Map<String, dynamic>) continue;
      final score = (annotation['score'] as num?)?.toDouble() ?? 0;
      if (score < _confidenceThreshold) continue;
      final description = (annotation['description'] as String?)?.trim();
      if (description == null || description.isEmpty) continue;
      results.add(LabelCatalog.present(description, score));
    }
    return results;
  }

  @override
  Future<void> close() async => _client.close();
}
