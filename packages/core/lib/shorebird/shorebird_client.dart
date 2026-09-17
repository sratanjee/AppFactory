import 'package:flutter/foundation.dart';
import 'package:shorebird_code_push/shorebird_code_push.dart';

/// Thin facade over `ShorebirdUpdater`.
///
/// Apps consume this through `shorebirdClientProvider`. Direct
/// construction is only for tests.
///
/// Failures inside `checkAndUpdate` are swallowed and logged via
/// `debugPrint` — code-push should never break the app.
class ShorebirdClient {
  factory ShorebirdClient() => ShorebirdClient._();

  /// Test/no-op mode. `isAvailable` returns `false`, all methods are
  /// safe no-ops.
  factory ShorebirdClient.disabled() =>
      ShorebirdClient._(forceDisabled: true);

  ShorebirdClient._({ShorebirdUpdater? updater, this.forceDisabled = false})
      : _updater = updater ?? ShorebirdUpdater();

  final ShorebirdUpdater _updater;
  final bool forceDisabled;

  /// True when the app was launched from a Shorebird-built binary.
  /// False in a plain `fvm flutter run` and in tests.
  bool get isAvailable => !forceDisabled && _updater.isAvailable;

  /// The currently-running patch number, or `null` when the updater
  /// isn't available or no patch is installed.
  Future<int?> currentPatchNumber() async {
    if (!isAvailable) return null;
    try {
      final patch = await _updater.readCurrentPatch();
      return patch?.number;
    } on Object catch (e, st) {
      _warn('readCurrentPatch failed', e, st);
      return null;
    }
  }

  /// Fire-and-forget update check. If a new patch is available, it's
  /// downloaded and takes effect on **next launch** (Shorebird's model).
  /// Called once at boot by `bootstrapShorebird`.
  Future<void> checkAndUpdate() async {
    if (!isAvailable) return;
    try {
      final status = await _updater.checkForUpdate();
      if (status == UpdateStatus.outdated) {
        await _updater.update();
      }
    } on Object catch (e, st) {
      _warn('checkAndUpdate failed', e, st);
    }
  }

  void _warn(String label, Object error, StackTrace stack) {
    if (kDebugMode) {
      debugPrint('⚠️  [factory_core/shorebird] $label: $error');
    }
  }
}
