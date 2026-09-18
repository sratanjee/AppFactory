import 'package:flutter_test/flutter_test.dart';
import 'package:wash_quote/data/app_database.dart';
import 'package:wash_quote/data/service_repo.dart';
import 'package:wash_quote/data/starter_services.dart';

/// Guards the "seed only runs when there are no services yet" contract in
/// OnboardingScreen._finish. If someone re-arms onboarding the seed must
/// not double-write.
void main() {
  late AppDatabase db;
  late ServiceRepo repo;

  setUp(() {
    db = AppDatabase.inMemory();
    repo = ServiceRepo(db);
  });

  tearDown(() async {
    await db.close();
  });

  Future<void> seedIfEmpty() async {
    final existing = await repo.getAll();
    if (existing.isNotEmpty) return;
    var i = 0;
    for (final s in starterServices) {
      await repo.add(
        name: s.name,
        unit: s.unit,
        unitPriceCents: s.defaultCents,
        sortOrder: i++,
      );
    }
  }

  test('seeds the six starter services when empty', () async {
    await seedIfEmpty();
    final all = await repo.getAll();
    expect(all, hasLength(starterServices.length));
    expect(all.map((s) => s.name), containsAll(const [
      'House soft wash',
      'Driveway',
      'Roof',
      'Deck',
      'Fence',
      'Commercial flatwork',
    ]));
  });

  test('does not re-seed on second run', () async {
    await seedIfEmpty();
    await seedIfEmpty();
    final all = await repo.getAll();
    expect(all, hasLength(starterServices.length));
  });
}
