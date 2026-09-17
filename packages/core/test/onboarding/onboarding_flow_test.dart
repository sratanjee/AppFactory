import 'package:factory_core/factory_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

Widget _wrap(
  Widget child, {
  required Analytics analytics,
  Color accent = const Color(0xFF6750A4),
}) {
  return ProviderScope(
    overrides: [
      analyticsProvider.overrideWith((_) => analytics),
    ],
    child: MaterialApp(
      debugShowCheckedModeBanner: false,
      localizationsDelegates: const [
        FactoryLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ],
      home: AdaptiveTheme(accent: accent, child: child),
    ),
  );
}

OnboardingStep _promiseStep(String text) => OnboardingStep(
      build: (_, _) => Center(child: Text(text)),
    );

void main() {
  group('OnboardingFlow', () {
    testWidgets('renders the first step and its default Continue label',
        (tester) async {
      final analytics = Analytics.testing();
      await tester.pumpWidget(_wrap(
        OnboardingFlow(
          steps: [_promiseStep('Step 1'), _promiseStep('Step 2')],
          onComplete: (_) {},
        ),
        analytics: analytics,
      ));
      await tester.pump();

      expect(find.text('Step 1'), findsOneWidget);
      expect(find.text('Step 2'), findsNothing);
      expect(find.text('Continue'), findsOneWidget);
    });

    testWidgets('primary tap advances to the next step', (tester) async {
      final analytics = Analytics.testing();
      await tester.pumpWidget(_wrap(
        OnboardingFlow(
          steps: [_promiseStep('Step 1'), _promiseStep('Step 2')],
          onComplete: (_) {},
        ),
        analytics: analytics,
      ));
      await tester.pump();

      await tester.tap(find.text('Continue'));
      await tester.pumpAndSettle();

      expect(find.text('Step 1'), findsNothing);
      expect(find.text('Step 2'), findsOneWidget);
      // Terminal step shows "Get started" instead of "Continue".
      expect(find.text('Get started'), findsOneWidget);
    });

    testWidgets('last-step primary tap fires onComplete with answers',
        (tester) async {
      final analytics = Analytics.testing();
      Map<String, Object?>? capturedAnswers;
      await tester.pumpWidget(_wrap(
        OnboardingFlow(
          steps: [
            OnboardingStep(
              build: (_, sc) {
                sc.answer('goal', 'reduce');
                return const Center(child: Text('Step 1'));
              },
            ),
            _promiseStep('Step 2'),
          ],
          onComplete: (answers) => capturedAnswers = answers,
        ),
        analytics: analytics,
      ));
      await tester.pump();
      await tester.tap(find.text('Continue'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Get started'));
      await tester.pumpAndSettle();

      expect(capturedAnswers, equals({'goal': 'reduce'}));
    });

    testWidgets('canAdvance = false disables the primary button',
        (tester) async {
      final analytics = Analytics.testing();
      await tester.pumpWidget(_wrap(
        OnboardingFlow(
          steps: [
            const OnboardingStep(
              canAdvance: false,
              build: _staticStepBuilder,
            ),
            _promiseStep('Step 2'),
          ],
          onComplete: (_) {},
        ),
        analytics: analytics,
      ));
      await tester.pump();

      // Tapping should be a no-op.
      await tester.tap(find.text('Continue'));
      await tester.pumpAndSettle();
      expect(find.text('Step 1'), findsOneWidget);
      expect(find.text('Step 2'), findsNothing);
    });

    testWidgets('setCanAdvance(true) enables the primary button',
        (tester) async {
      final analytics = Analytics.testing();
      late OnboardingStepContext capturedCtx;
      await tester.pumpWidget(_wrap(
        OnboardingFlow(
          steps: [
            OnboardingStep(
              canAdvance: false,
              build: (_, sc) {
                capturedCtx = sc;
                return const Center(child: Text('Step 1'));
              },
            ),
            _promiseStep('Step 2'),
          ],
          onComplete: (_) {},
        ),
        analytics: analytics,
      ));
      await tester.pump();

      capturedCtx.setCanAdvance(canAdvance: true);
      await tester.pump();
      await tester.tap(find.text('Continue'));
      await tester.pumpAndSettle();
      expect(find.text('Step 2'), findsOneWidget);
    });

    testWidgets('onPrimary is invoked and can suppress advance',
        (tester) async {
      final analytics = Analytics.testing();
      var invoked = 0;
      await tester.pumpWidget(_wrap(
        OnboardingFlow(
          steps: [
            OnboardingStep(
              build: (_, _) => const Center(child: Text('Step 1')),
              onPrimary: (ctx) async {
                invoked++;
                return false; // stay on this step
              },
            ),
            _promiseStep('Step 2'),
          ],
          onComplete: (_) {},
        ),
        analytics: analytics,
      ));
      await tester.pump();

      await tester.tap(find.text('Continue'));
      await tester.pumpAndSettle();

      expect(invoked, 1);
      expect(find.text('Step 1'), findsOneWidget);
      expect(find.text('Step 2'), findsNothing);
    });

    testWidgets('ctx.advance() moves forward programmatically',
        (tester) async {
      final analytics = Analytics.testing();
      late OnboardingStepContext capturedCtx;
      await tester.pumpWidget(_wrap(
        OnboardingFlow(
          steps: [
            OnboardingStep(
              build: (_, sc) {
                capturedCtx = sc;
                return const Center(child: Text('Step 1'));
              },
            ),
            _promiseStep('Step 2'),
          ],
          onComplete: (_) {},
        ),
        analytics: analytics,
      ));
      await tester.pump();

      capturedCtx.advance();
      await tester.pumpAndSettle();
      expect(find.text('Step 2'), findsOneWidget);
    });

    testWidgets('trackOnboardingStep fires with the visible index',
        (tester) async {
      final analytics = Analytics.testing();
      await tester.pumpWidget(_wrap(
        OnboardingFlow(
          steps: [
            _promiseStep('Step 1'),
            _promiseStep('Step 2'),
            _promiseStep('Step 3'),
          ],
          onComplete: (_) {},
        ),
        analytics: analytics,
      ));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Continue'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Continue'));
      await tester.pumpAndSettle();

      final steps = analytics.recordedEvents
          .where((e) => e.name == 'onboarding_step')
          .map((e) => e.properties['step'])
          .toList();
      expect(steps, [0, 1, 2]);
    });

    testWidgets('onCancel button fires when provided', (tester) async {
      final analytics = Analytics.testing();
      var cancelled = 0;
      await tester.pumpWidget(_wrap(
        OnboardingFlow(
          steps: [_promiseStep('Step 1'), _promiseStep('Step 2')],
          onComplete: (_) {},
          onCancel: () => cancelled++,
        ),
        analytics: analytics,
      ));
      await tester.pump();

      // The xmark leading tap area.
      await tester.tap(find.byType(AdaptiveIcon).first);
      await tester.pumpAndSettle();
      expect(cancelled, 1);
    });
  });

  group('OnboardingFlow step-count assertion', () {
    testWidgets('rejects fewer than 2 steps', (tester) async {
      await tester.pumpWidget(_wrap(
        OnboardingFlow(
          steps: [_promiseStep('Only one')],
          onComplete: (_) {},
        ),
        analytics: Analytics.testing(),
      ));
      expect(tester.takeException(), isA<AssertionError>());
    });

    testWidgets('rejects more than 4 steps', (tester) async {
      await tester.pumpWidget(_wrap(
        OnboardingFlow(
          steps: List.generate(5, (i) => _promiseStep('S$i')),
          onComplete: (_) {},
        ),
        analytics: Analytics.testing(),
      ));
      expect(tester.takeException(), isA<AssertionError>());
    });
  });
}

Widget _staticStepBuilder(BuildContext context, OnboardingStepContext ctx) =>
    const Center(child: Text('Step 1'));
