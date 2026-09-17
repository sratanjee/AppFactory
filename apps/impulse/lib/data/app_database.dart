import 'package:drift/drift.dart';
import 'package:factory_core/factory_core.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

part 'app_database.g.dart';

class Items extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text()();
  IntColumn get priceMinor => integer()();
  TextColumn get currency => text().withLength(min: 3, max: 3)();
  IntColumn get createdAt => integer()();
  IntColumn get decideAt => integer()();
  TextColumn get decision => text().nullable()();
  IntColumn get decidedAt => integer().nullable()();
}

@DriftDatabase(tables: [Items])
class AppDatabase extends _$AppDatabase {
  AppDatabase({required String appSlug})
      : super(FactoryDatabase.open(appSlug: appSlug, dbName: 'app'));

  AppDatabase.inMemory() : super(FactoryDatabase.openInMemory());

  @override
  int get schemaVersion => 1;
}

final appDatabaseProvider = Provider<AppDatabase>((ref) {
  final slug = ref.watch(appSlugProvider);
  final db = AppDatabase(appSlug: slug);
  ref.onDispose(db.close);
  return db;
});
