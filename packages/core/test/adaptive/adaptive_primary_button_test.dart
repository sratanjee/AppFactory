import 'package:factory_core/factory_core.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '_test_harness.dart';

void main() {
  group('AdaptivePrimaryButton', () {
    tearDown(() {
      AdaptivePlatform.debugOverride = null;
    });

    testWidgets('renders and fires onPressed on iOS', (tester) async {
      AdaptivePlatform.debugOverride = AdaptivePlatformType.ios;
      var taps = 0;
      await tester.pumpWidget(
        wrapForTest(AdaptivePrimaryButton(label: 'Start', onPressed: () => taps++)),
      );
      expect(find.text('Start'), findsOneWidget);
      expect(find.byType(CupertinoButton), findsOneWidget);
      await tester.tap(find.byType(CupertinoButton));
      await tester.pump();
      expect(taps, 1);
    });

    testWidgets('renders and fires onPressed on Android', (tester) async {
      AdaptivePlatform.debugOverride = AdaptivePlatformType.android;
      var taps = 0;
      await tester.pumpWidget(
        wrapForTest(AdaptivePrimaryButton(label: 'Start', onPressed: () => taps++)),
      );
      expect(find.text('Start'), findsOneWidget);
      expect(find.byType(FilledButton), findsOneWidget);
      await tester.tap(find.byType(FilledButton));
      await tester.pump();
      expect(taps, 1);
    });

    testWidgets('does not fire onPressed when isLoading', (tester) async {
      AdaptivePlatform.debugOverride = AdaptivePlatformType.ios;
      var taps = 0;
      await tester.pumpWidget(
        wrapForTest(
          AdaptivePrimaryButton(
            label: 'Start',
            onPressed: () => taps++,
            isLoading: true,
          ),
        ),
      );
      final button = tester.widget<CupertinoButton>(find.byType(CupertinoButton));
      expect(button.onPressed, isNull);
      expect(taps, 0);
    });

    testWidgets('does not fire onPressed when enabled is false', (tester) async {
      AdaptivePlatform.debugOverride = AdaptivePlatformType.android;
      var taps = 0;
      await tester.pumpWidget(
        wrapForTest(
          AdaptivePrimaryButton(
            label: 'Start',
            onPressed: () => taps++,
            enabled: false,
          ),
        ),
      );
      final button = tester.widget<FilledButton>(find.byType(FilledButton));
      expect(button.onPressed, isNull);
      expect(taps, 0);
    });
  });
}
