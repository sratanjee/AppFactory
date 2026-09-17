import 'package:factory_core/factory_core.dart';

/// Static per-app config. Keys land here at build time via --dart-define;
/// local runs without those defines see empty strings and the subsystems
/// fall back to disabled/testing mode.
abstract final class AppConfig {
  static const String posthogKey = String.fromEnvironment('POSTHOG_KEY');
  static const String revenueCatIosKey =
      String.fromEnvironment('REVENUECAT_IOS_KEY');
  static const String revenueCatAndroidKey =
      String.fromEnvironment('REVENUECAT_ANDROID_KEY');

  static AnalyticsConfig get analyticsConfig => posthogKey.isEmpty
      ? const AnalyticsConfig.disabled()
      : const AnalyticsConfig(apiKey: posthogKey);

  static PaywallConfig get paywallConfig => const PaywallConfig(
        iosApiKey: revenueCatIosKey,
        androidApiKey: revenueCatAndroidKey,
        benefits: [
          'Give yourself a whole week to think about the big ones.',
          'See every month you came out ahead, all the way back.',
          'Take your numbers with you, wherever you keep them.',
        ],
      );
}
