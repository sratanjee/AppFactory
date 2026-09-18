import 'dart:async';
import 'dart:io' show File;

import 'package:factory_core/factory_core.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:wash_quote/data/app_database.dart';
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
      titleDisplay: TitleDisplay.none,
      body: summariesAsync.when(
        loading: () => const AdaptiveLoading(),
        error: (_, _) => AdaptiveError(
          message: AppStrings.jobsErrorRead,
          onRetry: () => ref.invalidate(jobSummariesProvider),
        ),
        data: (summaries) {
          final filtered = _filter(summaries);
          return ListView(
            padding: EdgeInsets.zero,
            children: [
              SafeArea(
                bottom: false,
                child: Padding(
                  padding: EdgeInsets.fromLTRB(
                    theme.spacing.lg,
                    theme.spacing.sm,
                    theme.spacing.lg,
                    0,
                  ),
                  child: _Header(
                    title: isCustomers
                        ? AppStrings.tabCustomers
                        : AppStrings.jobsTitle,
                    segment: isCustomers ? null : _segment,
                    onSegmentChanged: isCustomers
                        ? null
                        : (v) => setState(() => _segment = v),
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.fromLTRB(
                  theme.spacing.lg,
                  18,
                  theme.spacing.lg,
                  0,
                ),
                child: _HeroCard(onTap: () => _openBuilder(context)),
              ),
              if (filtered.isEmpty)
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: theme.spacing.lg),
                  child: const _EmptyLine(text: AppStrings.jobsEmptyHint),
                )
              else if (isCustomers)
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: theme.spacing.lg),
                  child: _ByCustomerList(summaries: filtered),
                )
              else ...[
                _WaitingRow(summaries: _waiting(filtered)),
                _AcceptedList(summaries: _accepted(filtered)),
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

class _Header extends StatelessWidget {
  const _Header({
    required this.title,
    required this.segment,
    required this.onSegmentChanged,
  });

  final String title;
  final _Segment? segment;
  final ValueChanged<_Segment>? onSegmentChanged;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.w700,
            letterSpacing: -0.3,
          ),
        ),
        const Spacer(),
        if (segment != null && onSegmentChanged != null)
          _InlineSegmented(
            value: segment!,
            onChanged: onSegmentChanged!,
          ),
      ],
    );
  }
}

class _InlineSegmented extends StatelessWidget {
  const _InlineSegmented({required this.value, required this.onChanged});

  final _Segment value;
  final ValueChanged<_Segment> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(2),
      decoration: BoxDecoration(
        color: const Color(0xFFF2F2F7),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _pill(_Segment.quotes, AppStrings.jobsSegmentQuotes),
          _pill(_Segment.invoices, AppStrings.jobsSegmentInvoices),
        ],
      ),
    );
  }

  Widget _pill(_Segment seg, String label) {
    final selected = value == seg;
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => onChanged(seg),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: selected ? const Color(0xFFFFFFFF) : null,
          borderRadius: BorderRadius.circular(8),
          boxShadow: selected
              ? const [
                  BoxShadow(
                    color: Color(0x14000000),
                    offset: Offset(0, 1),
                    blurRadius: 2,
                  ),
                ]
              : null,
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: selected ? const Color(0xFF1C1C1E) : const Color(0xFF6E6E73),
          ),
        ),
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
      child: ClipRRect(
        borderRadius: BorderRadius.circular(22),
        child: Container(
          height: 168,
          color: theme.accent,
          child: Stack(
            children: [
              Positioned(
                top: -30,
                right: -30,
                child: Container(
                  width: 160,
                  height: 160,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: Color(0x1FFFFFFF),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      width: 44,
                      height: 44,
                      alignment: Alignment.center,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: Color(0x33FFFFFF),
                      ),
                      child: const AdaptiveIcon(
                        AdaptiveIconName.cameraSymbol,
                        color: Color(0xFFFFFFFF),
                      ),
                    ),
                    const Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          AppStrings.jobsHeroHeadline,
                          style: TextStyle(
                            color: Color(0xFFFFFFFF),
                            fontSize: 22,
                            fontWeight: FontWeight.w700,
                            letterSpacing: -0.3,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          AppStrings.jobsHeroSubline,
                          style: TextStyle(
                            color: Color(0xD9FFFFFF),
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
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
      child: Text(text, style: const TextStyle(color: Color(0xFF6E6E73))),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.title, required this.count, required this.totalCents});
  final String title;
  final int count;
  final int totalCents;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.baseline,
      textBaseline: TextBaseline.alphabetic,
      children: [
        Text(
          title,
          style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w700),
        ),
        const Spacer(),
        Text(
          '$count · ${Money.formatCents(totalCents)}',
          style: const TextStyle(fontSize: 13, color: Color(0xFF6E6E73)),
        ),
      ],
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
    final theme = context.adaptiveTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(height: theme.spacing.xl),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: theme.spacing.lg),
          child: _SectionHeader(
            title: AppStrings.jobsWaitingHeader,
            count: summaries.length,
            totalCents: total,
          ),
        ),
        SizedBox(height: theme.spacing.md),
        SizedBox(
          height: 176,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: EdgeInsets.symmetric(horizontal: theme.spacing.lg),
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
    final photo = summary.beforePhotoPath;
    final serviceName = summary.primaryServiceName ?? AppStrings.tabServices;
    final customer = summary.customer?.name ?? AppStrings.builderNoCustomer;
    final priceLabel = Money.formatCents(summary.totalCents);
    final pillLabel = _sentPillLabel(summary.job);

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => _openDetail(context, summary.job.id),
      child: SizedBox(
        width: 150,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: ColoredBox(
            color: const Color(0xFFF2F2F7),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  height: 92,
                  width: double.infinity,
                  child: Stack(
                    children: [
                      Positioned.fill(
                        child: photo == null
                            ? Container(
                                color: const Color(0xFFCFD8E3),
                                alignment: Alignment.center,
                                child: const AdaptiveIcon(
                                  AdaptiveIconName.photo,
                                  color: Color(0xFFFFFFFF),
                                ),
                              )
                            : Image.file(File(photo), fit: BoxFit.cover),
                      ),
                      if (pillLabel != null)
                        Positioned(
                          left: 8,
                          bottom: 8,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: const Color(0x73000000),
                              borderRadius: BorderRadius.circular(999),
                            ),
                            child: Text(
                              pillLabel,
                              style: const TextStyle(
                                color: Color(0xFFFFFFFF),
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        serviceName,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '$customer · $priceLabel',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 12,
                          color: Color(0xFF6E6E73),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
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
    final theme = context.adaptiveTheme;
    final total = summaries.fold<int>(0, (a, s) => a + s.totalCents);
    return Padding(
      padding: EdgeInsets.fromLTRB(
        theme.spacing.lg,
        theme.spacing.xl,
        theme.spacing.lg,
        0,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _SectionHeader(
            title: AppStrings.jobsAcceptedHeader,
            count: summaries.length,
            totalCents: total,
          ),
          const SizedBox(height: 8),
          for (var i = 0; i < summaries.length; i++)
            _AcceptedRow(summary: summaries[i], showDivider: i > 0),
        ],
      ),
    );
  }
}

class _AcceptedRow extends StatelessWidget {
  const _AcceptedRow({required this.summary, required this.showDivider});
  final JobSummary summary;
  final bool showDivider;

  @override
  Widget build(BuildContext context) {
    final theme = context.adaptiveTheme;
    final serviceName = summary.primaryServiceName ?? AppStrings.tabServices;
    final customer = summary.customer?.name ?? AppStrings.builderNoCustomer;
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => _openDetail(context, summary.job.id),
      child: Container(
        decoration: showDivider
            ? const BoxDecoration(
                border: Border(
                  top: BorderSide(color: Color(0xFFF2F2F7)),
                ),
              )
            : null,
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
                '$serviceName · $customer',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            Text(
              Money.formatCents(summary.totalCents),
              style: const TextStyle(
                fontSize: 15,
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
            padding: const EdgeInsets.only(top: 16, bottom: 4),
            child: Text(
              name,
              style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
            ),
          ),
          for (var i = 0; i < groups[name]!.length; i++)
            _AcceptedRow(summary: groups[name]![i], showDivider: i > 0),
        ],
      ],
    );
  }
}

void _openDetail(BuildContext context, int jobId) {
  unawaited(context.push<void>('/job/$jobId'));
}

String? _sentPillLabel(Job job) {
  if (job.status != JobStatus.sent.code) return null;
  final sentAt = job.sentAt ?? job.createdAt;
  final ago = DateTime.now().difference(
    DateTime.fromMillisecondsSinceEpoch(sentAt),
  );
  if (ago.inHours < 24) return '${AppStrings.jobsStatusSent} today';
  final days = ago.inDays;
  return '${AppStrings.jobsStatusSent} ${days}d ago';
}
