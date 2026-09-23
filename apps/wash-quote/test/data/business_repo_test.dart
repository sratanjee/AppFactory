import 'package:flutter_test/flutter_test.dart';
import 'package:wash_quote/data/app_database.dart';
import 'package:wash_quote/data/business_repo.dart';

void main() {
  late AppDatabase db;
  late BusinessRepo repo;

  setUp(() {
    db = AppDatabase.inMemory();
    repo = BusinessRepo(db);
  });

  tearDown(() async {
    await db.close();
  });

  test('upsertSingleton inserts on first call, updates on second', () async {
    await repo.upsertSingleton(name: 'Blue Wave Wash', payVia: 'Venmo');
    var row = await repo.get();
    expect(row?.name, 'Blue Wave Wash');
    expect(row?.payVia, 'Venmo');

    await repo.upsertSingleton(name: 'Blue Wave Wash', payVia: 'Zelle');
    row = await repo.get();
    expect(row?.payVia, 'Zelle');

    // Still exactly one row.
    final all = await db.select(db.businesses).get();
    expect(all, hasLength(1));
  });

  test('allocateJobNumber starts at 1001 and bumps monotonically', () async {
    await repo.upsertSingleton(name: 'X');
    final first = await repo.allocateJobNumber();
    final second = await repo.allocateJobNumber();
    final third = await repo.allocateJobNumber();
    expect(first, 1001);
    expect(second, 1002);
    expect(third, 1003);
  });
}
