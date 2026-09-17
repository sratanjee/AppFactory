import 'dart:async';

import 'package:alchemist/alchemist.dart';
import 'package:factory_core/factory_core.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

import '_test_harness.dart';

const _sampleSections = <AdaptiveListSection>[
  AdaptiveListSection(
    header: 'General',
    items: [
      AdaptiveListItem(title: 'Notifications', hasNavigation: true),
      AdaptiveListItem(title: 'Sounds'),
    ],
  ),
  AdaptiveListSection(
    header: 'Account',
    footer: 'Signed in as Sarang',
    items: [
      AdaptiveListItem(title: 'Manage subscription', hasNavigation: true),
    ],
  ),
];

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
        'AdaptiveList — ${platform.name}',
        fileName: 'adaptive_list_${platform.name}',
        builder: () => GoldenTestGroup(
          scenarioConstraints: const BoxConstraints(maxWidth: 360, maxHeight: 640),
          children: [
            GoldenTestScenario(
              name: 'light 100%',
              child: wrapForTest(
                const AdaptiveList(sections: _sampleSections, scrollable: false),
              ),
            ),
            GoldenTestScenario(
              name: 'dark 100%',
              child: wrapForTest(
                const AdaptiveList(sections: _sampleSections, scrollable: false),
                brightness: Brightness.dark,
              ),
            ),
            GoldenTestScenario(
              name: 'light 200%',
              child: wrapForTest(
                const AdaptiveList(sections: _sampleSections, scrollable: false),
                textScale: 2,
              ),
            ),
            GoldenTestScenario(
              name: 'dark 200%',
              child: wrapForTest(
                const AdaptiveList(sections: _sampleSections, scrollable: false),
                brightness: Brightness.dark,
                textScale: 2,
              ),
            ),
          ],
        ),
      ));
    });
  }
}
