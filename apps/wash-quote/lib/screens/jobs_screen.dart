import 'dart:async';
import 'dart:io' show File;

import 'package:factory_core/factory_core.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:wash_quote/data/job_repo.dart';
import 'package:wash_quote/features/money_format.dart';
import 'package:wash_quote/features/paywall_gate.dart';
import 'package:wash_quote/l10n/app_strings.dart';

enum JobsMode { all, byCustomer }

enum _Segment { quotes, invoices }

class JobsScreen extends ConsumerStatefulWidget {
  const JobsScreen({required this.mode, super.key});

  final JobsMode mode;

  @override
  ConsumerState<JobsScreen> createState() => _JobsScreenState();
}

class _JobsScreenState extends ConsumerState<JobsScreen> {
  _Segment _segment = _Segment.quotes;

  @override
  Widget build(BuildContext context) {
    final summariesAsync = ref.watch(jobSummariesProvider);
    final theme = context.adaptiveTheme;
    final isCustomers = widget.mode == JobsMode.byCustomer;

    return AdaptiveScaffold(
      title: Text(isCustomers ? AppStrings.tabCustomers : AppStrings.jobsTitle),
      body: summariesAsync.when(
        loading: () => const AdaptiveLoading(),
        error: (_, _) => AdaptiveError(
          message: AppStrings.jobsErrorRead,
          onRetry: () => ref.invalidate(jobSummariesProvider),
        ),
        data: (summaries) {
          final filtered = _filter(summaries);
          return ListView(
            padding: EdgeInsets.symmetric(horizontal: theme.spacing.lg),
            children: [
              SizedBox(height: theme.spacing.sm),
              _SegmentToggle(
                value: _segment,
                onChanged: (v) => setState(() => _segment = v),
              ),
              SizedBox(height: theme.spacing.lg),
              _HeroCard(onTap: () => _openBuilder(context)),
              SizedBox(height: theme.spacing.xl),
              if (filtered.isEmpty)
                const _EmptyLine(text: AppStrings.jobsEmptyHint)
              else ...[
                if (isCustomers)
                  _ByCustomerList(summaries: filtered)
                else ...[
                  _WaitingRow(summaries: _waiting(filtered)),
                  SizedBox(height: theme.spacing.xl),
                  _AcceptedList(summaries: _accepted(filtered)),
                ],
              ],
              SizedBox(height: theme.spacing.xxl),
            ],
          );
        },
      ),
    );
  }

  List<JobSummary> _filter(List<JobSummary> all) {
    final quotes = <JobSummary>[];
    final invoices = <JobSummary>[];
    for (final s in all) {
      final code = s.job.status;
      if (code == JobStatus.invoiced.code || code == JobStatus.paid.code) {
        invoices.add(s);
      } else {
        quotes.add(s);
      }
    }
    return _segment == _Segment.quotes ? quotes : invoices;
  }

  List<JobSummary> _waiting(List<JobSummary> quotes) {
    return quotes.where((s) => s.job.status == JobStatus.sent.code).toList();
  }

  List<JobSummary> _accepted(List<JobSummary> quotes) {
    final weekAgo =
        DateTime.now().subtract(const Duration(days: 7)).millisecondsSinceEpoch;
    return quotes
        .where((s) =>
            s.job.status == JobStatus.accepted.code &&
            (s.job.acceptedAt ?? s.job.createdAt) >= weekAgo)
        .toList();
  }

  Future<void> _openBuilder(BuildContext context) async {
    final ok = await ensureProEntitlement(
      context,
      ref,
      placement: 'first_save',
    );
    if (!ok) return;
    if (!context.mounted) return;
    await context.push<void>('/quote/new');
  }
}

class _SegmentToggle extends StatelessWidget {
  const _SegmentToggle({required this.value, required this.onChanged});

  final _Segment value;
  final ValueChanged<_Segment> onChanged;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: AdaptiveSegmentedControl<_Segment>(
        segments: const [
          AdaptiveSegment(
              value: _Segment.quotes, label: AppStrings.jobsSegmentQuotes),
          AdaptiveSegment(
              value: _Segment.invoices, label: AppStrings.jobsSegmentInvoices),
        ],
        selectedValue: value,
        onChanged: onChanged,
      ),
    );
  }
}

class _HeroCard extends StatelessWidget {
  const _HeroCard({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = context.adaptiveTheme;
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Container(
        height: 168,
        padding: EdgeInsets.all(theme.spacing.lg),
        decoration: BoxDecoration(
          color: theme.accent,
          borderRadius: BorderRadius.circular(22),
        ),
        child: Row(
          children: [
            Container(
              width: 56,
              height: 56,
              alignment: Alignment.center,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: Color(0x33FFFFFF),
              ),
              child: const AdaptiveIcon(
                AdaptiveIconName.cameraSymbol,
                color: Color(0xFFFFFFFF),
                size: 28,
              ),
            ),
            SizedBox(width: theme.spacing.lg),
            const Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    AppStrings.jobsHeroHeadline,
                    style: TextStyle(
                      color: Color(0xFFFFFFFF),
                      fontSize: 22,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(height: 6),
                  Text(
                    AppStrings.jobsHeroSubline,
                    style: TextStyle(
                      color: Color(0xE6FFFFFF),
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyLine extends StatelessWidget {
  const _EmptyLine({required this.text});
  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Text(text, style: const TextStyle(color: Color(0xFF666666))),
    );
  }
}

class _WaitingRow extends StatelessWidget {
  const _WaitingRow({required this.summaries});

  final List<JobSummary> summaries;

  @override
  Widget build(BuildContext context) {
    if (summaries.isEmpty) return const SizedBox.shrink();
    final total = summaries.fold<int>(0, (a, s) => a + s.totalCents);
    final header =
        '${AppStrings.jobsWaitingHeader} · ${summaries.length} · ${Money.formatCents(total)}';
    final theme = context.adaptiveTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(header,
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
        SizedBox(height: theme.spacing.md),
        SizedBox(
          height: 168,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: summaries.length,
            separatorBuilder: (_, _) => SizedBox(width: theme.spacing.md),
            itemBuilder: (context, i) => _QuoteThumbCard(summary: summaries[i]),
          ),
        ),
      ],
    );
  }
}

class _QuoteThumbCard extends StatelessWidget {
  const _QuoteThumbCard({required this.summary});

  final JobSummary summary;

  @override
  Widget build(BuildContext context) {
    final theme = context.adaptiveTheme;
    final photo = summary.beforePhotoPath;
    final name = summary.customer?.name ?? AppStrings.builderNoCustomer;
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => _openDetail(context, summary.job.id),
      child: SizedBox(
        width: 150,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(theme.cornerRadius.md),
              child: Container(
                height: 100,
                color: const Color(0xFFEDEDF2),
                child: photo == null
                    ? const Center(
                        child: AdaptiveIcon(
                          AdaptiveIconName.photo,
                          color: Color(0xFFA0A0A0),
                        ),
                      )
                    : Image.file(File(photo), fit: BoxFit.cover),
              ),
            ),
            SizedBox(height: theme.spacing.sm),
            Text(name, style: const TextStyle(fontSize: 14)),
            Text(
              Money.formatCents(summary.totalCents),
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
            ),
            _StatusPill(status: JobStatusCode.fromCode(summary.job.status)),
          ],
        ),
      ),
    );
  }
}

class _StatusPill extends StatelessWidget {
  const _StatusPill({required this.status});
  final JobStatus status;

  @override
  Widget build(BuildContext context) {
    final theme = context.adaptiveTheme;
    return Container(
      margin: const EdgeInsets.only(top: 4),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: theme.accent.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        _statusLabel(status),
        style: TextStyle(fontSize: 11, color: theme.accent),
      ),
    );
  }
}

class _AcceptedList extends StatelessWidget {
  const _AcceptedList({required this.summaries});
  final List<JobSummary> summaries;

  @override
  Widget build(BuildContext context) {
    if (summaries.isEmpty) return const SizedBox.shrink();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          AppStrings.jobsAcceptedHeader,
          style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: 8),
        for (final s in summaries) _AcceptedRow(summary: s),
      ],
    );
  }
}

class _AcceptedRow extends StatelessWidget {
  const _AcceptedRow({required this.summary});
  final JobSummary summary;

  @override
  Widget build(BuildContext context) {
    final theme = context.adaptiveTheme;
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => _openDetail(context, summary.job.id),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Row(
          children: [
            Container(
              width: 8,
              height: 8,
              decoration:
                  BoxDecoration(color: theme.accent, shape: BoxShape.circle),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                summary.customer?.name ?? AppStrings.builderNoCustomer,
                style: const TextStyle(fontSize: 16),
              ),
            ),
            Text(
              Money.formatCents(summary.totalCents),
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                fontFeatures: [FontFeature.tabularFigures()],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ByCustomerList extends StatelessWidget {
  const _ByCustomerList({required this.summaries});
  final List<JobSummary> summaries;

  @override
  Widget build(BuildContext context) {
    final groups = <String, List<JobSummary>>{};
    for (final s in summaries) {
      final name = s.customer?.name ?? AppStrings.builderNoCustomer;
      groups.putIfAbsent(name, () => []).add(s);
    }
    final names = groups.keys.toList()..sort();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (final name in names) ...[
          Padding(
            padding: const EdgeInsets.only(top: 12, bottom: 4),
            child: Text(
              name,
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
            ),
          ),
          for (final s in groups[name]!) _AcceptedRow(summary: s),
        ],
      ],
    );
  }
}

void _openDetail(BuildContext context, int jobId) {
  unawaited(context.push<void>('/job/$jobId'));
}

String _statusLabel(JobStatus status) {
  switch (status) {
    case JobStatus.quote:
      return AppStrings.jobsStatusQuote;
    case JobStatus.sent:
      return AppStrings.jobsStatusSent;
    case JobStatus.accepted:
      return AppStrings.jobsStatusAccepted;
    case JobStatus.invoiced:
      return AppStrings.jobsStatusInvoiced;
    case JobStatus.paid:
      return AppStrings.jobsStatusPaid;
  }
}
