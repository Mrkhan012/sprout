import 'dart:typed_data';

import 'package:equatable/equatable.dart';

import '../../../data/models/hunt_item.dart';
import '../../../data/services/image_recognizer.dart';

enum HuntStatus {
  initializing,
  ready, // viewfinder live, waiting for a snap
  recognizing, // photo taken, model is identifying it
  captured, // photo identified, waiting for the child to confirm
  complete, // all targets found
  permissionDenied,
  error,
}

/// State for the Nature Hunt activity.
class CameraHuntState extends Equatable {
  const CameraHuntState({
    this.status = HuntStatus.initializing,
    this.items = const [],
    this.currentIndex = 0,
    this.capturedPhoto,
    this.results = const [],
    this.errorMessage,
  });

  final HuntStatus status;
  final List<HuntItem> items;
  final int currentIndex;
  final Uint8List? capturedPhoto;

  /// What the on-device model thinks the snapped photo shows, best guess first.
  /// Empty once cleared, or when the model couldn't tell.
  final List<RecognizedLabel> results;

  final String? errorMessage;

  int get total => items.length;
  int get foundCount => items.where((i) => i.isFound).length;

  /// The model's best guess for the current photo, or null if none.
  RecognizedLabel? get topResult => results.isNotEmpty ? results.first : null;

  /// Up to two runner-up guesses, for the "or maybe…" chips.
  List<RecognizedLabel> get otherResults =>
      results.length > 1 ? results.sublist(1, results.length.clamp(0, 3)) : const [];

  HuntItem? get currentTarget =>
      currentIndex >= 0 && currentIndex < items.length
          ? items[currentIndex]
          : null;

  CameraHuntState copyWith({
    HuntStatus? status,
    List<HuntItem>? items,
    int? currentIndex,
    Uint8List? capturedPhoto,
    List<RecognizedLabel>? results,
    bool clearCaptured = false,
    String? errorMessage,
  }) {
    return CameraHuntState(
      status: status ?? this.status,
      items: items ?? this.items,
      currentIndex: currentIndex ?? this.currentIndex,
      capturedPhoto:
          clearCaptured ? null : (capturedPhoto ?? this.capturedPhoto),
      results: clearCaptured ? const [] : (results ?? this.results),
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props =>
      [status, items, currentIndex, capturedPhoto, results, errorMessage];
}
