import 'package:drift/drift.dart';
import 'package:factory_core/factory_core.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

part 'app_database.g.dart';

@DataClassName('Business')
class Businesses extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text()();
  TextColumn get logoPath => text().nullable()();
  TextColumn get phone => text().nullable()();
  TextColumn get email => text().nullable()();
  TextColumn get address => text().nullable()();
  TextColumn get payVia => text().withDefault(const Constant(''))();
  IntColumn get defaultDepositPct => integer().withDefault(const Constant(25))();
  TextColumn get termsText => text().nullable()();
  IntColumn get nextJobNumber =>
      integer().withDefault(const Constant(1001))();
}

class Customers extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text()();
  TextColumn get phone => text().nullable()();
  TextColumn get email => text().nullable()();
  TextColumn get address => text().nullable()();
}

class Services extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text()();
  TextColumn get unit => text()();
  IntColumn get unitPriceCents => integer()();
  IntColumn get sortOrder => integer().withDefault(const Constant(0))();
}

class Jobs extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get customerId => integer().nullable()();
  TextColumn get status => text()();
  IntColumn get number => integer()();
  IntColumn get createdAt => integer()();
  IntColumn get sentAt => integer().nullable()();
  IntColumn get acceptedAt => integer().nullable()();
  IntColumn get paidAt => integer().nullable()();
  IntColumn get depositPct => integer().withDefault(const Constant(25))();
  TextColumn get notes => text().nullable()();
  TextColumn get stripeLinkUrl => text().nullable()();
}

class LineItems extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get jobId => integer()();
  IntColumn get serviceId => integer().nullable()();
  TextColumn get description => text()();
  RealColumn get qty => real()();
  IntColumn get unitPriceCents => integer()();
  IntColumn get totalCents => integer()();
}

class Photos extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get jobId => integer()();
  TextColumn get path => text()();
  TextColumn get kind => text()();
  IntColumn get takenAt => integer()();
  TextColumn get caption => text().nullable()();
}

@DriftDatabase(
  tables: [Businesses, Customers, Services, Jobs, LineItems, Photos],
)
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
