/// Configuration for the factory's analytics stack (PostHog under the hood).
///
/// Apps provide one via `analyticsConfigProvider` in
/// `AdaptiveApp.riverpodOverrides`. Two special factories exist:
///   * [AnalyticsConfig.disabled] — everything is a no-op. Use before a real
///     PostHog project is wired.
///   * [AnalyticsConfig.testing] — records events in-memory, never hits the
///     network. Use in tests.
class AnalyticsConfig {
  const AnalyticsConfig({
    required this.apiKey,
    this.host = 'https://us.i.posthog.com',
    this.debug = false,
    this.captureApplicationLifecycleEvents = false,
  });

  const AnalyticsConfig.disabled() : this(apiKey: '');
  const AnalyticsConfig.testing() : this(apiKey: _testingSentinel);

  static const _testingSentinel = '__factory_analytics_testing__';

  /// PostHog project token (formerly "API key"). Empty means analytics is off.
  final String apiKey;

  /// PostHog ingestion host. Defaults to US cloud PostHog.
  final String host;

  /// Emit verbose PostHog logs. Off by default.
  final bool debug;

  /// Let PostHog auto-capture App Opened / Backgrounded / Installed events.
  /// Off by default because these events aren't in the factory's fixed five —
  /// enabling them per app should be justified in that app's PLAN §7.
  final bool captureApplicationLifecycleEvents;

  bool get isDisabled => apiKey.isEmpty;
  bool get isTesting => apiKey == _testingSentinel;
}
