import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../data/models/reward.dart';
import 'rewards_state.dart';

/// ViewModel for the sticker collection.
///
/// Provided at the app root so any activity can [award] a sticker and the
/// Rewards screen reflects it immediately. In-memory for now; swapping in a
/// persistent store (Hive / Firebase) would only touch this class.
class RewardsCubit extends Cubit<RewardsState> {
  RewardsCubit() : super(const RewardsState());

  /// Adds a sticker once — earning the same reward twice is a no-op so the
  /// sticker book shows a clean set.
  void award(Reward reward) {
    if (state.rewards.any((r) => r.id == reward.id)) return;
    emit(state.copyWith(rewards: [...state.rewards, reward]));
  }

  void reset() => emit(const RewardsState());
}
