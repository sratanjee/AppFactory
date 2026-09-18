import 'package:factory_core/factory_core.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';

Widget _host(Widget child, {Brightness brightness = Brightness.light}) {
  return MaterialApp(
    debugShowCheckedModeBanner: false,
    localizationsDelegates: const [
      FactoryLocalizations.delegate,
      GlobalMaterialLocalizations.delegate,
      GlobalCupertinoLocalizations.delegate,
      GlobalWidgetsLocalizations.delegate,
    ],
    theme: brightness == Brightness.dark ? ThemeData.dark() : ThemeData.light(),
    home: AdaptiveTheme(
      accent: const Color(0xFF6750A4),
      child: child,
    ),
  );
}

void main() {
  group('AdaptiveScaffold — Cupertino hero-tag', () {
    setUp(() {
      AdaptivePlatform.debugOverride = AdaptivePlatformType.ios;
    });
    tearDown(() {
      AdaptivePlatform.debugOverride = null;
    });

    testWidgets(
      'four AdaptiveScaffolds live simultaneously without hero-tag '
      'collision (transitionBetweenRoutes defaults to false)',
      (tester) async {
        // Column keeps every nav bar in the tree at once, unlike
        // IndexedStack which only builds the visible child.
        await tester.pumpWidget(
          _host(
            const Column(
              children: [
                Expanded(
                  child: AdaptiveScaffold(
                    title: Text('Jobs'),
                    body: SizedBox.shrink(),
                  ),
                ),
                Expanded(
                  child: AdaptiveScaffold(
                    title: Text('Customers'),
                    body: SizedBox.shrink(),
                  ),
                ),
                Expanded(
                  child: AdaptiveScaffold(
                    title: Text('Services'),
                    body: SizedBox.shrink(),
                  ),
                ),
                Expanded(
                  child: AdaptiveScaffold(
                    title: Text('Money'),
                    body: SizedBox.shrink(),
                  ),
                ),
              ],
            ),
          ),
        );
        await tester.pumpAndSettle();

        // If any of the four CupertinoNavigationBars was still opting in
        // to hero-based transitions, HeroController would throw
        // "multiple heroes with the same tag" during layout.
        expect(tester.takeException(), isNull);

        final bars = tester
            .widgetList<CupertinoNavigationBar>(find.byType(CupertinoNavigationBar))
            .toList();
        expect(bars, hasLength(4));
        for (final bar in bars) {
          expect(bar.transitionBetweenRoutes, isFalse,
              reason: 'tab-shell scaffolds must not share hero tags');
        }
      },
    );

    testWidgets(
      'sliver nav-bar variant also opts out of hero transitions by default',
      (tester) async {
        await tester.pumpWidget(
          _host(
            const AdaptiveScaffold(
              title: Text('Jobs'),
              titleDisplay: TitleDisplay.large,
              body: SizedBox(height: 200),
            ),
          ),
        );
        await tester.pumpAndSettle();

        expect(tester.takeException(), isNull);
        final bar = tester.widget<CupertinoSliverNavigationBar>(
          find.byType(CupertinoSliverNavigationBar),
        );
        expect(bar.transitionBetweenRoutes, isFalse);
      },
    );

    testWidgets(
      'opt-in: transitionBetweenRoutes:true forwards to nav bar',
      (tester) async {
        await tester.pumpWidget(
          _host(
            const AdaptiveScaffold(
              title: Text('Detail'),
              transitionBetweenRoutes: true,
              body: SizedBox.shrink(),
            ),
          ),
        );
        await tester.pumpAndSettle();
        final bar = tester
            .widget<CupertinoNavigationBar>(find.byType(CupertinoNavigationBar));
        expect(bar.transitionBetweenRoutes, isTrue);
      },
    );
  });
}
