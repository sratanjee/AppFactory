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
  _StubSightingsRepo() : super(deviceId: 'smoke-test-device');

  @override
  Future<ConfirmSightingResult> confirm({
    required String athleteId,
    required Appearance appearance,
  }) async =>
      ConfirmSightingResult.disabled;
}

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  tz_data.initializeTimeZones();

  testWidgets('OlympiaWeekendApp mounts on a fresh install', (tester) async {
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
    await tester.pumpAndSettle(const Duration(seconds: 3));
    expect(find.byType(OlympiaWeekendApp), findsOneWidget);
    expect(find.text('Olympia Weekend'), findsOneWidget);
  });
}
