import 'package:factory_core/factory_core.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Presents the paywall if `pro` isn't active. Returns `true` if the caller
/// should continue with the gated action (either already entitled or the
/// purchase just landed).
///
/// When the paywall is disabled at build time (no RC keys), the gate lets
/// the action through — dead-ending the hero card on every dev/preview
/// build is a worse failure mode than opening a gated screen without a
/// real subscription.
Future<bool> ensureProEntitlement(
  BuildContext context,
  WidgetRef ref, {
  required String placement,
}) async {
  final paywall = ref.read(paywallProvider);
  if (paywall.isDisabled) return true;
  final entitled = await paywall.hasEntitlement();
  if (entitled) return true;
  if (!context.mounted) return false;
  final result = await PaywallScreen.show(
    context,
    paywall: paywall,
    placement: placement,
  );
  return result == PaywallResult.purchased || result == PaywallResult.restored;
}
