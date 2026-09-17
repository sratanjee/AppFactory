import 'package:factory_core/adaptive/adaptive_icon.dart';
import 'package:factory_core/adaptive/platform.dart';
import 'package:factory_core/adaptive/theme.dart';
import 'package:flutter/cupertino.dart'
    show
        CupertinoActionSheet,
        CupertinoActionSheetAction,
        showCupertinoModalPopup;
import 'package:flutter/material.dart' show DropdownButton, DropdownMenuItem;
import 'package:flutter/widgets.dart';

class AdaptivePickerItem<T> {
  const AdaptivePickerItem({required this.value, required this.label});

  final T value;
  final String label;
}

class AdaptivePicker<T> extends StatelessWidget {
  const AdaptivePicker({
    required this.items,
    required this.selectedValue,
    required this.onSelected,
    this.cancelLabel = 'Cancel',
    super.key,
  });

  final List<AdaptivePickerItem<T>> items;
  final T selectedValue;
  final ValueChanged<T> onSelected;
  final String cancelLabel;

  @override
  Widget build(BuildContext context) {
    final theme = context.adaptiveTheme;
    if (AdaptivePlatform.isIOS) {
      final selected = items.firstWhere(
        (i) => i.value == selectedValue,
        orElse: () => items.first,
      );
      return GestureDetector(
        onTap: () async {
          final result = await showCupertinoModalPopup<T>(
            context: context,
            builder: (ctx) => CupertinoActionSheet(
              actions: [
                for (final i in items)
                  CupertinoActionSheetAction(
                    onPressed: () => Navigator.of(ctx).pop(i.value),
                    child: Text(i.label),
                  ),
              ],
              cancelButton: CupertinoActionSheetAction(
                onPressed: Navigator.of(ctx).pop,
                child: Text(cancelLabel),
              ),
            ),
          );
          if (result != null) onSelected(result);
        },
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(selected.label, style: TextStyle(color: theme.accent)),
            SizedBox(width: theme.spacing.xs),
            AdaptiveIcon(
              AdaptiveIconName.chevronDown,
              size: 14,
              color: theme.accent,
            ),
          ],
        ),
      );
    }
    return DropdownButton<T>(
      value: selectedValue,
      items: [
        for (final i in items)
          DropdownMenuItem<T>(value: i.value, child: Text(i.label)),
      ],
      onChanged: (v) {
        if (v != null) onSelected(v);
      },
    );
  }
}
