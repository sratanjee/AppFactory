import 'package:factory_core/shorebird/shorebird.dart';
import 'package:flutter/widgets.dart';
import 'package:olympia_weekend/app.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  bootstrapShorebird();
  runApp(const OlympiaWeekendApp());
}
