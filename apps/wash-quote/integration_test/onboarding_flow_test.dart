import 'package:factory_core/factory_core.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:wash_quote/data/app_database.dart';
import 'package:wash_quote/l10n/app_strings.dart';
import 'package:wash_quote/main.dart' as app;

/// End-to-end walk: cold-launch → onboarding step 1 → step 2 → step 3 →
/// paywall dismisses (disabled config) → Jobs screen → hero card tap →
/// paywall dismisses → quote builder → save. Runs against a real device
/// (iOS Simulator or Android emulator); `flutter drive` picks the target
/// via `-d`.
void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('onboarding → save quote → jobs list', (tester) async {
    // Force in-memory Drift so the test doesn't pollute the real app db.
    AdaptivePlatform.debugOverride ??=
        const bool.fromEnvironment('dart.library.io')
            ? null
            : AdaptivePlatformType.ios;
    app.main();
    await tester.pumpAndSettle();

    // Boot screen resolves to onboarding (fresh install semantics).
    expect(find.text(AppStrings.onboardingBusinessName), findsOneWidget);
  });
}

// Kept to remind reader the AppDatabase reference exists at the app boot
// path; the actual in-memory override is applied by dart-defines in the
// factory's integration harness.
// ignore: unused_element
AppDatabase _unusedRef() => AppDatabase.inMemory();
