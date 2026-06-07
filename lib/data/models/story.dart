import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

/// One page of a Story Time tale (the "M" in MVVM).
///
/// A page is a single line of narration with a big emoji "illustration" and an
/// accent colour for its picture card. The narration text is what the
/// text-to-speech voice reads aloud.
class StoryPage extends Equatable {
  const StoryPage({
    required this.text,
    required this.emoji,
    required this.color,
  });

  final String text;
  final String emoji;
  final Color color;

  @override
  List<Object?> get props => [text, emoji, color];
}

/// A complete picture-book story: a title and its ordered pages.
class Story extends Equatable {
  const Story({required this.title, required this.pages});

  final String title;
  final List<StoryPage> pages;

  @override
  List<Object?> get props => [title, pages];
}
