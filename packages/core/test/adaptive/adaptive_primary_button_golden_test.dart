import 'dart:async';

import 'package:alchemist/alchemist.dart';
import 'package:factory_core/factory_core.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

import '_test_harness.dart';

void main() {
  for (final platform in AdaptivePlatformType.values) {
    group(platform.name, () {
      setUp(() {
        AdaptivePlatform.debugOverride = platform;
      });
      tearDown(() {
        AdaptivePlatform.debugOverride = null;
      });

      unawaited(goldenTest(
        'AdaptivePrimaryButton — ${platform.name}',
        fileName: 'adaptive_primary_button_${platform.name}',
        builder: () => GoldenTestGroup(
          scenarioConstraints: const BoxConstraints(maxWidth: 320),
          children: [
            GoldenTestScenario(
              name: 'light 100%',
              child: wrapForTest(
                AdaptivePrimaryButton(label: 'Start counting', onPressed: () {}),
              ),
            ),
            GoldenTestScenario(
              name: 'dark 100%',
              child: wrapForTest(
                AdaptivePrimaryButton(label: 'Start counting', onPressed: () {}),
                brightness: Brightness.dark,
              ),
            ),
            GoldenTestScenario(
              name: 'light 200%',
              child: wrapForTest(
                AdaptivePrimaryButton(label: 'Start counting', onPressed: () {}),
                textScale: 2,
              ),
            ),
            GoldenTestScenario(
              name: 'dark 200%',
              child: wrapForTest(
                AdaptivePrimaryButton(label: 'Start counting', onPressed: () {}),
                brightness: Brightness.dark,
                textScale: 2,
              ),
            ),
            GoldenTestScenario(
              name: 'disabled',
              child: wrapForTest(
                const AdaptivePrimaryButton(
                  label: 'Start counting',
                  onPressed: null,
                ),
              ),
            ),
          ],
        ),
      ));
    });
  }
}
