import 'dart:async';

import 'package:factory_core/shorebird/shorebird_client.dart';

/// Kicks off a background Shorebird update check. Non-blocking — apps
/// call this in `main()` right before `runApp` so the check starts as
/// early as possible; new patches land on next launch.
///
/// ```dart
/// void main() {
///   WidgetsFlutterBinding.ensureInitialized();
///   bootstrapShorebird();
///   runApp(const MyApp());
/// }
/// ```
///
/// Never throws. In a non-Shorebird build the call is a no-op.
void bootstrapShorebird({ShorebirdClient? client}) {
  final c = client ?? ShorebirdClient();
  unawaited(c.checkAndUpdate());
}
