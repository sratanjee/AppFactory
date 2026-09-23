import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wash_quote/data/app_database.dart';

enum ServiceUnit { sqft, linft, flat, hour }

extension ServiceUnitCode on ServiceUnit {
  String get code => name;

  static ServiceUnit fromCode(String code) {
    return ServiceUnit.values.firstWhere(
      (u) => u.name == code,
      orElse: () => ServiceUnit.flat,
    );
  }
}

class ServiceRepo {
  ServiceRepo(this._db);

  final AppDatabase _db;

  Future<int> add({
    required String name,
    required ServiceUnit unit,
    required int unitPriceCents,
    int? sortOrder,
  }) async {
    final resolvedOrder = sortOrder ?? await _nextSortOrder();
    return await _db.into(_db.services).insert(
          ServicesCompanion.insert(
            name: name,
            unit: unit.code,
            unitPriceCents: unitPriceCents,
            sortOrder: Value(resolvedOrder),
          ),
        );
  }

  Future<void> update({
    required int id,
    required String name,
    required ServiceUnit unit,
    required int unitPriceCents,
  }) async {
    await (_db.update(_db.services)..where((t) => t.id.equals(id))).write(
      ServicesCompanion(
        name: Value(name),
        unit: Value(unit.code),
        unitPriceCents: Value(unitPriceCents),
      ),
    );
  }

  Future<void> delete(int id) async {
    await (_db.delete(_db.services)..where((t) => t.id.equals(id))).go();
  }

  Future<Service?> byId(int id) =>
      (_db.select(_db.services)..where((t) => t.id.equals(id)))
          .getSingleOrNull();

  Stream<List<Service>> watchAll() {
    return (_db.select(_db.services)
          ..orderBy([(t) => OrderingTerm.asc(t.sortOrder)]))
        .watch();
  }

  Future<List<Service>> getAll() {
    return (_db.select(_db.services)
          ..orderBy([(t) => OrderingTerm.asc(t.sortOrder)]))
        .get();
  }

  Future<int> _nextSortOrder() async {
    final rows = await (_db.select(_db.services)
          ..orderBy([(t) => OrderingTerm.desc(t.sortOrder)])
          ..limit(1))
        .get();
    if (rows.isEmpty) return 0;
    return rows.first.sortOrder + 1;
  }

  Future<void> reorder(List<int> orderedIds) async {
    await _db.transaction(() async {
      for (var i = 0; i < orderedIds.length; i++) {
        await (_db.update(_db.services)
              ..where((t) => t.id.equals(orderedIds[i])))
            .write(ServicesCompanion(sortOrder: Value(i)));
      }
    });
  }
}

final serviceRepoProvider = Provider<ServiceRepo>((ref) {
  return ServiceRepo(ref.watch(appDatabaseProvider));
});

final servicesProvider = StreamProvider<List<Service>>((ref) {
  return ref.watch(serviceRepoProvider).watchAll();
});
