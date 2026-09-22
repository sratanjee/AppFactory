import 'package:factory_core/adaptive/adaptive.dart';
import 'package:flutter/widgets.dart';
import 'package:olympia_weekend/design_tokens.dart';
import 'package:olympia_weekend/l10n/app_strings.dart';

class ScheduleScreen extends StatelessWidget {
  const ScheduleScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = context.olympiaColors;
    return AdaptiveScaffold(
      backgroundColor: colors.background,
      titleDisplay: TitleDisplay.none,
      body: Container(
        color: colors.background,
        child: SafeArea(
          child: Center(
            child: Text(
              AppStrings.tabSchedule,
              style: TextStyle(color: colors.text),
            ),
          ),
        ),
      ),
    );
  }
}
