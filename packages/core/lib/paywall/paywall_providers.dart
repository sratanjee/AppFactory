import 'package:factory_core/analytics/analytics_providers.dart';
import 'package:factory_core/paywall/paywall_client.dart';
import 'package:factory_core/paywall/paywall_config.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Apps override this at boot with a real PaywallConfig.
final paywallConfigProvider = Provider<PaywallConfig>((ref) {
  throw StateError(
    'paywallConfigProvider must be overridden with a PaywallConfig in '
    'AdaptiveApp.riverpodOverrides.',
  );
});

/// The app's Paywall facade. Reads config + analytics.
final paywallProvider = Provider<Paywall>((ref) {
  final config = ref.watch(paywallConfigProvider);
  final analytics = ref.watch(analyticsProvider);
  return Paywall(config: config, analytics: analytics);
});

/// Live entitlement state. Emits false immediately if paywall is disabled
/// or testing; otherwise seeds with `hasEntitlement()` and updates on
/// RevenueCat customer-info changes.
final entitlementProvider = StreamProvider<bool>((ref) {
  return ref.watch(paywallProvider).watchEntitlement();
});
