// Smoke + unit tests for Sprout.

import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:sprout/app/sprout_app.dart';
import 'package:sprout/data/models/reward.dart';
import 'package:sprout/data/repositories/activity_repository.dart';
import 'package:sprout/data/services/cloud_image_recognizer.dart';
import 'package:sprout/data/services/image_recognizer.dart';
import 'package:sprout/data/services/label_catalog.dart';
import 'package:sprout/features/rewards/viewmodel/rewards_cubit.dart';
import 'package:sprout/features/tap_play/viewmodel/tap_play_bloc.dart';
import 'package:sprout/features/tap_play/viewmodel/tap_play_event.dart';

void main() {
  setUpAll(() {
    // Don't hit the network for fonts during tests — fall back gracefully.
    GoogleFonts.config.allowRuntimeFetching = false;
  });

  testWidgets('App boots to the branded splash screen', (tester) async {
    await tester.pumpWidget(const SproutApp());
    await tester.pump();

    expect(find.text('Sprout'), findsWidgets);
    expect(
      find.text('Little minds. Big adventures. Every day.'),
      findsOneWidget,
    );

    // Advance past the splash reveal timer, then settle the entrance + CTA
    // animations so no timers leak past the test.
    await tester.pump(const Duration(milliseconds: 1400));
    await tester.pumpAndSettle();
  });

  group('RewardsCubit', () {
    test('awards a sticker and de-duplicates by id', () {
      final cubit = RewardsCubit();
      const reward = Reward(
        id: 'r1',
        label: 'Star',
        emoji: '⭐',
        color: Color(0xFF000000),
      );

      cubit.award(reward);
      cubit.award(reward); // duplicate is ignored

      expect(cubit.state.count, 1);
    });
  });

  group('TapPlayBloc', () {
    test('lays out a full field and completes when all bubbles pop', () async {
      final bloc = TapPlayBloc(bubbleCount: 3)..add(const TapPlayStarted());
      await pumpEventQueue();

      expect(bloc.state.total, 3);
      expect(bloc.state.isComplete, isFalse);

      for (final bubble in List.of(bloc.state.bubbles)) {
        bloc.add(BubblePopped(bubble.id));
      }
      await pumpEventQueue();

      expect(bloc.state.popped, 3);
      expect(bloc.state.isComplete, isTrue);

      await bloc.close();
    });
  });

  test('ActivityRepository serves activities and 5 hunt targets', () {
    const repo = ActivityRepository();
    expect(repo.getActivities(), isNotEmpty);
    expect(repo.getHuntTargets().length, 5);
    expect(repo.getLabelChoices(), isNotEmpty);
  });

  group('LabelCatalog', () {
    test('maps a known label to its emoji, preserving the model text', () {
      final result = LabelCatalog.present('Flower', 0.91);
      expect(result.label, 'Flower');
      expect(result.emoji, '🌸');
      expect(result.confidencePercent, 91);
      expect(result.display, '🌸 Flower');
    });

    test('is case-insensitive on the raw label', () {
      expect(LabelCatalog.present('TEDDY BEAR', 0.5).emoji, '🧸');
    });

    test('matches a known word inside a multi-word cloud label', () {
      // Cloud Vision often returns phrases like "Personal computer".
      expect(LabelCatalog.present('Personal computer', 0.9).emoji, '💻');
    });

    test('falls back to a sparkle for an unknown label', () {
      final result = LabelCatalog.present('Quasar', 0.5);
      expect(result.emoji, '✨');
      expect(result.label, 'Quasar');
    });
  });

  test('UnavailableImageRecognizer yields no guesses (manual fallback)',
      () async {
    const recognizer = UnavailableImageRecognizer();
    expect(await recognizer.recognize(Uint8List(0)), isEmpty);
    await recognizer.close();
  });

  group('CloudImageRecognizer', () {
    test('parses Vision labels, sparks emoji & drops low-confidence guesses',
        () async {
      final mock = MockClient((request) async {
        return http.Response(
          jsonEncode({
            'responses': [
              {
                'labelAnnotations': [
                  {'description': 'Laptop', 'score': 0.98},
                  {'description': 'Computer', 'score': 0.95},
                  {'description': 'Smudge', 'score': 0.20}, // below threshold
                ],
              },
            ],
          }),
          200,
        );
      });

      final recognizer = CloudImageRecognizer(
        apiKey: 'test-key',
        client: mock,
        confidenceThreshold: 0.6,
      );
      final results = await recognizer.recognize(Uint8List.fromList([1, 2, 3]));

      expect(results.map((r) => r.label), ['Laptop', 'Computer']);
      expect(results.first.emoji, '💻');
      expect(results.first.confidencePercent, 98);
      await recognizer.close();
    });

    test('returns no guesses (manual fallback) when no API key is configured',
        () async {
      final recognizer = CloudImageRecognizer(apiKey: '');
      expect(recognizer.isConfigured, isFalse);
      expect(await recognizer.recognize(Uint8List.fromList([1])), isEmpty);
      await recognizer.close();
    });
  });
}
