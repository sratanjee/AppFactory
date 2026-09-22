import 'package:factory_core/adaptive/adaptive.dart';
import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';
import 'package:olympia_weekend/design_tokens.dart';
import 'package:olympia_weekend/l10n/app_strings.dart';

/// Five-tab shell for Olympia Weekend.
///
/// Wraps the branch child from a [StatefulShellRoute.indexedStack] so
/// each tab keeps its own navigation stack. Uses [AdaptiveTabBar] so iOS
/// gets a Cupertino tab bar and Android gets a Material navigation bar.
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
        tabBar: AdaptiveTabBar(
          destinations: const [
            AdaptiveTabDestination(
              icon: AdaptiveIconName.clock,
              selectedIcon: AdaptiveIconName.clock,
              label: AppStrings.tabNow,
            ),
            AdaptiveTabDestination(
              icon: AdaptiveIconName.calendar,
              selectedIcon: AdaptiveIconName.calendar,
              label: AppStrings.tabSchedule,
            ),
            AdaptiveTabDestination(
              icon: AdaptiveIconName.person,
              selectedIcon: AdaptiveIconName.person,
              label: AppStrings.tabAthletes,
            ),
            AdaptiveTabDestination(
              icon: AdaptiveIconName.info,
              selectedIcon: AdaptiveIconName.info,
              label: AppStrings.tabVenues,
            ),
            AdaptiveTabDestination(
              icon: AdaptiveIconName.star,
              selectedIcon: AdaptiveIconName.starFill,
              label: AppStrings.tabSaved,
            ),
          ],
          currentIndex: navigationShell.currentIndex,
          onDestinationSelected: (i) =>
              navigationShell.goBranch(i, initialLocation: i == navigationShell.currentIndex),
        ),
      ),
    );
  }
}
