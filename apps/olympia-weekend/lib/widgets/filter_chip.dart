import 'package:flutter/widgets.dart';
import 'package:olympia_weekend/design_tokens.dart';
import 'package:olympia_weekend/widgets/pressable.dart';

/// Rounded outline chip used for schedule filters, division switchers,
/// and the report-a-sighting sheet's day/time pickers. Single source of
/// truth for pressable state + min tap target across those callers.
class OlympiaFilterChip extends StatelessWidget {
  const OlympiaFilterChip({
    required this.label,
    required this.active,
    required this.onTap,
    super.key,
  });

  final String label;
  final bool active;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.olympiaColors;
    return OlympiaPressable(
      onTap: onTap,
      semanticsLabel: label,
      semanticsSelected: active,
      // 44pt tall — iOS HIG minimum. 12px vertical padding on top of a
      // 13/500 label yields ~44px.
      child: Container(
        alignment: Alignment.center,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: active ? colors.pillActiveBg : colors.surface,
          borderRadius: BorderRadius.circular(999),
          border: Border.all(color: colors.surfaceBorder),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 13,
            fontWeight: active ? FontWeight.w600 : FontWeight.w500,
            color: active ? colors.pillActiveText : colors.text,
          ),
        ),
      ),
    );
  }
}
