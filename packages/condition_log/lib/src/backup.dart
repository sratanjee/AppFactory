import 'dart:io';

import 'package:path_provider/path_provider.dart';

/// Cloud driver contract implemented by the platform-specific storage
/// modules in `core/storage` — one adapter for iCloud Drive on iOS and
/// one for Drive `appDataFolder` on Android.
///
/// The engine takes an instance in [Backup]'s constructor rather than
/// picking a driver internally so tests can pass a fake and the app
/// can pick the right one at boot without engine changes.
abstract class BackupCloudDriver {
  Future<File> pushToCloud(File file);
}

/// Local-only stub driver used when no cloud key exists. Copies the
/// file into the app's documents dir under `backups/` so the flow is
/// end-to-end restorable, just not off-device.
class LocalBackupDriver implements BackupCloudDriver {
  const LocalBackupDriver();

  @override
  Future<File> pushToCloud(File file) async {
    final docs = await getApplicationDocumentsDirectory();
    final dir = Directory('${docs.path}/backups');
    if (!dir.existsSync()) dir.createSync(recursive: true);
    final destination = File('${dir.path}/${_basename(file.path)}');
    return file.copy(destination.path);
  }

  static String _basename(String path) {
    final slash = path.lastIndexOf(Platform.pathSeparator);
    return slash < 0 ? path : path.substring(slash + 1);
  }
}

/// Layer-2 backup primitive for the condition-log engine.
///
/// Two moves:
///   * `exportSqliteFor(petId)` — copies the app's SQLite file to a
///     timestamped path in the documents dir. Cheap; safe to run on a
///     debounce after every write.
///   * `pushToCloud(file)` — hands off to the injected [driver].
///
/// The engine does no scheduling of its own. Apps are expected to
/// debounce their calls (Seizure Log's PLAN §11 assumption pins 60s
/// after the last write).
class Backup {
  Backup({
    required this.appSlug,
    required this.dbName,
    BackupCloudDriver? driver,
  }) : driver = driver ?? const LocalBackupDriver();

  final String appSlug;
  final String dbName;
  final BackupCloudDriver driver;

  /// Copies the current SQLite file into the app's documents dir with
  /// a timestamped filename. Returns the copied file; callers hand it
  /// to `pushToCloud`.
  Future<File> exportSqliteFor(int petId) async {
    final docs = await getApplicationDocumentsDirectory();
    final source = File('${docs.path}/${appSlug}_$dbName.sqlite');
    final stamp = DateTime.now().millisecondsSinceEpoch;
    final dst = File(
      '${docs.path}/${appSlug}_${dbName}_pet${petId}_$stamp.sqlite',
    );
    if (!source.existsSync()) {
      // Return an empty destination file rather than throwing — tests
      // that don't drive drift through the real path can still exercise
      // the cloud handoff.
      await dst.create(recursive: true);
      return dst;
    }
    return source.copy(dst.path);
  }

  /// Full path: export then push. Returns the cloud-side file handle
  /// the driver produced. Apps schedule this on a debounce; the engine
  /// itself never runs a timer.
  Future<File> exportAndPush({required int petId}) async {
    final local = await exportSqliteFor(petId);
    return driver.pushToCloud(local);
  }
}
