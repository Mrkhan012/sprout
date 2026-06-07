import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

/// A single tappable bubble in the Pop the Bubbles activity.
///
/// Position is stored as a fraction (0–1) of the play area so it scales to any
/// screen size; the View turns it into pixels with the current constraints.
class Bubble extends Equatable {
  const Bubble({
    required this.id,
    required this.dx,
    required this.dy,
    required this.diameter,
    required this.color,
    required this.emoji,
    this.popped = false,
  });

  final int id;
  final double dx;
  final double dy;
  final double diameter;
  final Color color;
  final String emoji;
  final bool popped;

  Bubble copyWith({bool? popped}) => Bubble(
        id: id,
        dx: dx,
        dy: dy,
        diameter: diameter,
        color: color,
        emoji: emoji,
        popped: popped ?? this.popped,
      );

  @override
  List<Object?> get props => [id, dx, dy, diameter, color, emoji, popped];
}
