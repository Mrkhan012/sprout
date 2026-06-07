import 'package:equatable/equatable.dart';

import '../../../data/models/activity.dart';

/// State for the Home screen: the list of activity cards to show.
class HomeState extends Equatable {
  const HomeState({this.activities = const []});

  final List<Activity> activities;

  @override
  List<Object?> get props => [activities];
}
