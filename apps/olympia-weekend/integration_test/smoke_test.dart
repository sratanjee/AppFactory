import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:olympia_weekend/app.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('OlympiaWeekendApp mounts on a fresh install', (tester) async {
    await tester.pumpWidget(const OlympiaWeekendApp());
    await tester.pump();
    expect(find.byType(OlympiaWeekendApp), findsOneWidget);
  });
}
