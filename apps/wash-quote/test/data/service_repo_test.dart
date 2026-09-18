import 'package:flutter_test/flutter_test.dart';
import 'package:wash_quote/data/app_database.dart';
import 'package:wash_quote/data/service_repo.dart';

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

  test('add / update / delete a service', () async {
    final id = await repo.add(
      name: 'House soft wash',
      unit: ServiceUnit.sqft,
      unitPriceCents: 45,
    );
    final row = await repo.byId(id);
    expect(row?.name, 'House soft wash');
    expect(row?.unit, ServiceUnit.sqft.code);
    expect(row?.unitPriceCents, 45);

    await repo.update(
      id: id,
      name: 'House soft wash',
      unit: ServiceUnit.sqft,
      unitPriceCents: 55,
    );
    final updated = await repo.byId(id);
    expect(updated?.unitPriceCents, 55);

    await repo.delete(id);
    expect(await repo.byId(id), isNull);
  });

  test('reorder persists new sortOrder', () async {
    final a = await repo.add(
      name: 'A',
      unit: ServiceUnit.flat,
      unitPriceCents: 100,
    );
    final b = await repo.add(
      name: 'B',
      unit: ServiceUnit.flat,
      unitPriceCents: 100,
    );
    final c = await repo.add(
      name: 'C',
      unit: ServiceUnit.flat,
      unitPriceCents: 100,
    );

    await repo.reorder([c, a, b]);
    final list = await repo.getAll();
    expect(list.map((s) => s.name).toList(), ['C', 'A', 'B']);
  });
}
