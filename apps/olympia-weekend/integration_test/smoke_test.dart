import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:olympia_weekend/app.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timezone/data/latest_all.dart' as tz_data;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  tz_data.initializeTimeZones();

  testWidgets('OlympiaWeekendApp mounts on a fresh install', (tester) async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    await tester.pumpWidget(
      ProviderScope(
        child: OlympiaWeekendApp(prefs: prefs),
      ),
    );
    await tester.pump();
    expect(find.byType(OlympiaWeekendApp), findsOneWidget);
  });
}
