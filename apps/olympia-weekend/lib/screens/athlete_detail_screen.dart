import 'package:factory_core/adaptive/adaptive.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:olympia_weekend/data/models.dart';
import 'package:olympia_weekend/data/schedule_repo.dart';
import 'package:olympia_weekend/design_tokens.dart';
import 'package:olympia_weekend/features/instagram.dart';
import 'package:olympia_weekend/features/mixpanel_service.dart';
import 'package:olympia_weekend/features/sightings_repo.dart';
import 'package:olympia_weekend/l10n/app_strings.dart';
import 'package:olympia_weekend/router.dart';
import 'package:olympia_weekend/widgets/card.dart';

class AthleteDetailScreen extends ConsumerStatefulWidget {
  const AthleteDetailScreen({required this.athleteId, super.key});

  final String athleteId;

  @override
  ConsumerState<AthleteDetailScreen> createState() =>
      _AthleteDetailScreenState();
}

class _AthleteDetailScreenState extends ConsumerState<AthleteDetailScreen> {
  final Set<String> _optimisticallyConfirmed = {};
  String? _errorMsg;

  @override
  Widget build(BuildContext context) {
    final colors = context.olympiaColors;
    final data = ref.watch(athletesProvider);
    return ColoredBox(
      color: colors.background,
      child: AdaptiveScaffold(
        backgroundColor: colors.background,
        titleDisplay: TitleDisplay.none,
        body: SafeArea(
          bottom: false,
          child: data.when(
            loading: () => const Center(child: AdaptiveLoading()),
            error: (_, __) => Center(
              child: Text(
                AppStrings.errorLiveRefresh,
                style: context.olympiaText.row.copyWith(
                  fontWeight: FontWeight.w400,
                  color: colors.textMuted,
                ),
              ),
            ),
            data: (payload) {
              final athlete = payload.athletes.firstWhere(
                (a) => a.id == widget.athleteId,
                orElse: () => Athlete(
                  id: widget.athleteId,
                  name: widget.athleteId,
                  divisionId: 'mens-open',
                  country: '',
                  tagline: '',
                  appearances: const [],
                ),
              );
              final division = payload.divisions.firstWhere(
                (d) => d.id == athlete.divisionId,
                orElse: () => Division(
                  id: athlete.divisionId,
                  name: athlete.divisionId,
                  prejudgingEventId: '',
                  finalsEventId: '',
                ),
              );
              ref.read(mixpanelProvider).viewAthlete(
                    athleteId: athlete.id,
                    division: division.id,
                    hasInstagram: athlete.instagram != null,
                    hasAppearance: athlete.appearances.isNotEmpty,
                  );
              return _buildBody(athlete, division);
            },
          ),
        ),
      ),
    );
  }

  Widget _buildBody(Athlete athlete, Division division) {
    final colors = context.olympiaColors;
    return ListView(
      padding: EdgeInsets.zero,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
          child: GestureDetector(
            onTap: () {
              if (context.canPop()) {
                context.pop();
              } else {
                context.goNamed(Routes.athletes);
              }
            },
            child: Text(
              '‹ ${AppStrings.athletesTitle}',
              style: context.olympiaText.row.copyWith(
                fontWeight: FontWeight.w400,
                color: colors.textMuted,
              ),
            ),
          ),
        ),
        const SizedBox(height: 20),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Text(
            athlete.name,
            style: context.olympiaText.title.copyWith(fontSize: 28),
          ),
        ),
        const SizedBox(height: 4),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Text(
            '${division.name}${athlete.country.isEmpty ? '' : ' · ${athlete.country}'}',
            style: context.olympiaText.row.copyWith(
              fontWeight: FontWeight.w400,
              color: colors.textMuted,
            ),
          ),
        ),
        if (athlete.instagram != null) ...[
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: OlympiaCard(
              padding: const EdgeInsets.symmetric(
                  horizontal: 18, vertical: 14),
              child: GestureDetector(
                onTap: () {
                  ref.read(mixpanelProvider).openInstagram(athlete.id);
                  openInstagram(athlete.instagram!);
                },
                child: Row(
                  children: [
                    Text(
                      AppStrings.athleteInstagram,
                      style: context.olympiaText.row,
                    ),
                    const Spacer(),
                    Text(
                      '@${athlete.instagram}',
                      style: context.olympiaText.row.copyWith(
                        fontWeight: FontWeight.w400,
                        color: colors.textMuted,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
        if (athlete.appearances.isNotEmpty) ...[
          const SizedBox(height: 24),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Text(
              AppStrings.athleteAppearances,
              style: context.olympiaText.section,
            ),
          ),
          const SizedBox(height: 10),
          for (final a in athlete.appearances) ...[
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 12),
              child: _AppearanceCard(
                athleteId: athlete.id,
                appearance: a,
                optimisticallyConfirmed: _optimisticallyConfirmed
                    .contains(a.appearanceKey(athlete.id)),
                onSaw: () => _handleSaw(athlete, a),
              ),
            ),
          ],
        ],
        const SizedBox(height: 16),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: GestureDetector(
            onTap: () => _openReportSheet(athlete),
            child: Text(
              AppStrings.athleteReportBooth,
              style: context.olympiaText.row.copyWith(
                color: const Color(0xFFe2231a),
              ),
            ),
          ),
        ),
        if (_errorMsg != null) ...[
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Text(
              _errorMsg!,
              style: context.olympiaText.caption.copyWith(
                color: const Color(0xFFe2231a),
              ),
            ),
          ),
        ],
        const SizedBox(height: 40),
      ],
    );
  }

  Future<void> _openReportSheet(Athlete athlete) async {
    final report = await AdaptiveSheet.show<_Report>(
      context,
      child: _ReportSheet(athleteName: athlete.name),
    );
    if (report == null || !mounted) return;
    setState(() => _errorMsg = null);
    // Reviewer round 1 blocker 6: for v1 a report goes through the
    // same insert path as a confirm — sightings.appearance_key is a
    // composite that already carries booth + start, so a fresh row
    // means a user seeded a new location.
    final appearance = Appearance(
      date: report.date,
      start: report.start,
      venueId: 'lvcc',
      booth: report.booth,
      status: AppearanceStatus.reported,
      confirmations: 0,
      source: 'user_reported',
    );
    ref.read(mixpanelProvider).reportSighting(athlete.id);
    final result = await ref.read(sightingsRepoProvider).confirm(
          athleteId: athlete.id,
          appearance: appearance,
        );
    if (!mounted) return;
    switch (result) {
      case ConfirmSightingResult.inserted:
      case ConfirmSightingResult.duplicate:
      case ConfirmSightingResult.disabled:
        break;
      case ConfirmSightingResult.rateLimited:
        setState(() => _errorMsg = AppStrings.athleteSightingRateLimited);
        ref.read(mixpanelProvider).error(
              where: 'report_sighting',
              message: 'rate_limited',
            );
      case ConfirmSightingResult.failed:
        setState(() => _errorMsg = AppStrings.athleteSightingFailed);
        ref.read(mixpanelProvider).error(
              where: 'report_sighting',
              message: 'network',
            );
    }
  }

  Future<void> _handleSaw(Athlete athlete, Appearance appearance) async {
    setState(() => _errorMsg = null);
    final repo = ref.read(sightingsRepoProvider);
    final result = await repo.confirm(
      athleteId: athlete.id,
      appearance: appearance,
    );
    if (!mounted) return;
    setState(() {
      switch (result) {
        case ConfirmSightingResult.inserted:
        case ConfirmSightingResult.duplicate:
        case ConfirmSightingResult.disabled:
          _optimisticallyConfirmed.add(appearance.appearanceKey(athlete.id));
        case ConfirmSightingResult.rateLimited:
          _errorMsg = AppStrings.athleteSightingRateLimited;
          ref.read(mixpanelProvider).error(
                where: 'confirm_sighting',
                message: 'rate_limited',
              );
        case ConfirmSightingResult.failed:
          _errorMsg = AppStrings.athleteSightingFailed;
          ref.read(mixpanelProvider).error(
                where: 'confirm_sighting',
                message: 'network',
              );
      }
    });
    if (result == ConfirmSightingResult.inserted) {
      ref.read(mixpanelProvider).confirmSighting(
            athleteId: athlete.id,
            booth: appearance.booth,
            resultingStatus: 'confirmed',
          );
    }
  }
}

/// User input from the "Report a booth or time" sheet.
class _Report {
  const _Report({
    required this.booth,
    required this.date,
    required this.start,
  });
  final String booth;
  final String date;
  final String start;
}

class _ReportSheet extends StatefulWidget {
  const _ReportSheet({required this.athleteName});
  final String athleteName;

  @override
  State<_ReportSheet> createState() => _ReportSheetState();
}

class _ReportSheetState extends State<_ReportSheet> {
  final _boothController = TextEditingController();
  String _date = '2026-09-25';
  int _hour = 13;

  static const _days = [
    ('2026-09-23', 'Wed'),
    ('2026-09-24', 'Thu'),
    ('2026-09-25', 'Fri'),
    ('2026-09-26', 'Sat'),
    ('2026-09-27', 'Sun'),
  ];

  @override
  void dispose() {
    _boothController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.olympiaColors;
    return ColoredBox(
      color: colors.background,
      child: SafeArea(
        top: false,
        child: Padding(
          padding: EdgeInsets.only(
            left: 24,
            right: 24,
            top: 24,
            bottom: 24 + MediaQuery.viewInsetsOf(context).bottom,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                AppStrings.athleteReportTitle,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: colors.text,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                AppStrings.athleteReportBody,
                style: context.olympiaText.caption,
              ),
              const SizedBox(height: 20),
              Text(
                AppStrings.athleteReportBoothLabel,
                style: context.olympiaText.caption.copyWith(
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 6),
              AdaptiveInput(
                controller: _boothController,
                placeholder: AppStrings.athleteReportBoothHint,
              ),
              const SizedBox(height: 16),
              Text(
                AppStrings.athleteReportDay,
                style: context.olympiaText.caption.copyWith(
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  for (final d in _days)
                    _PillChoice(
                      label: d.$2,
                      active: _date == d.$1,
                      onTap: () => setState(() => _date = d.$1),
                    ),
                ],
              ),
              const SizedBox(height: 16),
              Text(
                AppStrings.athleteReportStart,
                style: context.olympiaText.caption.copyWith(
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  for (final h in const [10, 11, 12, 13, 14, 15, 16, 17, 18])
                    _PillChoice(
                      label: _shortHour(h),
                      active: _hour == h,
                      onTap: () => setState(() => _hour = h),
                    ),
                ],
              ),
              const SizedBox(height: 24),
              AdaptivePrimaryButton(
                label: AppStrings.athleteReportSubmit,
                onPressed: () {
                  final booth = _boothController.text.trim();
                  if (booth.isEmpty) return;
                  Navigator.of(context).pop(_Report(
                    booth: booth,
                    date: _date,
                    start: '${_hour.toString().padLeft(2, '0')}:00',
                  ));
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PillChoice extends StatelessWidget {
  const _PillChoice({
    required this.label,
    required this.active,
    required this.onTap,
  });
  final String label;
  final bool active;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.olympiaColors;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: active ? colors.pillActiveBg : colors.surface,
          borderRadius: BorderRadius.circular(999),
          border: Border.all(color: colors.surfaceBorder),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 13,
            fontWeight: active ? FontWeight.w600 : FontWeight.w500,
            color: active ? colors.pillActiveText : colors.text,
          ),
        ),
      ),
    );
  }
}

String _shortHour(int h) {
  final suffix = h >= 12 ? 'PM' : 'AM';
  final h12 = h == 0 ? 12 : (h > 12 ? h - 12 : h);
  return '$h12 $suffix';
}

class _AppearanceCard extends StatelessWidget {
  const _AppearanceCard({
    required this.athleteId,
    required this.appearance,
    required this.optimisticallyConfirmed,
    required this.onSaw,
  });

  final String athleteId;
  final Appearance appearance;
  final bool optimisticallyConfirmed;
  final VoidCallback onSaw;

  @override
  Widget build(BuildContext context) {
    final colors = context.olympiaColors;
    final confirmed = optimisticallyConfirmed ||
        appearance.status == AppearanceStatus.confirmed;
    return OlympiaCard(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  '${appearance.start}  ·  ${appearance.booth}',
                  style: context.olympiaText.row,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 9, vertical: 3),
                decoration: BoxDecoration(
                  color: confirmed
                      ? colors.badgeConfirmedBg
                      : colors.badgeReportedBg,
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  confirmed
                      ? AppStrings.athleteConfirmed
                      : AppStrings.athleteReported,
                  style: context.olympiaText.tag.copyWith(
                    color: confirmed
                        ? colors.badgeConfirmedText
                        : colors.badgeReportedText,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          AdaptiveSecondaryButton(
            label: AppStrings.athleteISawThis,
            onPressed: onSaw,
          ),
        ],
      ),
    );
  }
}
