import 'package:factory_core/factory_core.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wash_quote/data/job_repo.dart';
import 'package:wash_quote/features/money_format.dart';
import 'package:wash_quote/l10n/app_strings.dart';

enum _Period { week, month, all }

class MoneyScreen extends ConsumerStatefulWidget {
  const MoneyScreen({super.key});

  @override
  ConsumerState<MoneyScreen> createState() => _MoneyScreenState();
}

class _MoneyScreenState extends ConsumerState<MoneyScreen> {
  _Period _period = _Period.week;

  @override
  Widget build(BuildContext context) {
    final theme = context.adaptiveTheme;
    final summariesAsync = ref.watch(jobSummariesProvider);
    return AdaptiveScaffold(
      title: const Text(AppStrings.moneyTitle),
      body: summariesAsync.when(
        loading: () => const AdaptiveLoading(),
        error: (_, _) => AdaptiveError(
          message: AppStrings.moneyError,
          onRetry: () => ref.invalidate(jobSummariesProvider),
        ),
        data: (summaries) {
          final filtered = _filter(summaries);
          if (summaries.isEmpty) {
            return const AdaptiveEmpty(
              message: AppStrings.moneyEmpty,
              primaryAction: SizedBox.shrink(),
            );
          }
          final totals = _totals(filtered);
          return ListView(
            padding: EdgeInsets.symmetric(
              horizontal: theme.spacing.lg,
              vertical: theme.spacing.md,
            ),
            children: [
              SizedBox(
                width: double.infinity,
                child: AdaptiveSegmentedControl<_Period>(
                  segments: const [
                    AdaptiveSegment(
                      value: _Period.week,
                      label: AppStrings.moneyPeriodWeek,
                    ),
                    AdaptiveSegment(
                      value: _Period.month,
                      label: AppStrings.moneyPeriodMonth,
                    ),
                    AdaptiveSegment(
                      value: _Period.all,
                      label: AppStrings.moneyPeriodAll,
                    ),
                  ],
                  selectedValue: _period,
                  onChanged: (v) => setState(() => _period = v),
                ),
              ),
              SizedBox(height: theme.spacing.xl),
              _TotalsGrid(totals: totals),
            ],
          );
        },
      ),
    );
  }

  List<JobSummary> _filter(List<JobSummary> all) {
    if (_period == _Period.all) return all;
    final now = DateTime.now();
    final since = _period == _Period.week
        ? now.subtract(const Duration(days: 7))
        : DateTime(now.year, now.month);
    final sinceMs = since.millisecondsSinceEpoch;
    return all.where((s) => s.job.createdAt >= sinceMs).toList();
  }

  _Totals _totals(List<JobSummary> jobs) {
    var quoted = 0;
    var accepted = 0;
    var invoiced = 0;
    var paid = 0;
    for (final s in jobs) {
      final total = s.totalCents;
      final status = JobStatusCode.fromCode(s.job.status);
      switch (status) {
        case JobStatus.quote:
        case JobStatus.sent:
          quoted += total;
        case JobStatus.accepted:
          accepted += total;
          quoted += total;
        case JobStatus.invoiced:
          invoiced += total;
          accepted += total;
          quoted += total;
        case JobStatus.paid:
          paid += total;
          invoiced += total;
          accepted += total;
          quoted += total;
      }
    }
    return _Totals(
      quoted: quoted,
      accepted: accepted,
      invoiced: invoiced,
      paid: paid,
    );
  }
}

class _Totals {
  const _Totals({
    required this.quoted,
    required this.accepted,
    required this.invoiced,
    required this.paid,
  });

  final int quoted;
  final int accepted;
  final int invoiced;
  final int paid;
}

class _TotalsGrid extends StatelessWidget {
  const _TotalsGrid({required this.totals});

  final _Totals totals;

  @override
  Widget build(BuildContext context) {
    final theme = context.adaptiveTheme;
    final tiles = <_TotalTileData>[
      _TotalTileData(AppStrings.moneyQuoted, totals.quoted),
      _TotalTileData(AppStrings.moneyAccepted, totals.accepted),
      _TotalTileData(AppStrings.moneyInvoiced, totals.invoiced),
      _TotalTileData(AppStrings.moneyPaid, totals.paid),
    ];
    return LayoutBuilder(
      builder: (context, constraints) {
        // 2×2 on wide-enough phones/iPads; falls back to 1×4 on very
        // narrow widths or when large text pushes each tile past ~half
        // the available width.
        final gap = theme.spacing.md;
        final fullWidth = constraints.maxWidth;
        // Give each tile enough room for the large price to avoid clipping
        // at 200% text scaling. 220pt fits `$99,999.99` at scale 1; at 2×
        // the number is ~180pt, which fits within a ~220pt tile plus
        // wrap-when-needed. If half-width dips below 200 we go single-col.
        final tileWidth = fullWidth >= 440
            ? (fullWidth - gap) / 2
            : fullWidth;
        return Wrap(
          spacing: gap,
          runSpacing: gap,
          children: [
            for (final t in tiles)
              SizedBox(
                width: tileWidth,
                child: _TotalTile(label: t.label, cents: t.cents),
              ),
          ],
        );
      },
    );
  }
}

class _TotalTileData {
  const _TotalTileData(this.label, this.cents);
  final String label;
  final int cents;
}

class _TotalTile extends StatelessWidget {
  const _TotalTile({required this.label, required this.cents});

  final String label;
  final int cents;

  @override
  Widget build(BuildContext context) {
    final theme = context.adaptiveTheme;
    return Padding(
      padding: EdgeInsets.symmetric(vertical: theme.spacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(fontSize: 13, color: Color(0xFF666666)),
          ),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(
              Money.formatCents(cents),
              maxLines: 1,
              style: TextStyle(
                fontSize: 44,
                fontWeight: FontWeight.w700,
                color: theme.accent,
                fontFeatures: const [FontFeature.tabularFigures()],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
