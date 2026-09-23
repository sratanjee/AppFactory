import 'package:factory_core/factory_core.dart';
import 'package:flutter_test/flutter_test.dart';

/// Confirms every event name the app is allowed to emit maps to a typed
/// method on Analytics.testing(); the reserved set matches CLAUDE.md, and
/// the two app-specific extras (`pdf_sent` and `deposit_link_created`) go
/// through `trackCustom`.
void main() {
  test('reserved five + two custom events land in recorded log', () {
    final a = Analytics.testing()
      ..trackOnboardingStep(step: 0)
      ..trackPaywallView(placement: 'after_onboarding')
      ..trackPaywallPurchase(sku: 'annual', price: r'$59.99')
      ..trackCoreAction(properties: const {'action': 'save_quote'})
      ..trackWidgetAdded(surface: 'ios_shortcut', size: 'small')
      ..trackCustom(name: 'pdf_sent', properties: const {'job_number': 1001})
      ..trackCustom(
          name: 'deposit_link_created', properties: const {'ok': true});

    expect(a.recordedEvents.map((e) => e.name).toList(), [
      'onboarding_step',
      'paywall_view',
      'paywall_purchase',
      'core_action',
      'widget_added',
      'pdf_sent',
      'deposit_link_created',
    ]);
  });
}
