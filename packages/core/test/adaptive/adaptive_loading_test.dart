import 'package:factory_core/adaptive/adaptive_states.dart';
import 'package:flutter/cupertino.dart' show CupertinoActivityIndicator;
import 'package:flutter_test/flutter_test.dart';

import '_test_harness.dart';

void main() {
  group('AdaptiveLoading', () {
    tearDown(() {
      // flutter_test_config flips this to true; keep the default here in
      // case a test toggles it back for the production path.
      AdaptiveLoading.testMode = true;
    });

    testWidgets('pumpAndSettle returns when testMode is true', (tester) async {
      AdaptiveLoading.testMode = true;
      await tester.pumpWidget(wrapForTest(const AdaptiveLoading()));
      // Would deadlock if the Cupertino spinner still animated.
      await tester
          .pumpAndSettle(const Duration(seconds: 1))
          .timeout(const Duration(seconds: 5));
      expect(find.byType(CupertinoActivityIndicator), findsNothing);
    });

    testWidgets('renders the animated indicator when testMode is false',
        (tester) async {
      AdaptiveLoading.testMode = false;
      try {
        await tester.pumpWidget(wrapForTest(const AdaptiveLoading()));
        await tester.pump();
        expect(find.byType(CupertinoActivityIndicator), findsOneWidget);
      } finally {
        AdaptiveLoading.testMode = true;
      }
    });
  });
}
