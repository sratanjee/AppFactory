import 'package:factory_core/adaptive/platform.dart';
import 'package:flutter/cupertino.dart' show CupertinoPageRoute;
import 'package:flutter/material.dart' show MaterialPageRoute;
import 'package:flutter/widgets.dart';

class AdaptivePage<T> extends Page<T> {
  const AdaptivePage({
    required this.child,
    super.key,
    super.name,
    super.arguments,
    super.restorationId,
  });

  final Widget child;

  @override
  Route<T> createRoute(BuildContext context) {
    if (AdaptivePlatform.isIOS) {
      return CupertinoPageRoute<T>(
        settings: this,
        builder: (_) => child,
      );
    }
    return MaterialPageRoute<T>(
      settings: this,
      builder: (_) => child,
    );
  }
}
