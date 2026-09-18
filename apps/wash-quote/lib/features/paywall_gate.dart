import 'package:factory_core/factory_core.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Presents the paywall if `pro` isn't active. Returns `true` if the caller
/// should continue with the gated action (either already entitled or the
/// purchase just landed).
Future<bool> ensureProEntitlement(
  BuildContext context,
  WidgetRef ref, {
  required String placement,
}) async {
  final paywall = ref.read(paywallProvider);
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
