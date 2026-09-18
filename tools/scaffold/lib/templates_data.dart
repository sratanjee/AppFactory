/// Inlined template strings. Kept in Dart source (not on disk under
/// `templates/`) so the tool has no runtime file-loading dependency and
/// `dart pub global activate` from another repo would still work.
library;

const pubspecTemplate = r'''
name: ${slugUnderscored}
description: ${appNameLiteral}.
publish_to: none
version: 1.0.0+1

environment:
  sdk: ^3.13.0
  flutter: ">=${flutterVersion} <3.48.0"

dependencies:
  factory_core:
    path: ../../packages/core
  flutter:
    sdk: flutter
  flutter_riverpod: ^3.4.3
  go_router: ^18.0.1

dev_dependencies:
  alchemist: ^0.14.0
  flutter_test:
    sdk: flutter
  integration_test:
    sdk: flutter
  very_good_analysis: ^11.0.0

flutter:
  uses-material-design: true
''';

const mainDartTemplate = r'''
import 'package:factory_core/factory_core.dart';
import 'package:flutter/widgets.dart';
import 'package:${slugUnderscored}/app.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  bootstrapShorebird();
  runApp(const ${appClassName}App());
}
''';

const appDartTemplate = r'''
import 'package:factory_core/factory_core.dart';
import 'package:flutter/widgets.dart';
import 'package:${slugUnderscored}/app_config.dart';
import 'package:${slugUnderscored}/router.dart';

class ${appClassName}App extends StatelessWidget {
  const ${appClassName}App({super.key});

  @override
  Widget build(BuildContext context) {
    return AdaptiveApp(
      title: ${appName},
      theme: const AdaptiveTheme(
        accent: Color(0x${accentHex}),
        child: SizedBox.shrink(),
      ),
      router: buildRouter(),
      riverpodOverrides: [
        appSlugProvider.overrideWithValue('${slug}'),
        analyticsConfigProvider.overrideWithValue(AppConfig.analyticsConfig),
        paywallConfigProvider.overrideWithValue(AppConfig.paywallConfig),
      ],
    );
  }
}
''';

const appConfigDartTemplate = r'''
import 'package:factory_core/factory_core.dart';

/// Static per-app config. Keys land here at build time via --dart-define;
/// local runs without those defines see empty strings and the subsystems
/// fall back to disabled/testing mode.
abstract final class AppConfig {
  static const String posthogKey =
      String.fromEnvironment('POSTHOG_KEY');
  static const String revenueCatIosKey =
      String.fromEnvironment('REVENUECAT_IOS_KEY');
  static const String revenueCatAndroidKey =
      String.fromEnvironment('REVENUECAT_ANDROID_KEY');

  static AnalyticsConfig get analyticsConfig => posthogKey.isEmpty
      ? const AnalyticsConfig.disabled()
      : const AnalyticsConfig(apiKey: posthogKey);

  static PaywallConfig get paywallConfig => PaywallConfig(
        iosApiKey: revenueCatIosKey,
        androidApiKey: revenueCatAndroidKey,
        benefits: ${benefitsList},
        termsUrl: Uri.parse('${termsUrl}'),
        privacyUrl: Uri.parse('${privacyUrl}'),
      );
}
''';

const routerDartTemplate = r'''
import 'package:go_router/go_router.dart';
import 'package:${slugUnderscored}/screens/home_screen.dart';

GoRouter buildRouter() {
  return GoRouter(
    routes: [
      GoRoute(
        path: '/',
        name: 'home',
        builder: (_, _) => const HomeScreen(),
      ),
    ],
  );
}
''';

const homeScreenTemplate = r'''
import 'package:factory_core/factory_core.dart';
import 'package:flutter/widgets.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return AdaptiveScaffold(
      title: Text(${appName}),
      body: const Center(
        child: Text('Scaffolded. Builder replaces this.'),
      ),
      primaryAction: AdaptivePrimaryButton(
        label: 'Get started',
        onPressed: () {},
      ),
    );
  }
}
''';

const shorebirdYamlTemplate = r'''
app_id: TODO_SHOREBIRD_APP_ID
''';

const runShTemplate = r'''
#!/usr/bin/env bash
# Runs ${slug} with --dart-define values sourced from factory.config so
# RevenueCat / PostHog keys land in app_config.dart's String.fromEnvironment
# reads. Pass any extra args through to `flutter run`.
#
# Per-slug key lookup: REVENUECAT_IOS_KEY_${slugUnderscored} /
# REVENUECAT_ANDROID_KEY_${slugUnderscored} are the canonical names in
# factory.config. This wrapper resolves them into REVENUECAT_IOS_KEY /
# REVENUECAT_ANDROID_KEY for the app to consume.
set -euo pipefail

APP_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
REPO_ROOT="$(cd "$APP_DIR/../.." && pwd)"

# shellcheck disable=SC1090
source "$REPO_ROOT/factory.config"
if [[ -f "$REPO_ROOT/factory.config.local" ]]; then
  # shellcheck disable=SC1090
  source "$REPO_ROOT/factory.config.local"
fi

SLUG="${slugUnderscored}"
RC_IOS_VAR="REVENUECAT_IOS_KEY_${SLUG}"
RC_ANDROID_VAR="REVENUECAT_ANDROID_KEY_${SLUG}"
RC_IOS_KEY="${!RC_IOS_VAR:-}"
RC_ANDROID_KEY="${!RC_ANDROID_VAR:-}"

cd "$APP_DIR"
exec fvm flutter run \
  --dart-define=REVENUECAT_IOS_KEY="$RC_IOS_KEY" \
  --dart-define=REVENUECAT_ANDROID_KEY="$RC_ANDROID_KEY" \
  --dart-define=POSTHOG_KEY="${POSTHOG_KEY:-}" \
  "$@"
''';

const codemagicYamlTemplate = r'''
# Codemagic lane for ${slug}. iOS ships to TestFlight; Android to
# Play internal testing. Both builds resolve the RC key per-slug from
# factory.config's REVENUECAT_IOS_KEY_${slugUnderscored} and
# REVENUECAT_ANDROID_KEY_${slugUnderscored} values and pass them as
# --dart-define during the flutter build step.
#
# Fills the Codemagic env vars from a shared group named
# "app-factory-secrets" that mirrors factory.config's non-committed values.
# See tools/monetize/ for how RC keys are provisioned.

workflows:
  ios-testflight:
    name: ${slug} — iOS TestFlight
    max_build_duration: 60
    environment:
      groups:
        - app-factory-secrets
      flutter: ${flutterVersion}
      xcode: latest
    scripts:
      - name: Resolve per-slug RC keys
        script: |
          # Codemagic exposes group vars as env directly. The vars in
          # app-factory-secrets are named REVENUECAT_IOS_KEY_<slug>.
          eval "export RC_IOS_KEY=\$REVENUECAT_IOS_KEY_${slugUnderscored}"
      - name: Build IPA
        script: |
          cd apps/${slug}
          fvm flutter build ipa --release \
            --dart-define=REVENUECAT_IOS_KEY="$RC_IOS_KEY" \
            --dart-define=POSTHOG_KEY="$POSTHOG_KEY"
      - name: Upload to TestFlight
        script: |
          app-store-connect publish \
            --path build/ios/ipa/*.ipa \
            --testflight

  android-internal:
    name: ${slug} — Play internal
    max_build_duration: 60
    environment:
      groups:
        - app-factory-secrets
      flutter: ${flutterVersion}
    scripts:
      - name: Resolve per-slug RC keys
        script: |
          eval "export RC_ANDROID_KEY=\$REVENUECAT_ANDROID_KEY_${slugUnderscored}"
      - name: Build AAB
        script: |
          cd apps/${slug}
          fvm flutter build appbundle --release \
            --dart-define=REVENUECAT_ANDROID_KEY="$RC_ANDROID_KEY" \
            --dart-define=POSTHOG_KEY="$POSTHOG_KEY"
      - name: Upload to Play internal
        script: |
          google-play publish \
            --track internal \
            build/app/outputs/bundle/release/*.aab
''';

const analysisOptionsTemplate = r'''
include: package:very_good_analysis/analysis_options.yaml

analyzer:
  language:
    strict-casts: true
    strict-inference: true
    strict-raw-types: true
  exclude:
    - build/**
    - android/**
    - ios/**

linter:
  rules:
    public_member_api_docs: false
    lines_longer_than_80_chars: false
    prefer_double_quotes: false
    unnecessary_type_name_in_constructor: false
    prefer_initializing_formals: false
''';

const smokeTestTemplate = r'''
import 'package:flutter_test/flutter_test.dart';
import 'package:${slugUnderscored}/app.dart';

void main() {
  testWidgets('${appClassName}App mounts', (tester) async {
    await tester.pumpWidget(const ${appClassName}App());
    await tester.pump();
  });
}
''';

const reviewMdTemplate = r'''
# ${appName} — review

Scaffolded ${slug}. Builder has not run yet.

## Open at scaffold time

Fill in as the pipeline progresses. Empty at scaffold means "flagged, not blocking."

- Shorebird app ID — `.shorebird/shorebird.yaml` still says `TODO_SHOREBIRD_APP_ID`.
- RevenueCat keys — read at build via --dart-define; blank locally.
- Terms / Privacy URLs — `lib/app_config.dart` uses `example.test`; swap before release.
''';

// Store metadata

const iosNameTemplate = r'${appNameLiteral}';
const iosSubtitleTemplate = r'${iosSubtitle}';
const iosKeywordsTemplate = r'${iosKeywordsCsv}';
const iosPromoTemplate = r'${primaryKeyword}';
const iosDescriptionTemplate = r'${iosLongDescription}';

const androidNameTemplate = r'${appNameLiteral}';
const androidShortDescriptionTemplate = r'${androidShortDescription}';
const androidDescriptionTemplate = r'${androidLongDescription}';
