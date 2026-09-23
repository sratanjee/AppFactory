import 'package:factory_core/factory_core.dart';

/// Static per-app config. Keys land here at build time via --dart-define;
/// local runs without those defines see empty strings and the subsystems
/// fall back to disabled/testing mode.
abstract final class AppConfig {
  static const String posthogKey =
      String.fromEnvironment('POSTHOG_KEY');
  static const String revenueCatIosKey =
      String.fromEnvironment('REVENUECAT_IOS_KEY');
  static const String revenueCatAndroidKey =
      String.fromEnvironment('REVENUECAT_ANDROID_KEY');

  static AnalyticsConfig get analyticsConfig => posthogKey.isEmpty
      ? const AnalyticsConfig.disabled()
      : const AnalyticsConfig(apiKey: posthogKey);

  static PaywallConfig get paywallConfig => PaywallConfig(
        iosApiKey: revenueCatIosKey,
        androidApiKey: revenueCatAndroidKey,
        benefits: const [
    'Quote from the driveway and send the PDF before you leave.',
    "Unlimited quotes and invoices, your logo, nobody else's.",
    'One price that does not go up, and it works with no signal.',
  ],
        termsUrl: Uri.parse('https://sratanjee.github.io/appfactory-site/terms.html'),
        privacyUrl: Uri.parse('https://sratanjee.github.io/appfactory-site/wash-quote/privacy.html'),
      );
}
