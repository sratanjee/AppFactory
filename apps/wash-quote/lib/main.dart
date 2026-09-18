import 'package:factory_core/factory_core.dart';
import 'package:flutter/widgets.dart';
import 'package:wash_quote/app.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  bootstrapShorebird();
  runApp(const WashQuoteApp());
}
