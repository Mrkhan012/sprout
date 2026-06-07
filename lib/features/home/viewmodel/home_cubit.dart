import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../data/repositories/activity_repository.dart';
import 'home_state.dart';

/// ViewModel for Home. Pulls the activity list from the repository so the View
/// never hard-codes content.
class HomeCubit extends Cubit<HomeState> {
  HomeCubit(this._repository) : super(const HomeState());

  final ActivityRepository _repository;

  void load() => emit(HomeState(activities: _repository.getActivities()));
}
