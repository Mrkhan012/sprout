import 'package:equatable/equatable.dart';

import '../../../data/models/reward.dart';

/// State for the app-wide sticker collection.
class RewardsState extends Equatable {
  const RewardsState({this.rewards = const []});

  final List<Reward> rewards;

  bool get isEmpty => rewards.isEmpty;
  int get count => rewards.length;

  RewardsState copyWith({List<Reward>? rewards}) =>
      RewardsState(rewards: rewards ?? this.rewards);

  @override
  List<Object?> get props => [rewards];
}
