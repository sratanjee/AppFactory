import 'package:factory_core/factory_core.dart';
import 'package:flutter/foundation.dart' show kDebugMode;
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:wash_quote/data/app_database.dart';
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
    final shell = Column(
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

    // Debug-only reset pill. Reviewer round-1 blocker 4: without this,
    // `hasSeenOnboarding` sticks across `flutter run` re-installs (Android
    // keeps app data for the same signing key) and there's no way to
    // replay onboarding without an out-of-band uninstall.
    if (!kDebugMode) return shell;
    return Stack(
      children: [
        Positioned.fill(child: shell),
        Positioned(
          top: 4,
          right: 12,
          child: SafeArea(child: _DebugResetPill(onTap: _resetAppData)),
        ),
      ],
    );
  }

  Future<void> _resetAppData() async {
    final kv = await ref.read(keyValueStoreProvider.future);
    final db = ref.read(appDatabaseProvider);
    await resetAppData(keyValueStore: kv, database: db);
    if (!mounted) return;
    // Send the user back to /boot so the standard onboarding gate re-runs.
    context.go('/boot');
  }
}

class _DebugResetPill extends StatelessWidget {
  const _DebugResetPill({required this.onTap});

  final Future<void> Function() onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          color: const Color(0xCC000000),
          borderRadius: BorderRadius.circular(999),
        ),
        child: const Text(
          'Reset (debug)',
          style: TextStyle(
            color: Color(0xFFFFFFFF),
            fontSize: 11,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}
