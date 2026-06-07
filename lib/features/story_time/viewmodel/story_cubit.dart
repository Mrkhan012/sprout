import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../data/repositories/activity_repository.dart';
import '../../../data/services/speech_service.dart';
import 'story_state.dart';

/// ViewModel for Story Time.
///
/// Walks the child through a picture-book one page at a time and reads each page
/// aloud with the [SpeechService] (the child can mute the voice). Simple page
/// state, so a Cubit rather than a full event Bloc.
class StoryCubit extends Cubit<StoryState> {
  StoryCubit(this._repository, {SpeechService? speech})
      : _speech = speech ?? SpeechService(),
        super(const StoryState());

  final ActivityRepository _repository;
  final SpeechService _speech;

  /// Load the story and start narrating page one.
  void load() {
    final story = _repository.getStory();
    emit(StoryState(title: story.title, pages: story.pages));
    _narrate();
  }

  void next() {
    if (state.isLast || state.current == null) return;
    emit(state.copyWith(index: state.index + 1));
    _narrate();
  }

  void previous() {
    if (state.isFirst) return;
    emit(state.copyWith(index: state.index - 1));
    _narrate();
  }

  /// Toggle the read-aloud voice. Turning it on reads the current page again;
  /// turning it off stops any narration.
  void toggleVoice() {
    final on = !state.voiceOn;
    emit(state.copyWith(voiceOn: on));
    if (on) {
      _narrate();
    } else {
      _speech.stop();
    }
  }

  /// "Read it again" — speak the current page even if the child just heard it.
  void replay() {
    final page = state.current;
    if (page != null) _speech.speak(page.text);
  }

  /// Reach "The End" — stop the voice and trigger the reward + celebration.
  void finish() {
    _speech.stop();
    _speech.speak('The end! What a lovely story.');
    emit(state.copyWith(finished: true));
  }

  /// Read the story again from page one.
  void restart() {
    emit(state.copyWith(index: 0, finished: false));
    _narrate();
  }

  void _narrate() {
    if (!state.voiceOn) return;
    final page = state.current;
    if (page != null) _speech.speak(page.text);
  }

  @override
  Future<void> close() async {
    await _speech.dispose();
    return super.close();
  }
}
