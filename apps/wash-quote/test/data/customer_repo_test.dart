import 'package:flutter_test/flutter_test.dart';
import 'package:wash_quote/data/app_database.dart';
import 'package:wash_quote/data/customer_repo.dart';

void main() {
  late AppDatabase db;
  late CustomerRepo repo;

  setUp(() {
    db = AppDatabase.inMemory();
    repo = CustomerRepo(db);
  });

  tearDown(() async {
    await db.close();
  });

  test('add / update / delete round-trips through Drift', () async {
    final id = await repo.add(name: 'Ada Okafor', phone: '555 0100');
    final row = await repo.byId(id);
    expect(row?.name, 'Ada Okafor');
    expect(row?.phone, '555 0100');

    await repo.update(id: id, name: 'Ada O.', phone: '555 0100');
    final updated = await repo.byId(id);
    expect(updated?.name, 'Ada O.');

    await repo.delete(id);
    expect(await repo.byId(id), isNull);
  });

  test('watchAll emits customers sorted by name', () async {
    await repo.add(name: 'Zara');
    await repo.add(name: 'Ada');
    final list = await repo.watchAll().first;
    expect(list.map((c) => c.name).toList(), ['Ada', 'Zara']);
  });
}
