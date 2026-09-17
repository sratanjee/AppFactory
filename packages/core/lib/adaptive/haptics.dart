import 'dart:async';

import 'package:factory_core/adaptive/platform.dart';
import 'package:flutter/services.dart';

class AdaptiveHaptics {
  AdaptiveHaptics._();

  static void selection() {
    unawaited(HapticFeedback.selectionClick());
  }

  static void light() {
    unawaited(HapticFeedback.lightImpact());
  }

  static void medium() {
    // Android convention is lighter and rarer than iOS.
    if (AdaptivePlatform.isAndroid) {
      unawaited(HapticFeedback.selectionClick());
      return;
    }
    unawaited(HapticFeedback.mediumImpact());
  }

  static void heavy() {
    unawaited(HapticFeedback.heavyImpact());
  }

  static void success() {
    unawaited(HapticFeedback.mediumImpact());
  }

  static void warning() {
    unawaited(HapticFeedback.heavyImpact());
  }

  static void error() {
    unawaited(HapticFeedback.heavyImpact());
  }
}
