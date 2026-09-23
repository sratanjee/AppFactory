import 'package:factory_core/factory_core.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Paywall.disabled()', () {
    late Paywall paywall;

    setUp(() {
      paywall = Paywall.disabled();
    });

    test('isDisabled is true', () {
      expect(paywall.isDisabled, isTrue);
    });

    test(
      'hasEntitlement returns true in debug mode so gated actions are '
      'reachable without RC config wired',
      () async {
        // flutter_test runs kDebugMode = true; the "isDisabled &&
        // (kDebugMode || kIsWeb) -> true" branch is what dev/preview
        // builds hit.
        expect(await paywall.hasEntitlement(), isTrue);
      },
    );

    test('fetchOffering returns null', () async {
      expect(await paywall.fetchOffering(), isNull);
    });

    test('restore returns notPresented', () async {
      expect(await paywall.restore(), PaywallResult.notPresented);
    });

    test('presentIfNotEntitled returns notPresented (no context needed)',
        () async {
      // Disabled mode short-circuits before hitting BuildContext.
      final result = await paywall.presentIfNotEntitled(
        _NullContext(),
        placement: 'test',
      );
      expect(result, PaywallResult.notPresented);
    });

    test('initialize is a no-op', () async {
      await paywall.initialize();
      await paywall.initialize();  // idempotent
    });
  });

  group('Paywall.testing()', () {
    const testOffering = PaywallOffering(
      defaultPackageId: 'annual',
      packages: [
        PaywallPackage(
          identifier: 'annual',
          title: 'Annual',
          priceString: r'$49.99',
          period: 'year',
          savingString: 'Save 60%',
          freeTrialDays: 7,
        ),
        PaywallPackage(
          identifier: 'weekly',
          title: 'Weekly',
          priceString: r'$4.99',
          period: 'week',
        ),
      ],
    );

    test('fetchOffering returns the injected offering', () async {
      final paywall = Paywall.testing(offering: testOffering);
      final offering = await paywall.fetchOffering();
      expect(offering, isNotNull);
      expect(offering!.packages, hasLength(2));
      expect(offering.defaultPackageId, 'annual');
    });

    test('present returns the injected nextPresentResult', () async {
      final paywall = Paywall.testing(
        offering: testOffering,
        nextPresentResult: PaywallResult.purchased,
      );
      final result = await paywall.present(
        _NullContext(),
        placement: 'test',
      );
      expect(result, PaywallResult.purchased);
    });

    test('present returns dismissed by default', () async {
      final paywall = Paywall.testing(offering: testOffering);
      final result = await paywall.present(
        _NullContext(),
        placement: 'test',
      );
      expect(result, PaywallResult.dismissed);
    });

    test('hasEntitlement returns false (testing implies no purchase state)',
        () async {
      final paywall = Paywall.testing(offering: testOffering);
      expect(await paywall.hasEntitlement(), isFalse);
    });
  });

  group('PaywallOffering.packageForId', () {
    test('returns matching package or null', () {
      const offering = PaywallOffering(
        defaultPackageId: 'annual',
        packages: [
          PaywallPackage(
            identifier: 'annual',
            title: 'Annual',
            priceString: r'$49.99',
            period: 'year',
          ),
        ],
      );
      expect(offering.packageForId('annual')?.title, 'Annual');
      expect(offering.packageForId('nonexistent'), isNull);
    });
  });

  group('PaywallPackage.hasFreeTrial', () {
    test('true when freeTrialDays > 0', () {
      const pkg = PaywallPackage(
        identifier: 'annual',
        title: 'Annual',
        priceString: r'$49.99',
        period: 'year',
        freeTrialDays: 7,
      );
      expect(pkg.hasFreeTrial, isTrue);
    });

    test('false when freeTrialDays is null or zero', () {
      const noTrial = PaywallPackage(
        identifier: 'weekly',
        title: 'Weekly',
        priceString: r'$4.99',
        period: 'week',
      );
      expect(noTrial.hasFreeTrial, isFalse);
    });
  });
}

class _NullContext implements BuildContext {
  @override
  bool get mounted => true;

  @override
  dynamic noSuchMethod(Invocation invocation) => null;
}
