import 'package:factory_core/adaptive/adaptive_button.dart';
import 'package:factory_core/adaptive/adaptive_icon.dart';
import 'package:factory_core/adaptive/platform.dart';
import 'package:factory_core/adaptive/theme.dart';
import 'package:factory_core/l10n/l10n.dart';
import 'package:flutter/cupertino.dart'
    show
        CupertinoActionSheet,
        CupertinoActionSheetAction,
        CupertinoDatePicker,
        CupertinoDatePickerMode,
        showCupertinoModalPopup;
import 'package:flutter/material.dart'
    show
        DropdownButton,
        DropdownMenuItem,
        TimeOfDay,
        showDatePicker,
        showTimePicker;
import 'package:flutter/widgets.dart';

Future<(int, int)?> _showMaterialTimePicker(
  BuildContext context, {
  required int initialHour,
  required int initialMinute,
}) async {
  final picked = await showTimePicker(
    context: context,
    initialTime: TimeOfDay(hour: initialHour, minute: initialMinute),
  );
  if (picked == null) return null;
  return (picked.hour, picked.minute);
}

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
    this.cancelLabel,
    super.key,
  });

  /// Platform-adaptive date picker. Returns the selected `DateTime` or
  /// `null` when the user cancels. Renders a wheel-picker + Done button
  /// on iOS (sheet), and Material's `showDatePicker` on Android.
  static Future<DateTime?> pickDate(
    BuildContext context, {
    required DateTime initialDate,
    required DateTime firstDate,
    required DateTime lastDate,
  }) async {
    if (AdaptivePlatform.isIOS) {
      var picked = initialDate;
      final result = await showCupertinoModalPopup<DateTime>(
        context: context,
        builder: (ctx) => Container(
          height: 260,
          color: const Color(0xFFFFFFFF),
          child: Column(
            children: [
              SizedBox(
                height: 44,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    AdaptiveTextButton(
                      label: 'Done',
                      onPressed: () => Navigator.of(ctx).pop(picked),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: CupertinoDatePicker(
                  mode: CupertinoDatePickerMode.date,
                  initialDateTime: initialDate,
                  minimumDate: firstDate,
                  maximumDate: lastDate,
                  onDateTimeChanged: (v) => picked = v,
                ),
              ),
            ],
          ),
        ),
      );
      return result;
    }
    return await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: firstDate,
      lastDate: lastDate,
    );
  }

  /// Platform-adaptive time picker. Returns the selected `TimeOfDay`
  /// or `null` when the user cancels.
  static Future<(int hour, int minute)?> pickTime(
    BuildContext context, {
    required int initialHour,
    required int initialMinute,
  }) async {
    if (AdaptivePlatform.isIOS) {
      var pickedHour = initialHour;
      var pickedMinute = initialMinute;
      final result = await showCupertinoModalPopup<(int, int)>(
        context: context,
        builder: (ctx) => Container(
          height: 260,
          color: const Color(0xFFFFFFFF),
          child: Column(
            children: [
              SizedBox(
                height: 44,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    AdaptiveTextButton(
                      label: 'Done',
                      onPressed: () => Navigator.of(ctx)
                          .pop((pickedHour, pickedMinute)),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: CupertinoDatePicker(
                  mode: CupertinoDatePickerMode.time,
                  initialDateTime: DateTime(
                    2026,
                    1,
                    1,
                    initialHour,
                    initialMinute,
                  ),
                  onDateTimeChanged: (v) {
                    pickedHour = v.hour;
                    pickedMinute = v.minute;
                  },
                ),
              ),
            ],
          ),
        ),
      );
      return result;
    }
    final result = await _showMaterialTimePicker(
      context,
      initialHour: initialHour,
      initialMinute: initialMinute,
    );
    return result;
  }

  final List<AdaptivePickerItem<T>> items;
  final T selectedValue;
  final ValueChanged<T> onSelected;

  /// Overrides the default cancel label (`FactoryLocalizations.buttonCancel`,
  /// or a hardcoded English fallback when no `Localizations` ancestor exists).
  final String? cancelLabel;

  @override
  Widget build(BuildContext context) {
    final theme = context.adaptiveTheme;
    final resolvedCancelLabel =
        cancelLabel ?? context.maybeL10n?.buttonCancel ?? 'Cancel';
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
                child: Text(resolvedCancelLabel),
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
