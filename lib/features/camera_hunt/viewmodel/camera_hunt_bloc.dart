import 'package:camera/camera.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../data/repositories/activity_repository.dart';
import '../../../data/services/image_recognizer.dart';
import '../../../data/services/image_recognizer_factory.dart';
import 'camera_hunt_event.dart';
import 'camera_hunt_state.dart';

/// ViewModel for the Nature Hunt (Task 4).
///
/// Owns the [CameraController] hardware resource (created on [HuntStarted],
/// released on [close] / [HuntPaused]) and an [ImageRecognizer] that identifies
/// each snapped photo. Walks the child through finding & snapping five things,
/// auto-labels each with what the recognizer sees, then celebrates.
class CameraHuntBloc extends Bloc<CameraHuntEvent, CameraHuntState> {
  CameraHuntBloc(this._repository, {ImageRecognizer? recognizer})
      : _recognizer = recognizer ?? createImageRecognizer(),
        super(const CameraHuntState()) {
    on<HuntStarted>(_onStarted);
    on<HuntPhotoCaptured>(_onCaptured);
    on<HuntLabelSelected>(_onLabelSelected);
    on<HuntRetake>(_onRetake);
    on<HuntReset>(_onReset);
    on<HuntPaused>(_onPaused);
    on<HuntResumed>(_onResumed);
  }

  final ActivityRepository _repository;
  final ImageRecognizer _recognizer;

  CameraController? _controller;

  /// Exposed (read-only) so the View can render the live preview.
  CameraController? get controller => _controller;

  /// Friendly fallback labels used only when the model can't tell (or on a
  /// platform without on-device recognition).
  List<String> get labelChoices => _repository.getLabelChoices();

  Future<void> _onStarted(
    HuntStarted event,
    Emitter<CameraHuntState> emit,
  ) async {
    emit(state.copyWith(
      status: HuntStatus.initializing,
      items: _repository.getHuntTargets(),
      currentIndex: 0,
      clearCaptured: true,
    ));
    await _setUpCamera(emit);
  }

  /// (Re)create and initialise the camera without disturbing hunt progress.
  Future<void> _setUpCamera(Emitter<CameraHuntState> emit) async {
    try {
      final cameras = await availableCameras();
      if (cameras.isEmpty) {
        emit(state.copyWith(
          status: HuntStatus.error,
          errorMessage: 'No camera found on this device.',
        ));
        return;
      }
      final camera = cameras.firstWhere(
        (c) => c.lensDirection == CameraLensDirection.back,
        orElse: () => cameras.first,
      );
      final controller = CameraController(
        camera,
        ResolutionPreset.medium,
        enableAudio: false,
        imageFormatGroup: ImageFormatGroup.jpeg,
      );
      _controller = controller;
      await controller.initialize();
      emit(state.copyWith(status: HuntStatus.ready));
    } on CameraException catch (e) {
      if (e.code == 'CameraAccessDenied' ||
          e.code == 'CameraAccessDeniedWithoutPrompt' ||
          e.code == 'CameraAccessRestricted') {
        emit(state.copyWith(status: HuntStatus.permissionDenied));
      } else {
        emit(state.copyWith(
          status: HuntStatus.error,
          errorMessage: e.description ?? 'Could not open the camera.',
        ));
      }
    } catch (e) {
      emit(state.copyWith(
        status: HuntStatus.error,
        errorMessage: 'Could not open the camera.',
      ));
    }
  }

  Future<void> _onCaptured(
    HuntPhotoCaptured event,
    Emitter<CameraHuntState> emit,
  ) async {
    final controller = _controller;
    if (controller == null ||
        !controller.value.isInitialized ||
        controller.value.isTakingPicture ||
        state.status != HuntStatus.ready) {
      return;
    }
    try {
      final file = await controller.takePicture();
      final bytes = await file.readAsBytes();
      // Show the snapshot immediately with a "looking…" spinner, then identify
      // it via the recognizer.
      emit(state.copyWith(
        status: HuntStatus.recognizing,
        capturedPhoto: bytes,
        results: const [],
      ));
      final results = await _recognizer.recognize(bytes);
      // Guard against a retake/reset that landed while we were recognising.
      if (state.status != HuntStatus.recognizing) return;
      emit(state.copyWith(status: HuntStatus.captured, results: results));
    } catch (_) {
      // Couldn't snap or identify — drop the child back to the result step with
      // no guesses so they can name it themselves or retake.
      if (state.status == HuntStatus.recognizing) {
        emit(state.copyWith(status: HuntStatus.captured, results: const []));
      }
    }
  }

  void _onLabelSelected(
    HuntLabelSelected event,
    Emitter<CameraHuntState> emit,
  ) {
    final photo = state.capturedPhoto;
    if (photo == null) return;

    final items = [...state.items];
    items[state.currentIndex] =
        items[state.currentIndex].copyWith(photo: photo, foundAs: event.label);

    final allFound = items.every((i) => i.isFound);
    final nextIndex = (state.currentIndex + 1).clamp(0, items.length - 1);

    emit(state.copyWith(
      items: items,
      currentIndex: nextIndex,
      status: allFound ? HuntStatus.complete : HuntStatus.ready,
      clearCaptured: true,
    ));
  }

  void _onRetake(HuntRetake event, Emitter<CameraHuntState> emit) {
    emit(state.copyWith(status: HuntStatus.ready, clearCaptured: true));
  }

  void _onReset(HuntReset event, Emitter<CameraHuntState> emit) {
    emit(state.copyWith(
      items: _repository.getHuntTargets(),
      currentIndex: 0,
      status: HuntStatus.ready,
      clearCaptured: true,
    ));
  }

  Future<void> _onPaused(
    HuntPaused event,
    Emitter<CameraHuntState> emit,
  ) async {
    final controller = _controller;
    _controller = null;
    if (controller != null) {
      emit(state.copyWith(status: HuntStatus.initializing, clearCaptured: true));
      await controller.dispose();
    }
  }

  Future<void> _onResumed(
    HuntResumed event,
    Emitter<CameraHuntState> emit,
  ) async {
    if (_controller != null || state.status == HuntStatus.complete) return;
    await _setUpCamera(emit);
  }

  @override
  Future<void> close() async {
    await _controller?.dispose();
    _controller = null;
    await _recognizer.close();
    return super.close();
  }
}
