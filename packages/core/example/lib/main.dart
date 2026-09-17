import 'package:factory_core/factory_core.dart';
import 'package:factory_core_example/app.dart';
import 'package:flutter/widgets.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  bootstrapShorebird();
  runApp(const ExampleApp());
}
