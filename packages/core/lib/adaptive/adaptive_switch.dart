import 'package:factory_core/adaptive/platform.dart';
import 'package:factory_core/adaptive/theme.dart';
import 'package:flutter/cupertino.dart' show CupertinoSwitch;
import 'package:flutter/material.dart' show Switch;
import 'package:flutter/widgets.dart';

class AdaptiveSwitch extends StatelessWidget {
  const AdaptiveSwitch({
    required this.value,
    required this.onChanged,
    super.key,
  });

  final bool value;
  final ValueChanged<bool>? onChanged;

  @override
  Widget build(BuildContext context) {
    final theme = context.adaptiveTheme;
    if (AdaptivePlatform.isIOS) {
      return CupertinoSwitch(
        value: value,
        onChanged: onChanged,
        activeTrackColor: theme.accent,
      );
    }
    return Switch(
      value: value,
      onChanged: onChanged,
      activeThumbColor: theme.accent,
    );
  }
}
