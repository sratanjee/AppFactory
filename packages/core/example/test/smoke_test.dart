import 'package:factory_core_example/app.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('ExampleApp mounts and shows home', (tester) async {
    await tester.pumpWidget(const ExampleApp());
    await tester.pump();

    expect(find.text('factory_core'), findsWidgets);
    expect(find.text('Adaptive UI'), findsOneWidget);
    expect(find.text('Onboarding'), findsOneWidget);
    expect(find.text('Paywall'), findsOneWidget);
    expect(find.text('Storage'), findsOneWidget);
    expect(find.text('Analytics'), findsOneWidget);
    expect(find.text('Widget bridge'), findsOneWidget);
    expect(find.text('Shorebird'), findsOneWidget);
  });
}
