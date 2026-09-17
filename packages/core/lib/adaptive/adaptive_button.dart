import 'package:factory_core/adaptive/haptics.dart';
import 'package:factory_core/adaptive/platform.dart';
import 'package:factory_core/adaptive/theme.dart';
import 'package:flutter/cupertino.dart'
    show CupertinoActivityIndicator, CupertinoButton, CupertinoColors;
import 'package:flutter/material.dart' show FilledButton, TextButton;
import 'package:flutter/widgets.dart';

class AdaptivePrimaryButton extends StatelessWidget {
  const AdaptivePrimaryButton({
    required this.label,
    required this.onPressed,
    this.isLoading = false,
    this.enabled = true,
    super.key,
  });

  final String label;
  final VoidCallback? onPressed;
  final bool isLoading;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    final theme = context.adaptiveTheme;
    final effectiveOnPressed =
        (!enabled || isLoading || onPressed == null)
            ? null
            : () {
                AdaptiveHaptics.light();
                onPressed!();
              };

    if (AdaptivePlatform.isIOS) {
      return SizedBox(
        width: double.infinity,
        height: 50,
        child: CupertinoButton.filled(
          onPressed: effectiveOnPressed,
          padding: EdgeInsets.zero,
          child: isLoading
              ? const CupertinoActivityIndicator(color: CupertinoColors.white)
              : Text(label),
        ),
      );
    }
    return SizedBox(
      width: double.infinity,
      height: 48,
      child: FilledButton(
        onPressed: effectiveOnPressed,
        style: FilledButton.styleFrom(backgroundColor: theme.accent),
        child: isLoading
            ? const CupertinoActivityIndicator()
            : Text(label),
      ),
    );
  }
}

class AdaptiveSecondaryButton extends StatelessWidget {
  const AdaptiveSecondaryButton({
    required this.label,
    required this.onPressed,
    this.enabled = true,
    super.key,
  });

  final String label;
  final VoidCallback? onPressed;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    final effectiveOnPressed = (!enabled || onPressed == null) ? null : onPressed;
    if (AdaptivePlatform.isIOS) {
      return SizedBox(
        width: double.infinity,
        height: 50,
        child: CupertinoButton(
          onPressed: effectiveOnPressed,
          child: Text(label),
        ),
      );
    }
    return SizedBox(
      width: double.infinity,
      height: 48,
      child: TextButton(
        onPressed: effectiveOnPressed,
        child: Text(label),
      ),
    );
  }
}

class AdaptiveTextButton extends StatelessWidget {
  const AdaptiveTextButton({
    required this.label,
    required this.onPressed,
    super.key,
  });

  final String label;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    if (AdaptivePlatform.isIOS) {
      return CupertinoButton(
        onPressed: onPressed,
        padding: EdgeInsets.zero,
        minimumSize: const Size(44, 44),
        child: Text(label),
      );
    }
    return TextButton(onPressed: onPressed, child: Text(label));
  }
}

class AdaptiveDestructiveButton extends StatelessWidget {
  const AdaptiveDestructiveButton({
    required this.label,
    required this.onPressed,
    super.key,
  });

  final String label;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    const destructiveColor = Color(0xFFB3261E);
    if (AdaptivePlatform.isIOS) {
      return CupertinoButton(
        onPressed: onPressed,
        padding: EdgeInsets.zero,
        child: Text(label, style: const TextStyle(color: destructiveColor)),
      );
    }
    return TextButton(
      onPressed: onPressed,
      child: Text(label, style: const TextStyle(color: destructiveColor)),
    );
  }
}
