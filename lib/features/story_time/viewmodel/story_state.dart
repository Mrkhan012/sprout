import 'package:equatable/equatable.dart';

import '../../../data/models/story.dart';

/// State for the Story Time reader.
class StoryState extends Equatable {
  const StoryState({
    this.title = '',
    this.pages = const [],
    this.index = 0,
    this.voiceOn = true,
    this.finished = false,
  });

  final String title;
  final List<StoryPage> pages;
  final int index;

  /// Whether the read-aloud voice is on (the child can mute/unmute).
  final bool voiceOn;

  /// True once the child reaches "The End" — drives the reward + celebration.
  final bool finished;

  StoryPage? get current =>
      index >= 0 && index < pages.length ? pages[index] : null;

  int get total => pages.length;
  bool get isFirst => index == 0;
  bool get isLast => pages.isNotEmpty && index == pages.length - 1;

  StoryState copyWith({
    String? title,
    List<StoryPage>? pages,
    int? index,
    bool? voiceOn,
    bool? finished,
  }) {
    return StoryState(
      title: title ?? this.title,
      pages: pages ?? this.pages,
      index: index ?? this.index,
      voiceOn: voiceOn ?? this.voiceOn,
      finished: finished ?? this.finished,
    );
  }

  @override
  List<Object?> get props => [title, pages, index, voiceOn, finished];
}
