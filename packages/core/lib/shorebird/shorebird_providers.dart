import 'package:factory_core/shorebird/shorebird_client.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// The app's Shorebird client. Real by default; override with
/// `ShorebirdClient.disabled()` in tests.
final shorebirdClientProvider = Provider<ShorebirdClient>((ref) {
  return ShorebirdClient();
});

/// Async provider for the currently-running patch number. `null` when
/// Shorebird isn't available or no patch is installed.
final currentPatchProvider = FutureProvider<int?>((ref) {
  return ref.watch(shorebirdClientProvider).currentPatchNumber();
});
