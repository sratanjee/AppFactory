import 'dart:async';

import 'package:alchemist/alchemist.dart';
import 'package:factory_core/adaptive/adaptive_states.dart';

Future<void> testExecutable(FutureOr<void> Function() testMain) {
  // Freeze [AdaptiveLoading] so `pumpAndSettle` returns. See
  // packages/core/lib/adaptive/adaptive_states.dart#AdaptiveLoading.testMode.
  AdaptiveLoading.testMode = true;
  return AlchemistConfig.runWithConfig(
    config: const AlchemistConfig(
      platformGoldensConfig: PlatformGoldensConfig(),
      ciGoldensConfig: CiGoldensConfig(),
    ),
    run: () async {
      await testMain();
    },
  );
}
