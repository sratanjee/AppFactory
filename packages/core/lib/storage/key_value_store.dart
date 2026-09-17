import 'dart:async';
import 'dart:convert';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:drift_flutter/drift_flutter.dart';

part 'key_value_store.g.dart';

const _kString = 'string';
const _kInt = 'int';
const _kDouble = 'double';
const _kBool = 'bool';
const _kDateTime = 'datetime';
const _kJson = 'json';

class KvEntries extends Table {
  TextColumn get key => text()();
  TextColumn get value => text().nullable()();
  TextColumn get kind => text()();
  IntColumn get updatedAt => integer()();

  @override
  Set<Column<Object>> get primaryKey => {key};

  @override
  String get tableName => 'kv';
}

@DriftDatabase(tables: [KvEntries])
class KvDatabase extends _$KvDatabase {
  KvDatabase(super.e);

  @override
  int get schemaVersion => 1;
}

/// Scalar-prefs store backed by a small Drift database per app.
///
/// Persist single-value settings (`hasSeenOnboarding`, `lastOpenDate`,
/// `preferredUnits`, etc.). Structured data belongs in the app's own
/// `AppDatabase` via `FactoryDatabase.open`, not here.
///
/// Kind-mismatch reads return `null` rather than throwing, so an app that
/// changes the type of a key across versions doesn't crash on the first
/// read after upgrade.
class KeyValueStore {
  KeyValueStore._(this._db);

  /// In-memory store for tests.
  factory KeyValueStore.inMemory() =>
      KeyValueStore._(KvDatabase(NativeDatabase.memory()));

  final KvDatabase _db;

  /// Opens the app's KV store. File: `<appSlug>_kv.sqlite`.
  static Future<KeyValueStore> open({required String appSlug}) async {
    return KeyValueStore._(KvDatabase(driftDatabase(name: '${appSlug}_kv')));
  }

  Future<void> close() => _db.close();

  // ---- Reads ------------------------------------------------------------

  Future<String?> getString(String key) => _read(key, _kString, _identity);

  Future<int?> getInt(String key) => _read(key, _kInt, int.parse);

  Future<double?> getDouble(String key) => _read(key, _kDouble, double.parse);

  Future<bool?> getBool(String key) => _read(key, _kBool, _parseBool);

  Future<DateTime?> getDateTime(String key) =>
      _read(key, _kDateTime, _parseDateTime);

  Future<Map<String, dynamic>?> getJson(String key) =>
      _read(key, _kJson, _parseJson);

  Future<List<String>> keys() async {
    final rows = await _db.select(_db.kvEntries).get();
    return rows.map((r) => r.key).toList();
  }

  Future<T?> _read<T>(
    String key,
    String kind,
    T Function(String) parse,
  ) async {
    final row = await (_db.select(_db.kvEntries)
          ..where((t) => t.key.equals(key)))
        .getSingleOrNull();
    if (row == null || row.kind != kind || row.value == null) return null;
    return parse(row.value!);
  }

  // ---- Writes -----------------------------------------------------------

  Future<void> setString(String key, String value) =>
      _write(key, _kString, value);

  Future<void> setInt(String key, int value) =>
      _write(key, _kInt, value.toString());

  Future<void> setDouble(String key, double value) =>
      _write(key, _kDouble, value.toString());

  // Positional value keeps the setBool signature symmetrical with
  // setString/setInt/setDouble across scalar types.
  // ignore: avoid_positional_boolean_parameters
  Future<void> setBool(String key, bool value) =>
      _write(key, _kBool, value ? '1' : '0');

  Future<void> setDateTime(String key, DateTime value) =>
      _write(key, _kDateTime, value.millisecondsSinceEpoch.toString());

  Future<void> setJson(String key, Map<String, dynamic> value) =>
      _write(key, _kJson, jsonEncode(value));

  Future<void> _write(String key, String kind, String value) async {
    await _db.into(_db.kvEntries).insertOnConflictUpdate(
          KvEntriesCompanion.insert(
            key: key,
            value: Value(value),
            kind: kind,
            updatedAt: DateTime.now().millisecondsSinceEpoch,
          ),
        );
  }

  Future<void> remove(String key) async {
    await (_db.delete(_db.kvEntries)..where((t) => t.key.equals(key))).go();
  }

  Future<void> clear() async {
    await _db.delete(_db.kvEntries).go();
  }

  // ---- Reactive ---------------------------------------------------------

  Stream<String?> watchString(String key) => _watch(key, _kString, _identity);

  Stream<int?> watchInt(String key) => _watch(key, _kInt, int.parse);

  Stream<double?> watchDouble(String key) =>
      _watch(key, _kDouble, double.parse);

  Stream<bool?> watchBool(String key) => _watch(key, _kBool, _parseBool);

  Stream<DateTime?> watchDateTime(String key) =>
      _watch(key, _kDateTime, _parseDateTime);

  Stream<Map<String, dynamic>?> watchJson(String key) =>
      _watch(key, _kJson, _parseJson);

  Stream<T?> _watch<T>(
    String key,
    String kind,
    T Function(String) parse,
  ) {
    return (_db.select(_db.kvEntries)..where((t) => t.key.equals(key)))
        .watchSingleOrNull()
        .map((row) {
      if (row == null || row.kind != kind || row.value == null) return null;
      return parse(row.value!);
    });
  }

  // ---- Parsers ----------------------------------------------------------

  static String _identity(String v) => v;
  static bool _parseBool(String v) => v == '1';
  static DateTime _parseDateTime(String v) =>
      DateTime.fromMillisecondsSinceEpoch(int.parse(v));
  static Map<String, dynamic> _parseJson(String v) =>
      jsonDecode(v) as Map<String, dynamic>;
}
