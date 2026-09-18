import 'package:factory_core/factory_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:wash_quote/data/app_database.dart';
import 'package:wash_quote/l10n/app_strings.dart';
import 'package:wash_quote/screens/onboarding_screen.dart';

// Force Material path in tests: CupertinoActivityIndicator drives a Ticker
// that pumpAndSettle never drains on the desktop tester.

Widget _testApp() {
  final router = GoRouter(
    initialLocation: '/onboarding',
    routes: [
      GoRoute(path: '/onboarding', builder: (_, _) => const OnboardingScreen()),
    ],
  );

  return ProviderScope(
    overrides: [
      appSlugProvider.overrideWithValue('wash-quote-test'),
      analyticsConfigProvider
          .overrideWithValue(const AnalyticsConfig.testing()),
      paywallConfigProvider.overrideWithValue(const PaywallConfig.disabled()),
      keyValueStoreProvider
          .overrideWith((ref) async => KeyValueStore.inMemory()),
      appDatabaseProvider.overrideWithValue(AppDatabase.inMemory()),
    ],
    child: MaterialApp.router(
      routerConfig: router,
      localizationsDelegates: const [
        FactoryLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ],
      builder: (context, child) => AdaptiveTheme(
        accent: const Color(0xFF0a6ea8),
        child: child ?? const SizedBox.shrink(),
      ),
    ),
  );
}

void main() {
  setUp(() {
    AdaptivePlatform.debugOverride = AdaptivePlatformType.android;
  });

  tearDown(() {
    AdaptivePlatform.debugOverride = null;
  });

  testWidgets('onboarding first step renders', (tester) async {
    await tester.pumpWidget(_testApp());
    await tester.pump();

    expect(find.text(AppStrings.onboardingBusinessName), findsOneWidget);
  });
}
