import 'package:factory_core/factory_core.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late KeyValueStore kv;

  setUp(() {
    kv = KeyValueStore.inMemory();
  });

  tearDown(() async {
    await kv.close();
  });

  group('round-trip', () {
    test('string', () async {
      expect(await kv.getString('name'), isNull);
      await kv.setString('name', 'Sarang');
      expect(await kv.getString('name'), 'Sarang');
    });

    test('int', () async {
      await kv.setInt('count', 42);
      expect(await kv.getInt('count'), 42);
    });

    test('double', () async {
      await kv.setDouble('pi', 3.14);
      expect(await kv.getDouble('pi'), 3.14);
    });

    test('bool', () async {
      await kv.setBool('seen', true);
      expect(await kv.getBool('seen'), isTrue);
      await kv.setBool('seen', false);
      expect(await kv.getBool('seen'), isFalse);
    });

    test('DateTime', () async {
      final now = DateTime.fromMillisecondsSinceEpoch(1_700_000_000_000);
      await kv.setDateTime('at', now);
      expect(await kv.getDateTime('at'), now);
    });

    test('JSON', () async {
      final payload = <String, dynamic>{
        'name': 'Sarang',
        'counts': [1, 2, 3],
        'meta': {'active': true},
      };
      await kv.setJson('payload', payload);
      expect(await kv.getJson('payload'), payload);
    });
  });

  group('kind mismatch', () {
    test('returns null when reading a different type than written', () async {
      await kv.setString('x', 'not a number');
      expect(await kv.getInt('x'), isNull);
      expect(await kv.getDouble('x'), isNull);
      expect(await kv.getBool('x'), isNull);
      expect(await kv.getDateTime('x'), isNull);
      expect(await kv.getJson('x'), isNull);
    });
  });

  group('mutations', () {
    test('overwrite updates the value', () async {
      await kv.setString('greeting', 'hi');
      await kv.setString('greeting', 'hello');
      expect(await kv.getString('greeting'), 'hello');
    });

    test('remove deletes a single key', () async {
      await kv.setString('x', 'X');
      await kv.setString('y', 'Y');
      await kv.remove('x');
      expect(await kv.getString('x'), isNull);
      expect(await kv.getString('y'), 'Y');
    });

    test('clear empties the whole store', () async {
      await kv.setString('a', 'A');
      await kv.setInt('b', 2);
      await kv.clear();
      expect(await kv.keys(), isEmpty);
    });
  });

  group('introspection', () {
    test('keys() lists every stored key', () async {
      await kv.setString('a', 'A');
      await kv.setInt('b', 2);
      await kv.setBool('c', true);
      final keys = await kv.keys();
      expect(keys, unorderedEquals(['a', 'b', 'c']));
    });
  });

  group('watch', () {
    test('emits current value then updates', () async {
      final emitted = <int?>[];
      final sub = kv.watchInt('count').listen(emitted.add);
      await pumpEventQueue();
      await kv.setInt('count', 1);
      await pumpEventQueue();
      await kv.setInt('count', 2);
      await pumpEventQueue();
      await sub.cancel();
      expect(emitted, [null, 1, 2]);
    });

    test('emits null when key removed', () async {
      await kv.setInt('count', 5);
      final emitted = <int?>[];
      final sub = kv.watchInt('count').listen(emitted.add);
      await pumpEventQueue();
      await kv.remove('count');
      await pumpEventQueue();
      await sub.cancel();
      expect(emitted, [5, null]);
    });

    test('emits null on kind mismatch', () async {
      await kv.setString('x', 'A');
      final emitted = <int?>[];
      final sub = kv.watchInt('x').listen(emitted.add);
      await pumpEventQueue();
      await sub.cancel();
      expect(emitted, [null]);
    });
  });
}
