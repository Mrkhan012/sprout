import 'package:flutter_tts/flutter_tts.dart';

/// Thin wrapper around the device's text-to-speech engine, tuned for little
/// ears: a slow, clear rate and a bright pitch.
///
/// One instance is owned by each feature ViewModel that needs narration (Story
/// Time, Puzzle, Pop the Bubbles, Nature Hunt). All calls are best-effort —
/// failures (no engine, unsupported platform, a test) are swallowed so voice is
/// always a delightful extra, never something that can break a screen.
///
/// Use [SpeechService.silent] in tests / on platforms with no audio: it touches
/// no platform channels and every method is a no-op.
class SpeechService {
  SpeechService() : _tts = FlutterTts();
  SpeechService.silent() : _tts = null;

  final FlutterTts? _tts;
  Future<void>? _configured;

  Future<void> _configure() async {
    final tts = _tts;
    if (tts == null) return;
    try {
      await tts.setLanguage('en-US');
      await tts.setSpeechRate(0.45); // slow & clear for early ears
      await tts.setPitch(1.1); // bright, friendly
      await tts.setVolume(1.0);
    } catch (_) {
      // Engine not available — stay silent rather than crash.
    }
  }

  /// Speak [text], interrupting anything already playing so the latest line wins.
  Future<void> speak(String text) async {
    final tts = _tts;
    if (tts == null || text.trim().isEmpty) return;
    _configured ??= _configure();
    await _configured;
    try {
      await tts.stop();
      await tts.speak(text);
    } catch (_) {}
  }

  /// Stop any current narration.
  Future<void> stop() async {
    try {
      await _tts?.stop();
    } catch (_) {}
  }

  /// Release the engine. Call from the owning ViewModel's `close()`/`dispose()`.
  Future<void> dispose() async {
    try {
      await _tts?.stop();
    } catch (_) {}
  }
}
