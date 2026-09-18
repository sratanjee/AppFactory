import 'package:factory_core/factory_core.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wash_quote/l10n/app_strings.dart';
import 'package:wash_quote/screens/jobs_screen.dart';
import 'package:wash_quote/screens/money_screen.dart';
import 'package:wash_quote/screens/services_screen.dart';

/// Persistent four-tab shell. Each tab's own `AdaptiveScaffold` renders
/// its large title and content; the shell renders the tab bar once at the
/// bottom and swaps the tab's page body in/out. Using IndexedStack means
/// scroll position and half-typed input survive tab switches.
class AppShell extends ConsumerStatefulWidget {
  const AppShell({super.key});

  @override
  ConsumerState<AppShell> createState() => _AppShellState();
}

class _AppShellState extends ConsumerState<AppShell> {
  int _index = 0;

  static const _destinations = [
    AdaptiveTabDestination(
      icon: AdaptiveIconName.home,
      selectedIcon: AdaptiveIconName.home,
      label: AppStrings.tabJobs,
    ),
    AdaptiveTabDestination(
      icon: AdaptiveIconName.person,
      selectedIcon: AdaptiveIconName.person,
      label: AppStrings.tabCustomers,
    ),
    AdaptiveTabDestination(
      icon: AdaptiveIconName.pencil,
      selectedIcon: AdaptiveIconName.pencil,
      label: AppStrings.tabServices,
    ),
    AdaptiveTabDestination(
      icon: AdaptiveIconName.clock,
      selectedIcon: AdaptiveIconName.clock,
      label: AppStrings.tabMoney,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final tabBar = AdaptiveTabBar(
      destinations: _destinations,
      currentIndex: _index,
      onDestinationSelected: (i) => setState(() => _index = i),
    );

    // Each tab child owns its scaffold, so we compose the tab bar via a
    // bottom-aligned Row here — this keeps each screen's own primary
    // action working inside its own AdaptiveScaffold.
    return Column(
      children: [
        Expanded(
          child: IndexedStack(
            index: _index,
            children: const [
              JobsScreen(mode: JobsMode.all),
              JobsScreen(mode: JobsMode.byCustomer),
              ServicesScreen(),
              MoneyScreen(),
            ],
          ),
        ),
        tabBar,
      ],
    );
  }
}
