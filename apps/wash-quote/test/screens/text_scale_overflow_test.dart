import 'package:factory_core/factory_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:wash_quote/data/app_database.dart';
import 'package:wash_quote/data/business_repo.dart';
import 'package:wash_quote/data/job_repo.dart';
import 'package:wash_quote/screens/jobs_screen.dart';
import 'package:wash_quote/screens/money_screen.dart';
import 'package:wash_quote/screens/onboarding_screen.dart';

/// 200% text-scale overflow guards for the three screens the reviewer
/// flagged in round 1: onboarding (starter row), jobs (hero card),
/// money (totals grid). Each test pumps the screen inside a phone-sized
/// MediaQuery with textScaler=2.0 and asserts no framework exception
/// was recorded — RenderFlex overflow surfaces via
/// `FlutterError.onError`, so `tester.takeException()` catches it.
Widget _host({
  required Widget child,
  required Widget Function(BuildContext) route,
  required List<Override> overrides,
  double textScale = 2.0,
  Size size = const Size(390, 844),
}) {
  final router = GoRouter(
    initialLocation: '/screen',
    routes: [GoRoute(path: '/screen', builder: (ctx, _) => route(ctx))],
  );
  return ProviderScope(
    overrides: overrides,
    child: MediaQuery(
      data: MediaQueryData(
        size: size,
        textScaler: TextScaler.linear(textScale),
      ),
      child: MaterialApp.router(
        debugShowCheckedModeBanner: false,
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
    ),
  );
}

List<Override> _baseOverrides(AppDatabase db) => [
      appSlugProvider.overrideWithValue('wash-quote-test'),
      analyticsConfigProvider
          .overrideWithValue(const AnalyticsConfig.testing()),
      paywallConfigProvider.overrideWithValue(const PaywallConfig.disabled()),
      keyValueStoreProvider
          .overrideWith((ref) async => KeyValueStore.inMemory()),
      appDatabaseProvider.overrideWithValue(db),
    ];

void main() {
  setUp(() {
    AdaptivePlatform.debugOverride = AdaptivePlatformType.android;
  });
  tearDown(() {
    AdaptivePlatform.debugOverride = null;
  });

  testWidgets(
    'onboarding starter row lays out at 200% text scale without overflow',
    (tester) async {
      final db = AppDatabase.inMemory();
      addTearDown(db.close);
      await tester.pumpWidget(
        _host(
          child: const OnboardingScreen(),
          route: (_) => const OnboardingScreen(),
          overrides: _baseOverrides(db),
        ),
      );
      // Move to step 2 (services list) via the OnboardingFlow's primary
      // action. The business step's canAdvance starts false, so type a
      // business name first.
      await tester.pumpAndSettle();
      final input = find.byType(EditableText).first;
      await tester.enterText(input, 'Test Wash');
      await tester.pumpAndSettle();
      // Tap the primary "Next"/"Continue" button.
      final nextButton = find.byType(AdaptivePrimaryButton).first;
      await tester.tap(nextButton, warnIfMissed: false);
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull,
          reason: 'starter row must not overflow at 200% text scale');
    },
  );

  testWidgets(
    'jobs hero card lays out at 200% text scale without overflow',
    (tester) async {
      final db = AppDatabase.inMemory();
      addTearDown(db.close);
      final business = BusinessRepo(db);
      await business.upsertSingleton(name: 'Test Wash');

      await tester.pumpWidget(
        _host(
          child: const JobsScreen(mode: JobsMode.all),
          route: (_) => const JobsScreen(mode: JobsMode.all),
          overrides: [
            ..._baseOverrides(db),
            // Emit an empty list synchronously so the screen resolves past
            // AdaptiveLoading (a CupertinoActivityIndicator ticker that
            // pumpAndSettle can never drain in unit tests).
            jobSummariesProvider.overrideWith(
              (ref) => Stream<List<JobSummary>>.value(const []),
            ),
          ],
        ),
      );
      await tester.pump();
      await tester.pump();

      expect(tester.takeException(), isNull,
          reason: 'jobs hero subline must not overflow at 200% text scale');
    },
  );

  testWidgets(
    'money totals grid lays out at 200% text scale without overflow',
    (tester) async {
      final db = AppDatabase.inMemory();
      addTearDown(db.close);

      // Construct a JobSummary in-Dart so the test never touches the
      // Drift stream layer — Drift closes its stream via a zero-duration
      // Timer that outlives the widget tree and trips the tester's
      // "!timersPending" invariant.
      final now = DateTime.now().millisecondsSinceEpoch;
      final fakeJob = Job(
        id: 1,
        status: JobStatus.paid.code,
        number: 1001,
        createdAt: now,
        paidAt: now,
        depositPct: 25,
      );
      final summary = JobSummary(
        job: fakeJob,
        customer: null,
        // large number stresses the money tile's price cell
        totalCents: 9999999,
        beforePhotoPath: null,
        primaryServiceName: 'Sample line',
      );

      await tester.pumpWidget(
        _host(
          child: const MoneyScreen(),
          route: (_) => const MoneyScreen(),
          overrides: [
            ..._baseOverrides(db),
            jobSummariesProvider.overrideWith(
              (ref) => Stream<List<JobSummary>>.value([summary]),
            ),
          ],
        ),
      );
      await tester.pump();
      await tester.pump();

      expect(tester.takeException(), isNull,
          reason: 'money totals grid must not overflow at 200% text scale');
    },
  );
}
