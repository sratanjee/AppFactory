import 'package:factory_core/factory_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:impulse/data/app_database.dart';
import 'package:impulse/screens/home_screen.dart';
import 'package:impulse/screens/onboarding_screen.dart';

Widget _testApp() {
  final router = GoRouter(
    initialLocation: '/onboarding',
    routes: [
      GoRoute(
        path: '/onboarding',
        builder: (_, _) => const OnboardingScreen(),
      ),
      GoRoute(path: '/home', builder: (_, _) => const HomeScreen()),
    ],
  );

  return ProviderScope(
    overrides: [
      appSlugProvider.overrideWithValue('impulse-test'),
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
        accent: const Color(0xFF1D9A6C),
        child: child ?? const SizedBox.shrink(),
      ),
    ),
  );
}

void main() {
  testWidgets('onboarding renders and shows the first step', (tester) async {
    await tester.pumpWidget(_testApp());
    await tester.pump();

    expect(find.textContaining('Wanting and paying'), findsOneWidget);
    expect(find.text('Continue'), findsOneWidget);
  });
}
