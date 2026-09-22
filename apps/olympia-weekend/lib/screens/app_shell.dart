import 'package:factory_core/adaptive/adaptive.dart';
import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';
import 'package:olympia_weekend/design_tokens.dart';
import 'package:olympia_weekend/l10n/app_strings.dart';
import 'package:olympia_weekend/widgets/olympia_tab_bar.dart';

/// Five-tab shell for Olympia Weekend.
///
/// Wraps the branch child from a [StatefulShellRoute.indexedStack] so
/// each tab keeps its own navigation stack. Uses a hand-rolled tab bar
/// (see [OlympiaTabBar]) instead of `AdaptiveTabBar` because the spec
/// requires the selected item to use `colors.text`, not the accent —
/// Material's `NavigationBar` and Cupertino's default both tint with
/// the theme's primary colour.
class AppShell extends StatelessWidget {
  const AppShell({required this.navigationShell, super.key});

  final StatefulNavigationShell navigationShell;

  @override
  Widget build(BuildContext context) {
    final colors = context.olympiaColors;
    return Container(
      color: colors.background,
      child: AdaptiveScaffold(
        titleDisplay: TitleDisplay.none,
        backgroundColor: colors.background,
        body: navigationShell,
        tabBar: OlympiaTabBar(
          destinations: const [
            OlympiaTabDestination(
              icon: AdaptiveIconName.clock,
              selectedIcon: AdaptiveIconName.clock,
              label: AppStrings.tabNow,
            ),
            OlympiaTabDestination(
              icon: AdaptiveIconName.calendar,
              selectedIcon: AdaptiveIconName.calendar,
              label: AppStrings.tabSchedule,
            ),
            OlympiaTabDestination(
              icon: AdaptiveIconName.person,
              selectedIcon: AdaptiveIconName.person,
              label: AppStrings.tabAthletes,
            ),
            OlympiaTabDestination(
              icon: AdaptiveIconName.info,
              selectedIcon: AdaptiveIconName.info,
              label: AppStrings.tabVenues,
            ),
            OlympiaTabDestination(
              icon: AdaptiveIconName.star,
              selectedIcon: AdaptiveIconName.starFill,
              label: AppStrings.tabSaved,
            ),
          ],
          currentIndex: navigationShell.currentIndex,
          onDestinationSelected: (i) => navigationShell.goBranch(
            i,
            initialLocation: i == navigationShell.currentIndex,
          ),
        ),
      ),
    );
  }
}
