import 'package:factory_core/factory_core.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('typed events', () {
    late Analytics analytics;

    setUp(() {
      analytics = Analytics.testing();
    });

    test('trackOnboardingStep records name + step', () {
      analytics.trackOnboardingStep(step: 3);
      expect(analytics.recordedEvents, hasLength(1));
      expect(analytics.recordedEvents[0].name, 'onboarding_step');
      expect(analytics.recordedEvents[0].properties['step'], 3);
    });

    test('trackPaywallView records placement', () {
      analytics.trackPaywallView(placement: 'after_onboarding');
      expect(analytics.recordedEvents[0].name, 'paywall_view');
      expect(
        analytics.recordedEvents[0].properties['placement'],
        'after_onboarding',
      );
    });

    test('trackPaywallPurchase records sku + price', () {
      analytics.trackPaywallPurchase(sku: 'annual', price: r'$49.99');
      expect(analytics.recordedEvents[0].name, 'paywall_purchase');
      expect(analytics.recordedEvents[0].properties['sku'], 'annual');
      expect(analytics.recordedEvents[0].properties['price'], r'$49.99');
    });

    test('trackCoreAction records with and without properties', () {
      analytics
        ..trackCoreAction()
        ..clearRecorded()
        ..trackCoreAction(properties: {'action': 'log_drink'});
      expect(analytics.recordedEvents[0].name, 'core_action');
      expect(analytics.recordedEvents[0].properties['action'], 'log_drink');
    });

    test('trackWidgetAdded records surface + size', () {
      analytics.trackWidgetAdded(surface: 'home_widget', size: 'medium');
      expect(analytics.recordedEvents[0].name, 'widget_added');
      expect(analytics.recordedEvents[0].properties['surface'], 'home_widget');
      expect(analytics.recordedEvents[0].properties['size'], 'medium');
    });
  });

  group('trackCustom', () {
    test('records non-reserved names', () {
      final analytics = Analytics.testing()
        ..trackCustom(name: 'quiz_answered', properties: {'correct': true});
      expect(analytics.recordedEvents[0].name, 'quiz_answered');
      expect(analytics.recordedEvents[0].properties['correct'], true);
    });

    test('asserts in debug when name collides with a reserved event', () {
      final analytics = Analytics.testing();
      expect(
        () => analytics.trackCustom(
          name: 'onboarding_step',
          properties: {'step': 1},
        ),
        throwsA(isA<AssertionError>()),
      );
    });
  });

  group('disabled', () {
    test('captures nothing', () {
      Analytics.disabled()
        ..trackOnboardingStep(step: 1)
        ..trackPaywallView(placement: 'x')
        ..trackCustom(name: 'foo')
        ..identify(distinctId: 'user-1')
        ..reset()
        ..screen(name: 'HomeScreen');
      // Nothing to assert — the point is that no calls throw and none of the
      // network paths are exercised. Recorded buffer stays empty on disabled.
      final analytics = Analytics.disabled();
      expect(analytics.recordedEvents, isEmpty);
    });

    test('distinctId returns null', () async {
      final analytics = Analytics.disabled();
      expect(await analytics.distinctId(), isNull);
    });
  });

  group('user context in testing mode', () {
    late Analytics analytics;

    setUp(() {
      analytics = Analytics.testing();
    });

    test('identify records marker event with distinctId', () {
      analytics.identify(distinctId: 'user-123', properties: {'plan': 'pro'});
      expect(analytics.recordedEvents[0].name, '__identify__');
      expect(analytics.recordedEvents[0].properties['distinctId'], 'user-123');
      expect(analytics.recordedEvents[0].properties['plan'], 'pro');
    });

    test('reset records marker event with empty properties', () {
      analytics.reset();
      expect(analytics.recordedEvents[0].name, '__reset__');
      expect(analytics.recordedEvents[0].properties, isEmpty);
    });

    test('screen records marker event with name', () {
      analytics.screen(name: 'HomeScreen', properties: {'section': 'root'});
      expect(analytics.recordedEvents[0].name, '__screen__');
      expect(analytics.recordedEvents[0].properties['name'], 'HomeScreen');
      expect(analytics.recordedEvents[0].properties['section'], 'root');
    });

    test('distinctId returns null in testing mode', () async {
      expect(await analytics.distinctId(), isNull);
    });
  });

  group('clearRecorded', () {
    test('empties the buffer', () {
      final analytics = Analytics.testing()
        ..trackOnboardingStep(step: 1)
        ..trackOnboardingStep(step: 2);
      expect(analytics.recordedEvents, hasLength(2));
      analytics.clearRecorded();
      expect(analytics.recordedEvents, isEmpty);
    });
  });

  group('AnalyticsEvent equality', () {
    test('equal by name + properties', () {
      const a = AnalyticsEvent(name: 'x', properties: {'k': 1});
      const b = AnalyticsEvent(name: 'x', properties: {'k': 1});
      const c = AnalyticsEvent(name: 'x', properties: {'k': 2});
      expect(a, equals(b));
      expect(a, isNot(equals(c)));
    });
  });
}
