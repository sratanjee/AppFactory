import 'package:factory_core/factory_core.dart';
import 'package:flutter/widgets.dart';
import 'package:impulse/app.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  bootstrapShorebird();
  runApp(const ImpulseApp());
}
