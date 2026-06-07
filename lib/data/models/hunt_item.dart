import 'dart:typed_data';

import 'package:equatable/equatable.dart';

/// One target in the Nature Hunt (Task 4).
///
/// The child is asked to find & snap five real-world things. Each item carries
/// the friendly prompt, an emoji cue, and — once snapped — the captured photo
/// bytes (stored as bytes so the same model renders on web, mobile and desktop
/// via `Image.memory`).
class HuntItem extends Equatable {
  const HuntItem({
    required this.label,
    required this.emoji,
    this.photo,
    this.foundAs,
  });

  final String label;
  final String emoji;

  /// JPEG bytes of the photo the child snapped, or null if not yet found.
  final Uint8List? photo;

  /// The kid-friendly category the child tagged the photo with.
  final String? foundAs;

  bool get isFound => photo != null;

  HuntItem copyWith({Uint8List? photo, String? foundAs}) => HuntItem(
        label: label,
        emoji: emoji,
        photo: photo ?? this.photo,
        foundAs: foundAs ?? this.foundAs,
      );

  @override
  List<Object?> get props => [label, emoji, photo, foundAs];
}
