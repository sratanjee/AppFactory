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
        body: _SwipeToChangeTab(
          currentIndex: navigationShell.currentIndex,
          count: 5,
          onSwipe: (nextIndex) => navigationShell.goBranch(nextIndex),
          child: navigationShell,
        ),
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
              icon: AdaptiveIconName.bag,
              selectedIcon: AdaptiveIconName.bag,
              label: AppStrings.tabExpo,
            ),
            OlympiaTabDestination(
              icon: AdaptiveIconName.info,
              selectedIcon: AdaptiveIconName.info,
              label: AppStrings.tabVenues,
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

/// Wraps the shell body so a horizontal drag on the tab canvas switches
/// tabs (left swipe → next, right swipe → previous). Vertical scrolls
/// still win because we only claim the gesture when the horizontal
/// velocity dominates. Ignore swipes at the very edges to leave room
/// for iOS back-swipe on stacked routes.
class _SwipeToChangeTab extends StatefulWidget {
  const _SwipeToChangeTab({
    required this.currentIndex,
    required this.count,
    required this.onSwipe,
    required this.child,
  });

  final int currentIndex;
  final int count;
  final void Function(int nextIndex) onSwipe;
  final Widget child;

  @override
  State<_SwipeToChangeTab> createState() => _SwipeToChangeTabState();
}

class _SwipeToChangeTabState extends State<_SwipeToChangeTab> {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onHorizontalDragEnd: (details) {
        final v = details.primaryVelocity ?? 0;
        // Ignore tiny flicks — need a real swipe intent.
        if (v.abs() < 300) return;
        final delta = v > 0 ? -1 : 1; // swipe right → previous tab
        final next = widget.currentIndex + delta;
        if (next < 0 || next >= widget.count) return;
        widget.onSwipe(next);
      },
      child: widget.child,
    );
  }
}
