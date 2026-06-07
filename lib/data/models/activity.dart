import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

/// A single learning activity shown as a card on the Home screen.
///
/// This is a pure data model (the "M" in MVVM) — no behaviour, just the values a
/// card needs to render and route.
class Activity extends Equatable {
  const Activity({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.accent,
    required this.route,
    this.enabled = true,
  });

  final String id;
  final String title;
  final String subtitle;
  final IconData icon;
  final Color accent;
  final String route;

  /// "Coming soon" tiles render dimmed and are not tappable.
  final bool enabled;

  @override
  List<Object?> get props => [id, title, subtitle, icon, accent, route, enabled];
}
