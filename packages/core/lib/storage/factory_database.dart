import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:drift_flutter/drift_flutter.dart';

/// Helper for opening per-app Drift databases with the factory's standard
/// file-naming convention: `<appSlug>_<dbName>.sqlite` under the platform's
/// app-documents directory (via `drift_flutter`).
///
/// Apps write normal Drift code and pass the returned executor to their
/// AppDatabase's `super(...)` call. This helper does not wrap Drift itself —
/// it only standardises where the file lives.
///
/// ```dart
/// @DriftDatabase(tables: [Habits, HabitEntries])
/// class AppDatabase extends _$AppDatabase {
///   AppDatabase({required String appSlug})
///       : super(FactoryDatabase.open(appSlug: appSlug, dbName: 'app'));
///
///   @override
///   int get schemaVersion => 1;
/// }
/// ```
class FactoryDatabase {
  FactoryDatabase._();

  /// Opens a persistent, per-app SQLite-backed executor.
  static QueryExecutor open({
    required String appSlug,
    required String dbName,
  }) {
    return driftDatabase(name: '${appSlug}_$dbName');
  }

  /// In-memory executor for tests. Nothing is persisted.
  static QueryExecutor openInMemory() {
    return NativeDatabase.memory();
  }
}
