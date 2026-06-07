import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

/// A sticker the child has earned by completing an activity.
class Reward extends Equatable {
  const Reward({
    required this.id,
    required this.label,
    required this.emoji,
    required this.color,
  });

  final String id;
  final String label;
  final String emoji;
  final Color color;

  @override
  List<Object?> get props => [id, label, emoji, color];
}
