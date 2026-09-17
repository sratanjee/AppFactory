import 'package:factory_core/factory_core.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('ShorebirdClient.disabled()', () {
    late ShorebirdClient client;

    setUp(() {
      client = ShorebirdClient.disabled();
    });

    test('isAvailable is false', () {
      expect(client.isAvailable, isFalse);
    });

    test('currentPatchNumber returns null', () async {
      expect(await client.currentPatchNumber(), isNull);
    });

    test('checkAndUpdate is a no-op that does not throw', () async {
      await client.checkAndUpdate();
    });
  });

  group('bootstrapShorebird', () {
    test('accepts a disabled client and returns synchronously', () {
      final client = ShorebirdClient.disabled();
      bootstrapShorebird(client: client);
    });
  });
}
