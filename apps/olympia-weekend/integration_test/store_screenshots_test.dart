// Store screenshots for App Store and Play Store submission.
// Covers the 6 screens specified in the release brief.
// Excludes event_detail (Dragon's Lair not findable via text tap in test env)
// and saved screen (Saved is now a heart action, not a tab).

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:olympia_weekend/app.dart';
import 'package:olympia_weekend/data/models.dart';
import 'package:olympia_weekend/features/mixpanel_service.dart';
import 'package:olympia_weekend/features/sightings_repo.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timezone/data/latest_all.dart' as tz_data;

class _StubSightingsRepo extends SightingsRepo {
  _StubSightingsRepo() : super(deviceId: 'screenshot-test-device');
  @override
  Future<ConfirmSightingResult> confirm({
    required String athleteId,
    required Appearance appearance,
  }) async => ConfirmSightingResult.disabled;
}

Future<void> goTab(WidgetTester tester, String label) async {
  await tester.tap(find.text(label).first);
  await tester.pumpAndSettle(const Duration(seconds: 3));
}

void main() {
  final binding = IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  tz_data.initializeTimeZones();

  Future<void> pumpApp(WidgetTester tester) async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          mixpanelProvider.overrideWithValue(MixpanelService.stub()),
          sightingsRepoProvider.overrideWithValue(_StubSightingsRepo()),
        ],
        child: OlympiaWeekendApp(prefs: prefs),
      ),
    );
    await tester.pumpAndSettle(const Duration(seconds: 4));
  }

  testWidgets('01-now', (tester) async {
    await pumpApp(tester);
    await binding.takeScreenshot('01-now');
  });

  testWidgets('02-schedule', (tester) async {
    await pumpApp(tester);
    await goTab(tester, 'Schedule');
    await binding.takeScreenshot('02-schedule');
  });

  testWidgets('04-athletes', (tester) async {
    await pumpApp(tester);
    await goTab(tester, 'Athletes');
    await binding.takeScreenshot('04-athletes');
  });

  testWidgets('05-athlete-detail', (tester) async {
    await pumpApp(tester);
    await goTab(tester, 'Athletes');
    await tester.tap(find.text('Derek Lunsford'));
    await tester.pumpAndSettle(const Duration(seconds: 2));
    await binding.takeScreenshot('05-athlete-detail');
  });

  testWidgets('06-expo', (tester) async {
    await pumpApp(tester);
    await goTab(tester, 'Expo');
    await binding.takeScreenshot('06-expo');
  });

  testWidgets('venues', (tester) async {
    await pumpApp(tester);
    await goTab(tester, 'Venues');
    await binding.takeScreenshot('venues');
  });
}
