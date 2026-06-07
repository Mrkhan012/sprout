import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'app/sprout_app.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  // Kids hold phones every which way, but the activities are designed portrait.
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  runApp(const SproutApp());
}
