import 'package:flutter/widgets.dart';
import 'package:olympia_weekend/design_tokens.dart';
import 'package:olympia_weekend/l10n/app_strings.dart';
import 'package:olympia_weekend/widgets/pressable.dart';

/// Wed…Sun day pills. `dates` maps 1-to-1 to [AppStrings.dayShort].
class DayPills extends StatelessWidget {
  const DayPills({
    required this.dates,
    required this.selected,
    required this.onSelected,
    required this.activeColor,
    this.activeTextColor,
    super.key,
  });

  final List<String> dates;
  final String selected;
  final ValueChanged<String> onSelected;
  final Color activeColor;
  final Color? activeTextColor;

  @override
  Widget build(BuildContext context) {
    final colors = context.olympiaColors;
    return Row(
      children: [
        for (var i = 0; i < AppStrings.dayShort.length; i++) ...[
          Expanded(
            child: _DayPill(
              label: AppStrings.dayShort[i],
              accessLabel: AppStrings.dayLong[i],
              active: i < dates.length && dates[i] == selected,
              onTap: () {
                if (i < dates.length) onSelected(dates[i]);
              },
              colors: colors,
              activeColor: activeColor,
              activeTextColor: activeTextColor,
            ),
          ),
          if (i != AppStrings.dayShort.length - 1) const SizedBox(width: 6),
        ],
      ],
    );
  }
}

class _DayPill extends StatelessWidget {
  const _DayPill({
    required this.label,
    required this.accessLabel,
    required this.active,
    required this.onTap,
    required this.colors,
    required this.activeColor,
    required this.activeTextColor,
  });

  final String label;
  final String accessLabel;
  final bool active;
  final VoidCallback onTap;
  final OlympiaColors colors;
  final Color activeColor;
  final Color? activeTextColor;

  @override
  Widget build(BuildContext context) {
    return OlympiaPressable(
      onTap: onTap,
      semanticsLabel: accessLabel,
      semanticsSelected: active,
      // 44pt tall — iOS HIG minimum. 12px vertical padding on top of a
      // 17px line-height gets us to ~41px which was under the bar; now
      // 14px lands the pill at ~45px. Also gives the tap a real target
      // instead of a tight hairline row.
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: active ? activeColor : null,
          borderRadius: BorderRadius.circular(10),
        ),
        alignment: Alignment.center,
        child: Text(
          label,
          style: context.olympiaText.pill(active: active).copyWith(
                color: active
                    ? (activeTextColor ?? colors.pillActiveText)
                    : colors.textMuted,
              ),
        ),
      ),
    );
  }
}
