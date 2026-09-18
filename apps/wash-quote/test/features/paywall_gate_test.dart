import 'package:factory_core/factory_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wash_quote/features/paywall_gate.dart';

/// Regression: the paywall gate must not dead-end when the app is built
/// without RevenueCat keys (the factory-scaffold default). Before this
/// fix `_openBuilder` -> `ensureProEntitlement` -> `PaywallScreen.show`
/// -> `fetchOffering()==null` -> `PaywallResult.error` -> gate returns
/// false -> hero card silently no-ops.
void main() {
  testWidgets(
    'ensureProEntitlement returns true when the paywall is disabled',
    (tester) async {
      late WidgetRef capturedRef;
      late BuildContext capturedContext;

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            analyticsConfigProvider
                .overrideWithValue(const AnalyticsConfig.testing()),
            paywallConfigProvider
                .overrideWithValue(const PaywallConfig.disabled()),
          ],
          child: MaterialApp(
            home: Consumer(
              builder: (ctx, ref, _) {
                capturedRef = ref;
                capturedContext = ctx;
                return const SizedBox.shrink();
              },
            ),
          ),
        ),
      );

      final ok = await ensureProEntitlement(
        capturedContext,
        capturedRef,
        placement: 'test',
      );
      expect(ok, isTrue);
    },
  );
}
