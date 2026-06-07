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
    if (_apiKey.isEmpty) {
      throw const RecognizerException(
        'No Vision API key. Set --dart-define=VISION_API_KEY=... in launch.json.',
      );
    }

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

    http.Response response;
    try {
      response = await _client.post(
        uri,
        headers: const {'Content-Type': 'application/json'},
        body: payload,
      );
    } catch (e) {
      throw RecognizerException('Network error reaching Vision: $e');
    }

    if (response.statusCode != 200) {
      // Vision puts the real reason (bad key, API disabled, billing) here.
      throw RecognizerException(
        _errorMessage(response.body) ?? 'Vision HTTP ${response.statusCode}',
      );
    }
    return _parse(response.body);
  }

  /// Turn a Vision `images:annotate` response into kid-friendly labels, or throw
  /// [RecognizerException] if the response carries an error instead of labels.
  List<RecognizedLabel> _parse(String body) {
    final Object? decoded = jsonDecode(body);
    if (decoded is! Map<String, dynamic>) return const [];

    // Request-level error (e.g. key/permission) can arrive even with HTTP 200.
    final topError = _messageFrom(decoded['error']);
    if (topError != null) throw RecognizerException(topError);

    final responses = decoded['responses'];
    if (responses is! List || responses.isEmpty) return const [];
    final first = responses.first;
    if (first is! Map<String, dynamic>) return const [];

    // Per-image error (e.g. "billing must be enabled").
    final imageError = _messageFrom(first['error']);
    if (imageError != null) throw RecognizerException(imageError);

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

  /// Extract `error.message` from a raw Vision error body, if present.
  String? _errorMessage(String body) {
    try {
      final decoded = jsonDecode(body);
      return decoded is Map<String, dynamic> ? _messageFrom(decoded['error']) : null;
    } catch (_) {
      return null;
    }
  }

  /// `{code, message, status}` → `"PERMISSION_DENIED: <message>"`.
  String? _messageFrom(Object? error) {
    if (error is! Map<String, dynamic>) return null;
    final message = error['message'] as String?;
    if (message == null || message.isEmpty) return null;
    final status = error['status'] as String?;
    return status == null ? message : '$status: $message';
  }

  @override
  Future<void> close() async => _client.close();
}
