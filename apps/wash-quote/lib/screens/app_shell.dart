import 'package:factory_core/factory_core.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wash_quote/l10n/app_strings.dart';
import 'package:wash_quote/screens/jobs_screen.dart';
import 'package:wash_quote/screens/money_screen.dart';
import 'package:wash_quote/screens/services_screen.dart';

/// Persistent four-tab shell. Uses `IndexedStack` so each tab keeps its
/// scroll position, providers, and any half-typed input across tab
/// switches.
class AppShell extends ConsumerStatefulWidget {
  const AppShell({super.key});

  @override
  ConsumerState<AppShell> createState() => _AppShellState();
}

class _AppShellState extends ConsumerState<AppShell> {
  int _index = 0;

  static const _tabs = [
    _Tab(
      icon: AdaptiveIconName.home,
      selectedIcon: AdaptiveIconName.home,
      label: AppStrings.tabJobs,
    ),
    _Tab(
      icon: AdaptiveIconName.person,
      selectedIcon: AdaptiveIconName.person,
      label: AppStrings.tabCustomers,
    ),
    _Tab(
      icon: AdaptiveIconName.pencil,
      selectedIcon: AdaptiveIconName.pencil,
      label: AppStrings.tabServices,
    ),
    _Tab(
      icon: AdaptiveIconName.clock,
      selectedIcon: AdaptiveIconName.clock,
      label: AppStrings.tabMoney,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return _ShellScaffold(
      currentIndex: _index,
      onChanged: (i) => setState(() => _index = i),
      destinations: _tabs,
      children: const [
        JobsScreen(mode: JobsMode.all),
        JobsScreen(mode: JobsMode.byCustomer),
        ServicesScreen(),
        MoneyScreen(),
      ],
    );
  }
}

class _Tab extends AdaptiveTabDestination {
  const _Tab({
    required super.icon,
    required super.selectedIcon,
    required super.label,
  });
}

class _ShellScaffold extends StatelessWidget {
  const _ShellScaffold({
    required this.currentIndex,
    required this.onChanged,
    required this.destinations,
    required this.children,
  });

  final int currentIndex;
  final ValueChanged<int> onChanged;
  final List<AdaptiveTabDestination> destinations;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final tabBar = AdaptiveTabBar(
      destinations: destinations,
      currentIndex: currentIndex,
      onDestinationSelected: onChanged,
    );

    return _TabbedRoot(
      tabBar: tabBar,
      body: IndexedStack(index: currentIndex, children: children),
    );
  }
}

/// Wraps the current-tab content and a bottom tab bar. We can't use
/// `AdaptiveScaffold` here because each tab owns its own scaffold (large
/// title, primary action). This is the one place the shell is bare —
/// screens inside build their own `AdaptiveScaffold`.
class _TabbedRoot extends StatelessWidget {
  const _TabbedRoot({required this.body, required this.tabBar});

  final Widget body;
  final Widget tabBar;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(child: body),
        tabBar,
      ],
    );
  }
}
