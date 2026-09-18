import 'package:drift/drift.dart';
import 'package:factory_core/storage/key_value_store.dart';
import 'package:flutter/foundation.dart';

/// Wipes an app's local state.
///
/// Intended for debug menus and integration-test harnesses: apps clear
/// the KV store (so first-run flags like `hasSeenOnboarding` re-fire) and
/// truncate every user-facing Drift table (so seeded rows come back on
/// next launch).
///
/// Refuses to run in release builds unless [allowInRelease] is true, so
/// a factory-scaffold slip-up can't ship a wipe button that end users can
/// hit. Apps that legitimately need a user-visible "sign out / clear
/// data" flow can pass `allowInRelease: true`.
Future<void> resetAppData({
  required KeyValueStore keyValueStore,
  required GeneratedDatabase database,
  bool allowInRelease = false,
}) async {
  if (kReleaseMode && !allowInRelease) {
    throw StateError(
      'resetAppData is debug-only. Pass allowInRelease:true from a UI '
      'flow that explicitly warns the user before running in release.',
    );
  }
  await keyValueStore.clear();
  // Delete rows from every user table (skipping Drift's internal SQLite
  // schema tables); a raw `DELETE FROM x` per table is faster than
  // recreating the schema and avoids re-running migrations.
  await database.transaction(() async {
    for (final table in database.allTables) {
      await database.delete(table).go();
    }
  });
}
