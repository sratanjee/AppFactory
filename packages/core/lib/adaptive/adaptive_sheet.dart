import 'package:factory_core/adaptive/platform.dart';
import 'package:flutter/cupertino.dart' show CupertinoSheetRoute;
import 'package:flutter/material.dart' show showModalBottomSheet;
import 'package:flutter/widgets.dart';

enum SheetDetent { small, medium, large, full }

class AdaptiveSheet {
  AdaptiveSheet._();

  static Future<T?> show<T>(
    BuildContext context, {
    required Widget child,
    List<SheetDetent> detents = const [SheetDetent.medium, SheetDetent.large],
    bool dismissible = true,
  }) {
    if (AdaptivePlatform.isIOS) {
      return Navigator.of(context).push<T>(
        CupertinoSheetRoute<T>(scrollableBuilder: (_, _) => child),
      );
    }
    return showModalBottomSheet<T>(
      context: context,
      isDismissible: dismissible,
      isScrollControlled: detents.contains(SheetDetent.large) ||
          detents.contains(SheetDetent.full),
      builder: (_) => child,
    );
  }
}
