import 'dart:async';

import 'package:alchemist/alchemist.dart';
import 'package:factory_core/factory_core.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

import '_test_harness.dart';

Widget _scaffold({String? title, bool withPrimaryAction = true}) {
  return AdaptiveScaffold(
    title: title == null ? null : Text(title),
    body: const Center(
      child: Text(
        'Body content',
        textAlign: TextAlign.center,
      ),
    ),
    primaryAction: withPrimaryAction
        ? AdaptivePrimaryButton(label: 'Start counting', onPressed: () {})
        : null,
  );
}

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
        'AdaptiveScaffold — ${platform.name}',
        fileName: 'adaptive_scaffold_${platform.name}',
        builder: () => GoldenTestGroup(
          scenarioConstraints: const BoxConstraints(maxWidth: 360, maxHeight: 640),
          children: [
            GoldenTestScenario(
              name: 'title + primary action, light 100%',
              child: wrapForTest(_scaffold(title: 'Home')),
            ),
            GoldenTestScenario(
              name: 'title + primary action, dark 100%',
              child: wrapForTest(
                _scaffold(title: 'Home'),
                brightness: Brightness.dark,
              ),
            ),
            GoldenTestScenario(
              name: 'title + primary action, light 200%',
              child: wrapForTest(_scaffold(title: 'Home'), textScale: 2),
            ),
            GoldenTestScenario(
              name: 'no title, no primary action',
              child: wrapForTest(_scaffold(withPrimaryAction: false)),
            ),
          ],
        ),
      ));
    });
  }
}
