import 'package:equatable/equatable.dart';

enum SplashStatus { loading, ready }

/// State for the branded intro screen.
class SplashState extends Equatable {
  const SplashState(this.status);

  final SplashStatus status;

  bool get isReady => status == SplashStatus.ready;

  @override
  List<Object?> get props => [status];
}
