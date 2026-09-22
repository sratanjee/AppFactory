import 'package:factory_core/factory_core.dart';

/// Static per-app config for Olympia Weekend.
///
/// This app deviates from the factory defaults (spec §0, §4, §6):
///   * No paywall — [PaywallConfig.disabled], no RevenueCat keys.
///   * Mixpanel instead of PostHog — factory analytics is disabled;
///     the app's own MixpanelService (see `lib/features/mixpanel.dart`,
///     added by the builder) is initialised from `mixpanelToken` at
///     boot.
///   * Web-first — Google Maps uses a browser key alongside the mobile
///     keys.
///   * Anonymous Supabase table for crowd confirmations.
///
/// Values land here via `--dart-define` at build time (see `tool/run.sh`);
/// local runs without those defines see empty strings and each subsystem
/// disables itself.
abstract final class AppConfig {
  static const String mixpanelToken =
      String.fromEnvironment('MIXPANEL_TOKEN');

  static const String supabaseUrl =
      String.fromEnvironment('SUPABASE_URL');
  static const String supabaseAnonKey =
      String.fromEnvironment('SUPABASE_ANON_KEY');

  static const String googleMapsWebKey =
      String.fromEnvironment('GOOGLE_MAPS_WEB_KEY');
  static const String googleMapsIosKey =
      String.fromEnvironment('GOOGLE_MAPS_IOS_KEY');
  static const String googleMapsAndroidKey =
      String.fromEnvironment('GOOGLE_MAPS_ANDROID_KEY');

  static const String webDeployDomain =
      String.fromEnvironment('WEB_DEPLOY_DOMAIN');

  /// Factory analytics disabled — this app uses Mixpanel directly.
  static AnalyticsConfig get analyticsConfig =>
      const AnalyticsConfig.disabled();

  /// No paywall — spec §6 overrides CLAUDE.md non-negotiable #3.
  static PaywallConfig get paywallConfig => const PaywallConfig.disabled();
}
