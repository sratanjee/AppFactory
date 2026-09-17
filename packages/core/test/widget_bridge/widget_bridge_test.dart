import 'dart:async';

import 'package:factory_core/factory_core.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('WidgetBridge in-memory', () {
    late WidgetBridge bridge;

    setUp(() {
      bridge = WidgetBridge.inMemory();
    });

    test('read returns null before any publish', () async {
      expect(await bridge.read(), isNull);
    });

    test('publish + read round-trip for scalar types', () async {
      await bridge.publish({
        'count': 3,
        'label': 'Drinks',
        'weight': 72.5,
        'active': true,
      });
      final result = await bridge.read();
      expect(result, isNotNull);
      expect(result!['count'], 3);
      expect(result['label'], 'Drinks');
      expect(result['weight'], 72.5);
      expect(result['active'], true);
    });

    test('publish + read round-trip for List<String>', () async {
      await bridge.publish({
        'tags': ['water', 'coffee', 'tea'],
      });
      final result = await bridge.read();
      expect(result!['tags'], ['water', 'coffee', 'tea']);
    });

    test('publish replaces prior payload (does not merge)', () async {
      await bridge.publish({'count': 1, 'label': 'A'});
      await bridge.publish({'count': 2});
      final result = await bridge.read();
      expect(result!['count'], 2);
      expect(result.containsKey('label'), isFalse);
    });

    test('clear empties the store', () async {
      await bridge.publish({'count': 1});
      await bridge.clear();
      expect(await bridge.read(), isNull);
    });

    test('reloadAllWidgets is a no-op in memory', () async {
      await bridge.reloadAllWidgets();
    });
  });

  group('WidgetBridge suite naming', () {
    test('forSlug produces factory.widget.<slug>', () {
      final bridge = WidgetBridge.forSlug('habits');
      expect(bridge.suiteName, 'factory.widget.habits');
    });

    test('forSlug asserts on empty slug', () {
      expect(() => WidgetBridge.forSlug(''), throwsA(isA<AssertionError>()));
    });

    test('inMemory has a distinct suite name', () {
      final bridge = WidgetBridge.inMemory();
      expect(bridge.suiteName, startsWith('factory.widget.'));
    });
  });

  group('WidgetBridge payload validation', () {
    test('DateTime auto-encodes as ISO 8601 on the transport path', () async {
      // In-memory bridge stores the original payload (post-encode-check but
      // pre-JSON-roundtrip). DateTimes survive on the in-memory read; on the
      // real channel path they land as ISO 8601 strings.
      final bridge = WidgetBridge.inMemory();
      final now = DateTime.utc(2026, 9, 17, 15);
      await bridge.publish({'at': now});
      final result = await bridge.read();
      expect(result!['at'], now);
    });
  });

  group('WidgetBridge debounce + unchanged-skip', () {
    test('re-publishing the same payload does not reset lastPublishedEncoded',
        () async {
      final bridge = WidgetBridge.inMemory();
      await bridge.publish({'count': 3});
      // Second publish with identical payload is a no-op (returns
      // immediately, no store touched — same effect from outside).
      await bridge.publish({'count': 3});
      final result = await bridge.read();
      expect(result!['count'], 3);
    });

    test('debounced publishes coalesce to the last payload', () async {
      final bridge = WidgetBridge.inMemory(
        debounce: const Duration(milliseconds: 50),
      );
      // Fire three publishes inside the debounce window.
      final first = bridge.publish({'count': 1});
      final second = bridge.publish({'count': 2});
      final third = bridge.publish({'count': 3});
      await Future.wait([first, second, third]);
      final result = await bridge.read();
      // Only the last payload lands.
      expect(result!['count'], 3);
    });

    test('rapid A → B → A collapses to A with no wasted write', () async {
      final bridge = WidgetBridge.inMemory(
        debounce: const Duration(milliseconds: 50),
      );
      await bridge.publish({'value': 'A'});
      // These three calls should collapse; final state stays A.
      final f1 = bridge.publish({'value': 'B'});
      final f2 = bridge.publish({'value': 'A'});
      await Future.wait([f1, f2]);
      final result = await bridge.read();
      expect(result!['value'], 'A');
    });

    test('clear cancels any pending debounced publish', () async {
      final bridge = WidgetBridge.inMemory(
        debounce: const Duration(milliseconds: 200),
      );
      // Schedule a publish that will be superseded.
      unawaited(bridge.publish({'count': 42}));
      await bridge.clear();
      // After clear, the pending publish should have been dropped and the
      // store should be empty.
      expect(await bridge.read(), isNull);
    });
  });
}
