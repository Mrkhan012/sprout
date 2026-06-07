import 'dart:typed_data';

import 'package:equatable/equatable.dart';

import '../../../data/models/hunt_item.dart';

enum HuntStatus {
  initializing,
  ready, // viewfinder live, waiting for a snap
  captured, // photo taken, waiting for a label
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
    this.errorMessage,
  });

  final HuntStatus status;
  final List<HuntItem> items;
  final int currentIndex;
  final Uint8List? capturedPhoto;
  final String? errorMessage;

  int get total => items.length;
  int get foundCount => items.where((i) => i.isFound).length;

  HuntItem? get currentTarget =>
      currentIndex >= 0 && currentIndex < items.length
          ? items[currentIndex]
          : null;

  CameraHuntState copyWith({
    HuntStatus? status,
    List<HuntItem>? items,
    int? currentIndex,
    Uint8List? capturedPhoto,
    bool clearCaptured = false,
    String? errorMessage,
  }) {
    return CameraHuntState(
      status: status ?? this.status,
      items: items ?? this.items,
      currentIndex: currentIndex ?? this.currentIndex,
      capturedPhoto:
          clearCaptured ? null : (capturedPhoto ?? this.capturedPhoto),
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props =>
      [status, items, currentIndex, capturedPhoto, errorMessage];
}
