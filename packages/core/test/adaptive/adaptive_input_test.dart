import 'package:factory_core/factory_core.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';

/// Wraps [child] with enough scaffolding for EditableText to work
/// (MaterialApp provides the required Overlay ancestor).
Widget _inputHost(Widget child) {
  return MaterialApp(
    debugShowCheckedModeBanner: false,
    localizationsDelegates: const [
      FactoryLocalizations.delegate,
      GlobalMaterialLocalizations.delegate,
      GlobalCupertinoLocalizations.delegate,
      GlobalWidgetsLocalizations.delegate,
    ],
    home: Scaffold(
      body: SafeArea(
        child: AdaptiveTheme(
          accent: const Color(0xFF6750A4),
          child: Padding(padding: const EdgeInsets.all(16), child: child),
        ),
      ),
    ),
  );
}

void main() {
  group('AdaptiveInput', () {
    tearDown(() {
      AdaptivePlatform.debugOverride = null;
    });

    testWidgets('renders CupertinoTextField on iOS', (tester) async {
      AdaptivePlatform.debugOverride = AdaptivePlatformType.ios;
      final controller = TextEditingController();
      await tester.pumpWidget(
        _inputHost(
          AdaptiveInput(controller: controller, placeholder: 'Name'),
        ),
      );
      expect(find.byType(CupertinoTextField), findsOneWidget);
      expect(find.byType(TextField), findsNothing);
    });

    testWidgets('renders Material TextField on Android', (tester) async {
      AdaptivePlatform.debugOverride = AdaptivePlatformType.android;
      final controller = TextEditingController();
      await tester.pumpWidget(
        _inputHost(
          AdaptiveInput(controller: controller, placeholder: 'Name'),
        ),
      );
      expect(find.byType(TextField), findsOneWidget);
      expect(find.byType(CupertinoTextField), findsNothing);
    });

    testWidgets('placeholder shows on both platforms', (tester) async {
      for (final platform in AdaptivePlatformType.values) {
        AdaptivePlatform.debugOverride = platform;
        final controller = TextEditingController();
        await tester.pumpWidget(
          _inputHost(
            AdaptiveInput(controller: controller, placeholder: 'Type here'),
          ),
        );
        expect(find.text('Type here'), findsOneWidget,
            reason: 'placeholder missing on ${platform.name}');
      }
    });

    testWidgets('onChanged fires with the entered text on iOS',
        (tester) async {
      AdaptivePlatform.debugOverride = AdaptivePlatformType.ios;
      final controller = TextEditingController();
      String? seen;
      await tester.pumpWidget(
        _inputHost(
          AdaptiveInput(
            controller: controller,
            onChanged: (v) => seen = v,
          ),
        ),
      );
      await tester.enterText(find.byType(CupertinoTextField), 'hello');
      expect(seen, 'hello');
      expect(controller.text, 'hello');
    });

    testWidgets('onChanged fires with the entered text on Android',
        (tester) async {
      AdaptivePlatform.debugOverride = AdaptivePlatformType.android;
      final controller = TextEditingController();
      String? seen;
      await tester.pumpWidget(
        _inputHost(
          AdaptiveInput(
            controller: controller,
            onChanged: (v) => seen = v,
          ),
        ),
      );
      await tester.enterText(find.byType(TextField), 'world');
      expect(seen, 'world');
      expect(controller.text, 'world');
    });

    testWidgets('enabled=false disables the input on Android',
        (tester) async {
      AdaptivePlatform.debugOverride = AdaptivePlatformType.android;
      final controller = TextEditingController();
      await tester.pumpWidget(
        _inputHost(
          AdaptiveInput(controller: controller, enabled: false),
        ),
      );
      final field = tester.widget<TextField>(find.byType(TextField));
      expect(field.enabled, isFalse);
    });

    testWidgets('enabled=false disables the input on iOS', (tester) async {
      AdaptivePlatform.debugOverride = AdaptivePlatformType.ios;
      final controller = TextEditingController();
      await tester.pumpWidget(
        _inputHost(
          AdaptiveInput(controller: controller, enabled: false),
        ),
      );
      final field =
          tester.widget<CupertinoTextField>(find.byType(CupertinoTextField));
      expect(field.enabled, isFalse);
    });
  });
}
