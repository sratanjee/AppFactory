import 'dart:async';
import 'dart:collection';

import 'package:factory_core/analytics/analytics_config.dart';
import 'package:flutter/foundation.dart';
import 'package:posthog_flutter/posthog_flutter.dart';

/// One record of a captured event, for [Analytics.recordedEvents] in testing.
///
/// Reserved event-name markers for non-track calls:
///   * `__identify__` — payload includes `distinctId`.
///   * `__reset__`    — payload empty.
///   * `__screen__`   — payload includes `name`.
@immutable
class AnalyticsEvent {
  const AnalyticsEvent({required this.name, required this.properties});

  final String name;
  final Map<String, Object?> properties;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AnalyticsEvent &&
          other.name == name &&
          mapEquals(other.properties, properties);

  @override
  int get hashCode => Object.hash(name, Object.hashAllUnordered(properties.entries));

  @override
  String toString() => 'AnalyticsEvent($name, $properties)';
}

/// The factory's analytics facade. Exposes exactly the five fixed events
/// from CLAUDE.md §Conventions as typed methods; [trackCustom] is the escape
/// hatch for PLAN §7-approved additions.
///
/// Track calls are fire-and-forget: they don't return futures. Internally
/// each one lazily initialises PostHog and swallows errors — analytics
/// should never break the app.
class Analytics {
  Analytics._(this._config);

  factory Analytics.forConfig(AnalyticsConfig config) =>
      Analytics._(config);
  factory Analytics.disabled() =>
      Analytics._(const AnalyticsConfig.disabled());
  factory Analytics.testing() =>
      Analytics._(const AnalyticsConfig.testing());

  final AnalyticsConfig _config;
  final Posthog _client = Posthog();
  final List<AnalyticsEvent> _recorded = [];
  Future<void>? _readyFuture;

  static const _reserved = {
    'onboarding_step',
    'paywall_view',
    'paywall_purchase',
    'core_action',
    'widget_added',
  };

  // ---- Fixed events -----------------------------------------------------

  void trackOnboardingStep({required int step}) =>
      _capture('onboarding_step', {'step': step});

  void trackPaywallView({required String placement}) =>
      _capture('paywall_view', {'placement': placement});

  void trackPaywallPurchase({required String sku, required String price}) =>
      _capture('paywall_purchase', {'sku': sku, 'price': price});

  void trackCoreAction({Map<String, Object?>? properties}) =>
      _capture('core_action', properties);

  void trackWidgetAdded({required String surface, required String size}) =>
      _capture('widget_added', {'surface': surface, 'size': size});

  // ---- Escape hatch -----------------------------------------------------

  /// Fire any event name. In **debug** builds this asserts when [name]
  /// collides with the reserved five; in **release** it reroutes to the
  /// matching typed method (safety net if a reserved name slips through
  /// after asserts are stripped). Non-reserved names always capture.
  void trackCustom({required String name, Map<String, Object?>? properties}) {
    assert(
      !_reserved.contains(name),
      'trackCustom called with reserved event "$name" — use the typed track method instead.',
    );
    if (_reserved.contains(name)) {
      _routeReserved(name, properties);
      return;
    }
    _capture(name, properties);
  }

  void _routeReserved(String name, Map<String, Object?>? props) {
    if (name == 'onboarding_step') {
      final step = props?['step'];
      if (step is int) trackOnboardingStep(step: step);
    } else if (name == 'paywall_view') {
      final placement = props?['placement'];
      if (placement is String) trackPaywallView(placement: placement);
    } else if (name == 'paywall_purchase') {
      final sku = props?['sku'];
      final price = props?['price'];
      if (sku is String && price is String) {
        trackPaywallPurchase(sku: sku, price: price);
      }
    } else if (name == 'core_action') {
      trackCoreAction(properties: props);
    } else if (name == 'widget_added') {
      final surface = props?['surface'];
      final size = props?['size'];
      if (surface is String && size is String) {
        trackWidgetAdded(surface: surface, size: size);
      }
    }
  }

  // ---- User context -----------------------------------------------------

  void identify({
    required String distinctId,
    Map<String, Object?>? properties,
  }) {
    if (_config.isTesting) {
      _recorded.add(AnalyticsEvent(
        name: '__identify__',
        properties: {
          'distinctId': distinctId,
          ...?properties,
        },
      ));
      return;
    }
    if (_config.isDisabled) return;
    unawaited(_run(() => _client.identify(
          userId: distinctId,
          userProperties: _clean(properties),
        )));
  }

  void reset() {
    if (_config.isTesting) {
      _recorded.add(const AnalyticsEvent(
        name: '__reset__',
        properties: {},
      ));
      return;
    }
    if (_config.isDisabled) return;
    unawaited(_run(_client.reset));
  }

  void screen({required String name, Map<String, Object?>? properties}) {
    if (_config.isTesting) {
      _recorded.add(AnalyticsEvent(
        name: '__screen__',
        properties: {
          'name': name,
          ...?properties,
        },
      ));
      return;
    }
    if (_config.isDisabled) return;
    unawaited(_run(() => _client.screen(
          screenName: name,
          properties: _clean(properties),
        )));
  }

  /// The PostHog distinct ID (anonymous or identified). Returns `null` when
  /// analytics is disabled or in testing mode. Used to seed the RevenueCat
  /// `appUserID` at init so the two systems share IDs from install.
  Future<String?> distinctId() async {
    if (_config.isDisabled || _config.isTesting) return null;
    try {
      await _ensureReady();
      return await _client.getDistinctId();
    } on Object catch (e, st) {
      _warn('getDistinctId failed', e, st);
      return null;
    }
  }

  // ---- Test-only --------------------------------------------------------

  @visibleForTesting
  UnmodifiableListView<AnalyticsEvent> get recordedEvents =>
      UnmodifiableListView(_recorded);

  @visibleForTesting
  void clearRecorded() => _recorded.clear();

  // ---- Internals --------------------------------------------------------

  void _capture(String name, Map<String, Object?>? properties) {
    if (_config.isTesting) {
      _recorded.add(AnalyticsEvent(
        name: name,
        properties: properties ?? const {},
      ));
      return;
    }
    if (_config.isDisabled) return;
    unawaited(_run(() => _client.capture(
          eventName: name,
          properties: _clean(properties),
        )));
  }

  Future<void> _ensureReady() {
    return _readyFuture ??= _initialize();
  }

  Future<void> _initialize() async {
    final options = PostHogConfig(_config.apiKey)
      ..host = _config.host
      ..debug = _config.debug
      ..captureApplicationLifecycleEvents =
          _config.captureApplicationLifecycleEvents;
    await _client.setup(options);
  }

  Future<void> _run(Future<void> Function() op) async {
    try {
      await _ensureReady();
      await op();
    } on Object catch (e, st) {
      _warn('analytics call failed', e, st);
    }
  }

  Map<String, Object>? _clean(Map<String, Object?>? props) {
    if (props == null) return null;
    return {
      for (final e in props.entries)
        if (e.value != null) e.key: e.value!,
    };
  }

  void _warn(String label, Object error, StackTrace stack) {
    if (kDebugMode) {
      debugPrint('⚠️  [factory_core/analytics] $label: $error');
    }
  }
}
