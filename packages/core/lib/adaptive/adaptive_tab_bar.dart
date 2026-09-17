import 'package:factory_core/adaptive/adaptive_icon.dart';
import 'package:factory_core/adaptive/platform.dart';
import 'package:flutter/cupertino.dart'
    show BottomNavigationBarItem, CupertinoTabBar;
import 'package:flutter/material.dart'
    show NavigationBar, NavigationDestination;
import 'package:flutter/widgets.dart';

class AdaptiveTabDestination {
  const AdaptiveTabDestination({
    required this.icon,
    required this.selectedIcon,
    required this.label,
    this.badgeCount,
  });

  final AdaptiveIconName icon;
  final AdaptiveIconName selectedIcon;
  final String label;
  final int? badgeCount;
}

class AdaptiveTabBar extends StatelessWidget {
  const AdaptiveTabBar({
    required this.destinations,
    required this.currentIndex,
    required this.onDestinationSelected,
    this.hasSearchTab = false,
    super.key,
  });

  final List<AdaptiveTabDestination> destinations;
  final int currentIndex;
  final ValueChanged<int> onDestinationSelected;
  final bool hasSearchTab;

  @override
  Widget build(BuildContext context) {
    assert(
      destinations.length >= 2 && destinations.length <= 5,
      'AdaptiveTabBar supports 2 to 5 destinations',
    );
    if (AdaptivePlatform.isIOS) {
      return CupertinoTabBar(
        currentIndex: currentIndex,
        onTap: onDestinationSelected,
        items: [
          for (final d in destinations)
            BottomNavigationBarItem(
              icon: AdaptiveIcon(d.icon, size: 26),
              activeIcon: AdaptiveIcon(d.selectedIcon, size: 26),
              label: d.label,
            ),
        ],
      );
    }
    return NavigationBar(
      selectedIndex: currentIndex,
      onDestinationSelected: onDestinationSelected,
      destinations: [
        for (final d in destinations)
          NavigationDestination(
            icon: AdaptiveIcon(d.icon),
            selectedIcon: AdaptiveIcon(d.selectedIcon),
            label: d.label,
          ),
      ],
    );
  }
}
