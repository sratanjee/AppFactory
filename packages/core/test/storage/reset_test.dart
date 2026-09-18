import 'package:drift/drift.dart' hide isNull;
import 'package:drift/native.dart';
import 'package:factory_core/factory_core.dart';
import 'package:flutter_test/flutter_test.dart';

part 'reset_test.g.dart';

class Items extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text()();
}

class Gadgets extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get label => text()();
}

@DriftDatabase(tables: [Items, Gadgets])
class TestDb extends _$TestDb {
  TestDb() : super(NativeDatabase.memory());

  @override
  int get schemaVersion => 1;
}

void main() {
  group('resetAppData', () {
    late KeyValueStore kv;
    late TestDb db;

    setUp(() async {
      kv = KeyValueStore.inMemory();
      db = TestDb();
      await kv.setBool('hasSeenOnboarding', true);
      await kv.setString('lastOpenSlug', 'wash-quote');
      await db.into(db.items).insert(ItemsCompanion.insert(name: 'a'));
      await db.into(db.items).insert(ItemsCompanion.insert(name: 'b'));
      await db.into(db.gadgets).insert(GadgetsCompanion.insert(label: 'x'));
    });

    tearDown(() async {
      await db.close();
      await kv.close();
    });

    test('clears the key-value store and every user table', () async {
      // Pre-conditions: seeded data exists.
      expect(await kv.getBool('hasSeenOnboarding'), isTrue);
      expect(await kv.getString('lastOpenSlug'), 'wash-quote');
      expect(await db.select(db.items).get(), hasLength(2));
      expect(await db.select(db.gadgets).get(), hasLength(1));

      await resetAppData(keyValueStore: kv, database: db);

      expect(await kv.getBool('hasSeenOnboarding'), isNull);
      expect(await kv.getString('lastOpenSlug'), isNull);
      expect(await db.select(db.items).get(), isEmpty);
      expect(await db.select(db.gadgets).get(), isEmpty);
    });
  });
}
