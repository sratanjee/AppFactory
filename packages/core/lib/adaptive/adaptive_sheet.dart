import 'package:factory_core/adaptive/platform.dart';
import 'package:flutter/cupertino.dart'
    show CupertinoColors, showCupertinoModalPopup;
import 'package:flutter/material.dart' show showModalBottomSheet;
import 'package:flutter/widgets.dart';

enum SheetDetent { small, medium, large, full }

class AdaptiveSheet {
  AdaptiveSheet._();

  /// Bottom sheet for compact action-sheet content (a few buttons).
  ///
  /// iOS: `showCupertinoModalPopup` — the native action-sheet mechanism.
  /// Wraps the child in a bottom-anchored container with safe-area
  /// padding so the buttons never get overlaid by the home indicator
  /// or a bottom tab bar. Don't use for long scrollable content — use
  /// a full route for that.
  static Future<T?> show<T>(
    BuildContext context, {
    required Widget child,
    List<SheetDetent> detents = const [SheetDetent.medium, SheetDetent.large],
    bool dismissible = true,
  }) {
    if (AdaptivePlatform.isIOS) {
      return showCupertinoModalPopup<T>(
        context: context,
        barrierDismissible: dismissible,
        builder: (ctx) => Container(
          decoration: const BoxDecoration(
            color: CupertinoColors.systemBackground,
            borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
          ),
          child: SafeArea(
            top: false,
            child: child,
          ),
        ),
      );
    }
    return showModalBottomSheet<T>(
      context: context,
      isDismissible: dismissible,
      isScrollControlled: detents.contains(SheetDetent.large) ||
          detents.contains(SheetDetent.full),
      builder: (_) => SafeArea(top: false, child: child),
    );
  }
}
