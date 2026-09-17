import 'package:factory_core/adaptive/platform.dart';
import 'package:flutter/cupertino.dart'
    show
        CupertinoActionSheet,
        CupertinoActionSheetAction,
        CupertinoAlertDialog,
        CupertinoDialogAction,
        showCupertinoDialog,
        showCupertinoModalPopup;
import 'package:flutter/material.dart' show AlertDialog, TextButton, showDialog;
import 'package:flutter/widgets.dart';

class AdaptiveDialogAction<T> {
  const AdaptiveDialogAction({
    required this.label,
    required this.value,
    this.isDestructive = false,
    this.isCancel = false,
  });

  final String label;
  final T value;
  final bool isDestructive;
  final bool isCancel;
}

class AdaptiveDialog {
  AdaptiveDialog._();

  static Future<T?> confirm<T>(
    BuildContext context, {
    required String title,
    required List<AdaptiveDialogAction<T>> actions,
    String? message,
  }) {
    if (AdaptivePlatform.isIOS) {
      return _showCupertino(context, title: title, actions: actions, message: message);
    }
    return _showMaterial(context, title: title, actions: actions, message: message);
  }

  static Future<T?> _showCupertino<T>(
    BuildContext context, {
    required String title,
    required List<AdaptiveDialogAction<T>> actions,
    String? message,
  }) {
    if (actions.length >= 3) {
      final nonCancel = actions.where((a) => !a.isCancel).toList();
      final cancelList = actions.where((a) => a.isCancel).toList();
      final cancel = cancelList.isEmpty ? null : cancelList.first;
      return showCupertinoModalPopup<T>(
        context: context,
        builder: (ctx) => CupertinoActionSheet(
          title: Text(title),
          message: message == null ? null : Text(message),
          actions: [
            for (final a in nonCancel)
              CupertinoActionSheetAction(
                onPressed: () => Navigator.of(ctx).pop(a.value),
                isDestructiveAction: a.isDestructive,
                child: Text(a.label),
              ),
          ],
          cancelButton: cancel == null
              ? null
              : CupertinoActionSheetAction(
                  onPressed: () => Navigator.of(ctx).pop(cancel.value),
                  child: Text(cancel.label),
                ),
        ),
      );
    }
    return showCupertinoDialog<T>(
      context: context,
      builder: (ctx) => CupertinoAlertDialog(
        title: Text(title),
        content: message == null ? null : Text(message),
        actions: [
          for (final a in actions)
            CupertinoDialogAction(
              onPressed: () => Navigator.of(ctx).pop(a.value),
              isDestructiveAction: a.isDestructive,
              isDefaultAction: !a.isCancel && !a.isDestructive,
              child: Text(a.label),
            ),
        ],
      ),
    );
  }

  static Future<T?> _showMaterial<T>(
    BuildContext context, {
    required String title,
    required List<AdaptiveDialogAction<T>> actions,
    String? message,
  }) {
    final sorted = [...actions]
      ..sort((x, y) => (x.isDestructive ? 1 : 0) - (y.isDestructive ? 1 : 0));
    return showDialog<T>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(title),
        content: message == null ? null : Text(message),
        actions: [
          for (final a in sorted)
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(a.value),
              child: Text(
                a.label,
                style: a.isDestructive
                    ? const TextStyle(color: Color(0xFFB3261E))
                    : null,
              ),
            ),
        ],
      ),
    );
  }
}
