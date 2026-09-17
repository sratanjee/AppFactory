import 'package:factory_core/factory_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';

const _offering = PaywallOffering(
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

PaywallConfig _config({Uri? terms, Uri? privacy}) => PaywallConfig(
      iosApiKey: 'appl_test',
      androidApiKey: 'goog_test',
      benefits: const [
        'See every drink',
        'Streaks that stick',
        'Widget on the lock screen',
      ],
      termsUrl: terms,
      privacyUrl: privacy,
    );

Widget _wrap(Widget child) {
  return MaterialApp(
    debugShowCheckedModeBanner: false,
    localizationsDelegates: const [
      FactoryLocalizations.delegate,
      GlobalMaterialLocalizations.delegate,
      GlobalCupertinoLocalizations.delegate,
      GlobalWidgetsLocalizations.delegate,
    ],
    home: AdaptiveTheme(accent: const Color(0xFF6750A4), child: child),
  );
}

PaywallScreen _screen({
  required Paywall paywall,
  PaywallOffering offering = _offering,
  String placement = 'after_onboarding',
}) =>
    PaywallScreen(
      paywall: paywall,
      offering: offering,
      placement: placement,
    );

void main() {
  group('PaywallScreen', () {
    testWidgets('renders benefits, both packages, and the primary button',
        (tester) async {
      final paywall = Paywall.testing(config: _config());
      await tester.pumpWidget(_wrap(_screen(paywall: paywall)));
      await tester.pump();

      expect(find.text('See every drink'), findsOneWidget);
      expect(find.text('Streaks that stick'), findsOneWidget);
      expect(find.text('Widget on the lock screen'), findsOneWidget);
      expect(find.text('Annual'), findsOneWidget);
      expect(find.text('Weekly'), findsOneWidget);
      expect(find.text(r'$49.99 / year'), findsOneWidget);
      expect(find.text(r'$4.99 / week'), findsOneWidget);
      expect(find.text('Save 60%'), findsOneWidget);
    });

    testWidgets('primary label defaults to Start free trial when annual is '
        'selected (has trial)', (tester) async {
      final paywall = Paywall.testing(config: _config());
      await tester.pumpWidget(_wrap(_screen(paywall: paywall)));
      await tester.pump();

      expect(find.text('Start free trial'), findsOneWidget);
      expect(find.text('Continue'), findsNothing);
    });

    testWidgets('selecting weekly (no trial) switches label to Continue',
        (tester) async {
      final paywall = Paywall.testing(config: _config());
      await tester.pumpWidget(_wrap(_screen(paywall: paywall)));
      await tester.pump();

      await tester.tap(find.text('Weekly'));
      await tester.pump();

      expect(find.text('Continue'), findsOneWidget);
      expect(find.text('Start free trial'), findsNothing);
    });

    testWidgets('close button is not present at t=0', (tester) async {
      final paywall = Paywall.testing(config: _config());
      await tester.pumpWidget(_wrap(_screen(paywall: paywall)));
      await tester.pump();

      expect(find.byKey(const ValueKey('paywall_close')), findsNothing);
    });

    testWidgets('close button appears after 2s', (tester) async {
      final paywall = Paywall.testing(config: _config());
      await tester.pumpWidget(_wrap(_screen(paywall: paywall)));
      await tester.pump();
      await tester.pump(const Duration(seconds: 2, milliseconds: 100));

      expect(find.byKey(const ValueKey('paywall_close')), findsOneWidget);
    });

    testWidgets('fires analytics.trackPaywallView on init with placement',
        (tester) async {
      final analytics = Analytics.testing();
      final paywall = Paywall.testing(config: _config(), analytics: analytics);
      await tester.pumpWidget(
        _wrap(_screen(paywall: paywall, placement: 'somewhere_else')),
      );
      await tester.pump();

      final views = analytics.recordedEvents
          .where((e) => e.name == 'paywall_view')
          .toList();
      expect(views, hasLength(1));
      expect(views[0].properties['placement'], 'somewhere_else');
    });

    testWidgets('renders Restore button always, Terms + Privacy only when '
        'URLs are provided', (tester) async {
      final paywall = Paywall.testing(config: _config());
      await tester.pumpWidget(_wrap(_screen(paywall: paywall)));
      await tester.pump();

      expect(find.text('Restore purchases'), findsOneWidget);
      expect(find.text('Terms'), findsNothing);
      expect(find.text('Privacy'), findsNothing);
    });

    testWidgets('renders Terms + Privacy when URLs are on the config',
        (tester) async {
      final paywall = Paywall.testing(
        config: _config(
          terms: Uri.parse('https://factory.example/terms'),
          privacy: Uri.parse('https://factory.example/privacy'),
        ),
      );
      await tester.pumpWidget(_wrap(_screen(paywall: paywall)));
      await tester.pump();

      expect(find.text('Terms'), findsOneWidget);
      expect(find.text('Privacy'), findsOneWidget);
    });
  });
}
