import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wash_quote/data/app_database.dart';

/// Singleton row + `nextJobNumber` sequence live here. Every quote pulls
/// `nextJobNumber` and immediately bumps it; the increment is inside a
/// transaction so two rapid `Save quote` taps can't collide.
class BusinessRepo {
  BusinessRepo(this._db);

  final AppDatabase _db;

  Future<Business?> get() =>
      (_db.select(_db.businesses)..limit(1)).getSingleOrNull();

  Stream<Business?> watch() =>
      (_db.select(_db.businesses)..limit(1)).watchSingleOrNull();

  Future<int> upsertSingleton({
    required String name,
    String? logoPath,
    String? phone,
    String? email,
    String? address,
    String payVia = '',
    int defaultDepositPct = 25,
    String? termsText,
  }) async {
    final existing = await get();
    if (existing == null) {
      return await _db.into(_db.businesses).insert(
            BusinessesCompanion.insert(
              name: name,
              logoPath: Value(logoPath),
              phone: Value(phone),
              email: Value(email),
              address: Value(address),
              payVia: Value(payVia),
              defaultDepositPct: Value(defaultDepositPct),
              termsText: Value(termsText),
            ),
          );
    }
    await (_db.update(_db.businesses)..where((t) => t.id.equals(existing.id)))
        .write(
      BusinessesCompanion(
        name: Value(name),
        logoPath: Value(logoPath),
        phone: Value(phone),
        email: Value(email),
        address: Value(address),
        payVia: Value(payVia),
        defaultDepositPct: Value(defaultDepositPct),
        termsText: Value(termsText),
      ),
    );
    return existing.id;
  }

  /// Returns the next job number and bumps the counter atomically.
  Future<int> allocateJobNumber() async {
    return await _db.transaction<int>(() async {
      final row = await get();
      if (row == null) {
        // No business row means onboarding wasn't finished, but we still
        // need a monotonic number so writes don't collide during tests.
        await _db.into(_db.businesses).insert(
              BusinessesCompanion.insert(
                name: 'Business',
              ),
            );
        return await allocateJobNumber();
      }
      final number = row.nextJobNumber;
      await (_db.update(_db.businesses)..where((t) => t.id.equals(row.id)))
          .write(
        BusinessesCompanion(nextJobNumber: Value(number + 1)),
      );
      return number;
    });
  }
}

final businessRepoProvider = Provider<BusinessRepo>((ref) {
  return BusinessRepo(ref.watch(appDatabaseProvider));
});

final businessProvider = StreamProvider<Business?>((ref) {
  return ref.watch(businessRepoProvider).watch();
});
