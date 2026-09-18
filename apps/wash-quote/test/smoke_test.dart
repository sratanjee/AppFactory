import 'package:factory_core/factory_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:wash_quote/l10n/app_strings.dart';
import 'package:wash_quote/screens/app_shell.dart';

Widget _testApp() {
  final router = GoRouter(
    initialLocation: '/home',
    routes: [
      GoRoute(path: '/home', builder: (_, _) => const AppShell()),
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
  testWidgets('AppShell renders four tabs', (tester) async {
    await tester.pumpWidget(_testApp());
    await tester.pump();

    expect(find.text(AppStrings.tabJobs), findsWidgets);
    expect(find.text(AppStrings.tabCustomers), findsWidgets);
    expect(find.text(AppStrings.tabServices), findsWidgets);
    expect(find.text(AppStrings.tabMoney), findsWidgets);
  });
}
