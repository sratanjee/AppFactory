import 'dart:io';

import 'package:scaffold/spec.dart';
import 'package:test/test.dart';

void main() {
  late Spec spec;

  setUpAll(() async {
    final content = await File('test/fixtures/2026-09-17-example.md').readAsString();
    spec = SpecParser(content).parse();
  });

  test('§1 identity', () {
    expect(spec.appName, 'Habits');
    expect(spec.iosSubtitle, 'One habit a day');
    expect(spec.slug, 'example-habits');
    expect(spec.bundleIdRaw, 'com.appfactory.examplehabits');
    expect(spec.storeCategory, 'Health & Fitness');
    expect(spec.developerAccount, 'A');
    expect(spec.factoryCategory, 'utility');
  });

  test('§2 the job', () {
    expect(
      spec.job,
      contains('I want to keep one habit a day'),
    );
    expect(spec.who, 'solo desk worker in their 30s');
    expect(spec.where, 'r/getdisciplined');
    expect(spec.whyPay, contains('quiet'));
  });

  test('§3 screens', () {
    expect(spec.screens, hasLength(3));
    expect(spec.screens[0].name, 'Today');
    expect(spec.screens[0].purpose, "Show today's habit + tap-to-check");
    expect(spec.screens[0].keyInteraction, 'Tap the habit card');
  });

  test('§4 data model', () {
    expect(spec.backendMode, 'no');
    expect(spec.syncMode, 'none');
    expect(spec.dataModelRaw, contains('Habit'));
    expect(spec.dataModelRaw, contains('HabitEntry'));
  });

  test('§5 native surfaces', () {
    expect(spec.nativeSurfaces.homeWidget, isTrue);
    expect(spec.nativeSurfaces.notifications, isTrue);
    expect(spec.nativeSurfaces.liveActivityOrOngoing, isFalse);
    expect(spec.nativeSurfaces.camera, isFalse);
  });

  test('§6 monetization', () {
    expect(spec.monetization.paywallPlacement, contains('after onboarding'));
    expect(spec.monetization.freeTrial, '7-day');
    expect(spec.monetization.weeklyPrice, r'$2.99');
    expect(spec.monetization.annualPrice, r'$19.99');
    expect(spec.monetization.revenueCatEntitlement, 'pro');
    expect(spec.monetization.benefits, hasLength(3));
    expect(spec.monetization.benefits[0], contains('every habit'));
  });

  test('§7 onboarding', () {
    expect(spec.onboardingSteps, hasLength(3));
    expect(spec.onboardingSteps[0], contains('Promise'));
  });

  test('§8 design notes', () {
    expect(spec.designNotes.accentHex, '#7A5AF8');
    expect(spec.designNotes.iconConcept, contains('check mark'));
    expect(spec.designNotes.toneOfCopy, 'quiet, encouraging');
    expect(spec.designNotes.differsFromSiblings, contains('gamification'));
  });

  test('§9 store seeds', () {
    expect(spec.storeSeeds.primaryKeyword, 'habits');
    expect(spec.storeSeeds.secondaryKeywords, hasLength(5));
    expect(spec.storeSeeds.secondaryKeywords[0], 'habit');
    expect(spec.storeSeeds.screenshotStory, hasLength(5));
    expect(spec.storeSeeds.screenshotStory[0],
        "See today's habit at a glance");
  });

  test('§11 out of scope', () {
    expect(spec.outOfScope, hasLength(2));
    expect(spec.outOfScope[0], contains('social'));
  });

  test('slugUnderscored replaces hyphens', () {
    expect(spec.slugUnderscored, 'example_habits');
  });

  test('throws on missing §1 App name', () {
    const bad = '''
## 1. Identity

| Field | Value |
|---|---|
| Slug (lowercase, hyphenated) | foo |
''';
    expect(
      () => SpecParser(bad).parse(),
      throwsA(isA<SpecParseException>()),
    );
  });
}
