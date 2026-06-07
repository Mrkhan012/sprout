import 'package:flutter_bloc/flutter_bloc.dart';

import 'splash_state.dart';

/// ViewModel for the intro screen: reveals the "Let's play!" call-to-action
/// after a short branded pause (where a real app would warm up services).
class SplashCubit extends Cubit<SplashState> {
  SplashCubit() : super(const SplashState(SplashStatus.loading));

  Future<void> init() async {
    await Future<void>.delayed(const Duration(milliseconds: 1300));
    if (!isClosed) emit(const SplashState(SplashStatus.ready));
  }
}
