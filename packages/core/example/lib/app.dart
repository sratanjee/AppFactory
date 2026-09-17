import 'package:factory_core/factory_core.dart';
import 'package:factory_core_example/router.dart';
import 'package:flutter/widgets.dart';

class ExampleApp extends StatelessWidget {
  const ExampleApp({super.key});

  static final _analytics = Analytics.testing();
  static final _paywall = Paywall.testing(
    config: _demoPaywallConfig,
    analytics: _analytics,
    offering: _demoOffering,
  );

  @override
  Widget build(BuildContext context) {
    return AdaptiveApp(
      title: 'factory_core example',
      theme: const AdaptiveTheme(
        accent: Color(0xFF6750A4),
        child: SizedBox.shrink(),
      ),
      router: buildRouter(),
      riverpodOverrides: [
        appSlugProvider.overrideWithValue('example'),
        analyticsConfigProvider.overrideWithValue(
          const AnalyticsConfig.testing(),
        ),
        analyticsProvider.overrideWithValue(_analytics),
        paywallConfigProvider.overrideWithValue(_demoPaywallConfig),
        paywallProvider.overrideWithValue(_paywall),
        shorebirdClientProvider.overrideWithValue(ShorebirdClient.disabled()),
      ],
    );
  }
}

final _demoPaywallConfig = PaywallConfig(
  iosApiKey: '',
  androidApiKey: '',
  benefits: const [
    'See every subsystem tick over',
    'Fake purchases, real UI',
    'Reload widgets without leaving the demo',
  ],
  termsUrl: Uri.parse('https://example.test/terms'),
  privacyUrl: Uri.parse('https://example.test/privacy'),
);

const _demoOffering = PaywallOffering(
  defaultPackageId: 'annual',
  packages: [
    PaywallPackage(
      identifier: 'annual',
      title: 'Annual',
      priceString: r'$49.99',
      period: 'year',
      savingString: 'Save 60%',
      freeTrialDays: 7,
    ),
    PaywallPackage(
      identifier: 'weekly',
      title: 'Weekly',
      priceString: r'$4.99',
      period: 'week',
    ),
  ],
);
