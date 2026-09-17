import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:impulse/data/app_database.dart';

enum ItemDecision { bought, skipped }

class ItemsRepo {
  ItemsRepo(this._db);

  final AppDatabase _db;

  Future<int> add({
    required String name,
    required int priceMinor,
    required String currency,
    required int waitHours,
  }) {
    final now = DateTime.now().millisecondsSinceEpoch;
    return _db.into(_db.items).insert(
          ItemsCompanion.insert(
            name: name,
            priceMinor: priceMinor,
            currency: currency,
            createdAt: now,
            decideAt: now + waitHours * 3600 * 1000,
          ),
        );
  }

  Stream<List<Item>> watchWaiting() {
    final nowMs = DateTime.now().millisecondsSinceEpoch;
    return (_db.select(_db.items)
          ..where((t) => t.decision.isNull() & t.decideAt.isBiggerThanValue(nowMs))
          ..orderBy([(t) => OrderingTerm.asc(t.decideAt)]))
        .watch();
  }

  Stream<List<Item>> watchReady() {
    final nowMs = DateTime.now().millisecondsSinceEpoch;
    return (_db.select(_db.items)
          ..where((t) => t.decision.isNull() & t.decideAt.isSmallerOrEqualValue(nowMs))
          ..orderBy([(t) => OrderingTerm.asc(t.decideAt)]))
        .watch();
  }

  Stream<int> watchSavedTotalMinor() {
    return _db
        .customSelect(
          '\nSELECT COALESCE(SUM(price_minor), 0) AS total '
          "FROM items WHERE decision = 'skipped'",
          readsFrom: {_db.items},
        )
        .watchSingle()
        .map((row) => row.read<int>('total'));
  }

  Future<void> decide(int id, ItemDecision decision) async {
    await (_db.update(_db.items)..where((t) => t.id.equals(id))).write(
      ItemsCompanion(
        decision: Value(decision.name),
        decidedAt: Value(DateTime.now().millisecondsSinceEpoch),
      ),
    );
  }
}

final itemsRepoProvider = Provider<ItemsRepo>((ref) {
  return ItemsRepo(ref.watch(appDatabaseProvider));
});

final waitingItemsProvider = StreamProvider<List<Item>>((ref) {
  return ref.watch(itemsRepoProvider).watchWaiting();
});

final readyItemsProvider = StreamProvider<List<Item>>((ref) {
  return ref.watch(itemsRepoProvider).watchReady();
});

final savedTotalMinorProvider = StreamProvider<int>((ref) {
  return ref.watch(itemsRepoProvider).watchSavedTotalMinor();
});
