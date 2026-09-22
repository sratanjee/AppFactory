// Screenshot capture integration test for Olympia Weekend.
//
// Set TEXT_SCALE dart-define to control text size:
//   --dart-define=TEXT_SCALE=2.0  # for 200% text
//   --dart-define=TEXT_SCALE=1.0  # for 100% text (default)

import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:olympia_weekend/app.dart';
import 'package:olympia_weekend/data/models.dart';
import 'package:olympia_weekend/features/mixpanel_service.dart';
import 'package:olympia_weekend/features/sightings_repo.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timezone/data/latest_all.dart' as tz_data;

const _kTextScaleRaw =
    String.fromEnvironment('TEXT_SCALE', defaultValue: '1.0');
final double _kTextScale = double.tryParse(_kTextScaleRaw) ?? 1.0;

class _StubSightingsRepo extends SightingsRepo {
  _StubSightingsRepo() : super(deviceId: 'screenshot-test-device');

  @override
  Future<ConfirmSightingResult> confirm({
    required String athleteId,
    required Appearance appearance,
  }) async =>
      ConfirmSightingResult.disabled;
}

/// Navigate to a tab by its label and wait for it to settle.
Future<void> goTab(WidgetTester tester, String label) async {
  await tester.tap(find.text(label).first);
  await tester.pumpAndSettle(const Duration(seconds: 3));
}

Widget _wrapWithScale(Widget child) {
  if (_kTextScale == 1.0) return child;
  return Builder(
    builder: (ctx) {
      final mq = MediaQuery.of(ctx);
      return MediaQuery(
        data: mq.copyWith(
          textScaler: TextScaler.linear(_kTextScale),
        ),
        child: child,
      );
    },
  );
}

void main() {
  final binding = IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  tz_data.initializeTimeZones();

  Future<void> pumpApp(WidgetTester tester) async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    await tester.pumpWidget(
      _wrapWithScale(
        ProviderScope(
          overrides: [
            mixpanelProvider.overrideWithValue(MixpanelService.stub()),
            sightingsRepoProvider.overrideWithValue(_StubSightingsRepo()),
          ],
          child: OlympiaWeekendApp(prefs: prefs),
        ),
      ),
    );
    await tester.pumpAndSettle(const Duration(seconds: 4));
  }

  testWidgets('Capture screenshots — Now screen', (tester) async {
    await pumpApp(tester);
    await binding.takeScreenshot('now');
  });

  testWidgets('Capture screenshots — Schedule screen', (tester) async {
    await pumpApp(tester);
    await goTab(tester, 'Schedule');
    await binding.takeScreenshot('schedule');
  });

  testWidgets('Capture screenshots — Athletes screen', (tester) async {
    await pumpApp(tester);
    await goTab(tester, 'Athletes');
    await binding.takeScreenshot('athletes');
  });

  testWidgets('Capture screenshots — Athlete detail', (tester) async {
    await pumpApp(tester);
    await goTab(tester, 'Athletes');
    await tester.tap(find.text('Derek Lunsford'));
    await tester.pumpAndSettle(const Duration(seconds: 2));
    await binding.takeScreenshot('athlete');
  });

  testWidgets('Capture screenshots — Venues screen', (tester) async {
    await pumpApp(tester);
    await goTab(tester, 'Venues');
    await binding.takeScreenshot('venues');
  });

  testWidgets('Capture screenshots — Saved screen (empty)', (tester) async {
    await pumpApp(tester);
    await goTab(tester, 'Saved');
    await binding.takeScreenshot('saved');
  });

  testWidgets('Capture screenshots — Event detail', (tester) async {
    await pumpApp(tester);
    await goTab(tester, 'Schedule');
    final fri = find.text('Fri');
    if (tester.any(fri)) {
      await tester.tap(fri.first);
      await tester.pumpAndSettle(const Duration(milliseconds: 500));
    }
    await tester.tap(find.text("Dragon's Lair Pop-Up Gym"));
    await tester.pumpAndSettle(const Duration(seconds: 2));
    await binding.takeScreenshot('event');
  });
}
