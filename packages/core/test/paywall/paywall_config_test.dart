import 'package:factory_core/factory_core.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('PaywallConfig', () {
    test('non-disabled with keys is active', () {
      const config = PaywallConfig(
        iosApiKey: 'appl_xxx',
        androidApiKey: 'goog_xxx',
      );
      expect(config.isDisabled, isFalse);
    });

    test('disabled() has no keys and reports disabled', () {
      const config = PaywallConfig.disabled();
      expect(config.iosApiKey, isEmpty);
      expect(config.androidApiKey, isEmpty);
      expect(config.isDisabled, isTrue);
    });

    test('default entitlementId is "pro"', () {
      const config = PaywallConfig(iosApiKey: 'a', androidApiKey: 'b');
      expect(config.entitlementId, 'pro');
    });

    test('holds benefits + urls', () {
      final config = PaywallConfig(
        iosApiKey: 'a',
        androidApiKey: 'b',
        termsUrl: Uri.parse('https://example.test/terms'),
        privacyUrl: Uri.parse('https://example.test/privacy'),
        benefits: const ['See every drink', 'Streaks that stick', 'Widget on lock'],
      );
      expect(config.benefits, hasLength(3));
      expect(config.termsUrl?.path, '/terms');
      expect(config.privacyUrl?.path, '/privacy');
    });
  });
}
