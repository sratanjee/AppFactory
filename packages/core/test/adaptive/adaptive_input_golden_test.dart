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
        'AdaptiveInput — ${platform.name}',
        fileName: 'adaptive_input_${platform.name}',
        builder: () => GoldenTestGroup(
          scenarioConstraints: const BoxConstraints(maxWidth: 320),
          children: [
            GoldenTestScenario(
              name: 'empty light 100%',
              child: wrapForTest(
                AdaptiveInput(
                  controller: TextEditingController(),
                  placeholder: 'Type here',
                ),
              ),
            ),
            GoldenTestScenario(
              name: 'empty dark 100%',
              child: wrapForTest(
                AdaptiveInput(
                  controller: TextEditingController(),
                  placeholder: 'Type here',
                ),
                brightness: Brightness.dark,
              ),
            ),
            GoldenTestScenario(
              name: 'filled light 100%',
              child: wrapForTest(
                AdaptiveInput(
                  controller: TextEditingController(text: 'Hello world'),
                ),
              ),
            ),
            GoldenTestScenario(
              name: 'filled light 200%',
              child: wrapForTest(
                AdaptiveInput(
                  controller: TextEditingController(text: 'Hello world'),
                ),
                textScale: 2,
              ),
            ),
            GoldenTestScenario(
              name: 'disabled light 100%',
              child: wrapForTest(
                AdaptiveInput(
                  controller: TextEditingController(text: 'Read only'),
                  enabled: false,
                ),
              ),
            ),
          ],
        ),
      ));
    });
  }
}
