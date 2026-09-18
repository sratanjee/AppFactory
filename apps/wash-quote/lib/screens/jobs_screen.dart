import 'package:factory_core/factory_core.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wash_quote/l10n/app_strings.dart';

/// Filter used when the shell mounts the Jobs surface.
///
/// * `all` — the Jobs tab itself: renders the hero card, waiting list, and
///   the accepted-this-week list.
/// * `byCustomer` — the Customers tab: same underlying data grouped by
///   customer instead of by segment (spec §3 says Customers is a filtered
///   Jobs view, not its own screen).
enum JobsMode { all, byCustomer }

class JobsScreen extends ConsumerStatefulWidget {
  const JobsScreen({required this.mode, super.key});

  final JobsMode mode;

  @override
  ConsumerState<JobsScreen> createState() => _JobsScreenState();
}

class _JobsScreenState extends ConsumerState<JobsScreen> {
  @override
  Widget build(BuildContext context) {
    return AdaptiveScaffold(
      title: Text(
        widget.mode == JobsMode.byCustomer
            ? AppStrings.tabCustomers
            : AppStrings.jobsTitle,
      ),
      titleDisplay: TitleDisplay.large,
      body: Center(
        child: Text(
          widget.mode == JobsMode.byCustomer
              ? AppStrings.tabCustomers
              : AppStrings.jobsTitle,
        ),
      ),
    );
  }
}
