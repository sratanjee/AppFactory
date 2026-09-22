import 'dart:async';

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
import 'package:olympia_weekend/widgets/filter_chip.dart';
import 'package:olympia_weekend/widgets/pressable.dart';
import 'package:url_launcher/url_launcher.dart';

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
                    hasInstagram: _effectiveSocials(athlete)
                        .any((s) => s.platform == SocialPlatform.instagram),
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
          child: Align(
            alignment: Alignment.centerLeft,
            child: OlympiaPressable(
              onTap: () {
                if (context.canPop()) {
                  context.pop();
                } else {
                  context.goNamed(Routes.athletes);
                }
              },
              semanticsLabel: 'Back to athletes',
              minSize: const Size(48, 44),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
                child: Text(
                  '‹ ${AppStrings.athletesTitle}',
                  style: context.olympiaText.row.copyWith(
                    fontWeight: FontWeight.w400,
                    color: colors.textMuted,
                  ),
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 16),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: _AthleteHeroCard(
            athlete: athlete,
            division: division,
            onOpenSocial: (link) => _openSocial(athlete, link),
          ),
        ),
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
          child: Align(
            alignment: Alignment.centerLeft,
            child: OlympiaPressable(
              onTap: () => _openReportSheet(athlete),
              semanticsLabel: AppStrings.athleteReportBooth,
              minSize: const Size(0, 44),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 4),
                child: Text(
                  AppStrings.athleteReportBooth,
                  style: context.olympiaText.row.copyWith(
                    color: const Color(0xFFe2231a),
                  ),
                ),
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

  Future<void> _openSocial(Athlete athlete, SocialLink link) async {
    final url = resolveSocialUrl(link);
    if (url == null) return;
    final mp = ref.read(mixpanelProvider);
    if (link.platform == SocialPlatform.instagram) {
      // Existing tracking event keeps its dashboards intact.
      unawaited(mp.openInstagram(athlete.id));
      // Prefer the native Instagram app when we still have a handle.
      final handle = link.handleOrUrl;
      if (!handle.startsWith('http')) {
        await openInstagram(handle);
        return;
      }
    } else {
      unawaited(mp.openSocial(athleteId: athlete.id, platform: link.platform.name));
    }
    await launchUrl(url, mode: LaunchMode.externalApplication);
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
                    OlympiaFilterChip(
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
                    OlympiaFilterChip(
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

String _shortHour(int h) {
  final suffix = h >= 12 ? 'PM' : 'AM';
  final h12 = h == 0 ? 12 : (h > 12 ? h - 12 : h);
  return '$h12 $suffix';
}

/// Merges the legacy `Athlete.instagram` field into the socials list at
/// render time, so entries that predate the socials array still show
/// their Instagram pill without a data migration.
List<SocialLink> _effectiveSocials(Athlete a) {
  final hasInsta =
      a.socials.any((s) => s.platform == SocialPlatform.instagram);
  if (hasInsta || a.instagram == null || a.instagram!.isEmpty) {
    return a.socials;
  }
  return <SocialLink>[
    SocialLink(platform: SocialPlatform.instagram, handleOrUrl: a.instagram!),
    ...a.socials,
  ];
}

/// Turns a [SocialLink] into a resolvable https URL. Handles the two
/// conventions we allow in the JSON: bare handle for insta/tiktok,
/// full URL for everything else.
Uri? resolveSocialUrl(SocialLink link) {
  final v = link.handleOrUrl.trim();
  if (v.isEmpty) return null;
  if (v.startsWith('http://') || v.startsWith('https://')) {
    return Uri.tryParse(v);
  }
  switch (link.platform) {
    case SocialPlatform.instagram:
      return Uri.parse('https://instagram.com/${_stripAt(v)}');
    case SocialPlatform.tiktok:
      return Uri.parse('https://tiktok.com/@${_stripAt(v)}');
    case SocialPlatform.twitter:
      return Uri.parse('https://x.com/${_stripAt(v)}');
    case SocialPlatform.youtube:
      // Handle "@channel" or bare channel id; official channels live on
      // youtube.com/@name so that's the safer default.
      return Uri.parse('https://youtube.com/${v.startsWith('@') ? v : '@$v'}');
    case SocialPlatform.website:
      return Uri.tryParse(v.startsWith('http') ? v : 'https://$v');
  }
}

String _stripAt(String v) => v.startsWith('@') ? v.substring(1) : v;

/// Flag emoji for the roster's most common countries. When we don't
/// have a mapping the row just omits the flag, which is visually fine.
String? _countryFlag(String? country) {
  if (country == null || country.isEmpty) return null;
  const map = <String, String>{
    'United States': '\u{1F1FA}\u{1F1F8}',
    'Iran': '\u{1F1EE}\u{1F1F7}',
    'United Arab Emirates': '\u{1F1E6}\u{1F1EA}',
    'United Kingdom': '\u{1F1EC}\u{1F1E7}',
    'Brazil': '\u{1F1E7}\u{1F1F7}',
    'Canada': '\u{1F1E8}\u{1F1E6}',
    'Netherlands': '\u{1F1F3}\u{1F1F1}',
    'Germany': '\u{1F1E9}\u{1F1EA}',
    'Poland': '\u{1F1F5}\u{1F1F1}',
    'Russia': '\u{1F1F7}\u{1F1FA}',
    'Slovakia': '\u{1F1F8}\u{1F1F0}',
    'Slovenia': '\u{1F1F8}\u{1F1EE}',
    'Italy': '\u{1F1EE}\u{1F1F9}',
    'Spain': '\u{1F1EA}\u{1F1F8}',
    'Turkey': '\u{1F1F9}\u{1F1F7}',
    'Bulgaria': '\u{1F1E7}\u{1F1EC}',
    'Mexico': '\u{1F1F2}\u{1F1FD}',
    'Colombia': '\u{1F1E8}\u{1F1F4}',
    'Chile': '\u{1F1E8}\u{1F1F1}',
    'Australia': '\u{1F1E6}\u{1F1FA}',
    'China': '\u{1F1E8}\u{1F1F3}',
    'Taiwan': '\u{1F1F9}\u{1F1FC}',
    'Japan': '\u{1F1EF}\u{1F1F5}',
    'South Korea': '\u{1F1F0}\u{1F1F7}',
    'Kuwait': '\u{1F1F0}\u{1F1FC}',
    'Nigeria': '\u{1F1F3}\u{1F1EC}',
    'Saudi Arabia': '\u{1F1F8}\u{1F1E6}',
    'Ukraine': '\u{1F1FA}\u{1F1E6}',
    'Croatia': '\u{1F1ED}\u{1F1F7}',
    'Hungary': '\u{1F1ED}\u{1F1FA}',
    'Nicaragua': '\u{1F1F3}\u{1F1EE}',
    'Czech Republic': '\u{1F1E8}\u{1F1FF}',
    'Austria': '\u{1F1E6}\u{1F1F9}',
    'Afghanistan': '\u{1F1E6}\u{1F1EB}',
    'Morocco': '\u{1F1F2}\u{1F1E6}',
    'Ghana': '\u{1F1EC}\u{1F1ED}',
    'India': '\u{1F1EE}\u{1F1F3}',
    'Indonesia': '\u{1F1EE}\u{1F1E9}',
    'Paraguay': '\u{1F1F5}\u{1F1FE}',
    'Venezuela': '\u{1F1FB}\u{1F1EA}',
    'Philippines': '\u{1F1F5}\u{1F1ED}',
    'Kyrgyzstan': '\u{1F1F0}\u{1F1EC}',
    'New Zealand': '\u{1F1F3}\u{1F1FF}',
    'Switzerland': '\u{1F1E8}\u{1F1ED}',
    'Thailand': '\u{1F1F9}\u{1F1ED}',
    'Greece': '\u{1F1EC}\u{1F1F7}',
    'Portugal': '\u{1F1F5}\u{1F1F9}',
    'Dominican Republic': '\u{1F1E9}\u{1F1F4}',
    'Moldova': '\u{1F1F2}\u{1F1E9}',
    'Bahamas': '\u{1F1E7}\u{1F1F8}',
    'Puerto Rico': '\u{1F1F5}\u{1F1F7}',
    'Bolivia': '\u{1F1E7}\u{1F1F4}',
    'Finland': '\u{1F1EB}\u{1F1EE}',
    'France': '\u{1F1EB}\u{1F1F7}',
    'Montenegro': '\u{1F1F2}\u{1F1EA}',
    'Vietnam': '\u{1F1FB}\u{1F1F3}',
    'Romania': '\u{1F1F7}\u{1F1F4}',
  };
  return map[country];
}

String _socialLabel(SocialPlatform p) {
  switch (p) {
    case SocialPlatform.instagram:
      return 'Instagram';
    case SocialPlatform.tiktok:
      return 'TikTok';
    case SocialPlatform.youtube:
      return 'YouTube';
    case SocialPlatform.twitter:
      return 'X';
    case SocialPlatform.website:
      return 'Website';
  }
}

/// The baseball-card hero at the top of an athlete's detail screen.
///
/// Photo tile on the left (or initials avatar when we don't have a
/// verified physique shot), name + division + country + tagline on the
/// right, then a wrapping row of tappable social pills.
class _AthleteHeroCard extends StatelessWidget {
  const _AthleteHeroCard({
    required this.athlete,
    required this.division,
    required this.onOpenSocial,
  });

  final Athlete athlete;
  final Division division;
  final ValueChanged<SocialLink> onOpenSocial;

  @override
  Widget build(BuildContext context) {
    final colors = context.olympiaColors;
    final socials = _effectiveSocials(athlete);
    final flag = _countryFlag(athlete.country);
    final countryLine = <String>[
      division.name,
      if (flag != null && athlete.country.isNotEmpty)
        '$flag ${athlete.country}'
      else if (athlete.country.isNotEmpty)
        athlete.country,
    ].join(' · ');

    return OlympiaCard(
      padding: const EdgeInsets.fromLTRB(18, 18, 18, 18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _HeroPhoto(athlete: athlete),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      athlete.name,
                      style: context.olympiaText.title.copyWith(fontSize: 26),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      countryLine,
                      style: context.olympiaText.caption,
                    ),
                    if (athlete.tagline.isNotEmpty) ...[
                      const SizedBox(height: 8),
                      Text(
                        athlete.tagline,
                        style: context.olympiaText.row.copyWith(
                          color: colors.textMuted,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
          if (socials.isNotEmpty) ...[
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final link in socials)
                  _SocialPill(
                    link: link,
                    onTap: () => onOpenSocial(link),
                  ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

/// 96 sq photo tile with graceful fallback to the initials avatar.
class _HeroPhoto extends StatelessWidget {
  const _HeroPhoto({required this.athlete});
  final Athlete athlete;

  @override
  Widget build(BuildContext context) {
    final colors = context.olympiaColors;
    final fallback = Container(
      width: 96,
      height: 96,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: colors.avatarBg,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Text(
        athlete.initials,
        style: TextStyle(
          fontSize: 28,
          fontWeight: FontWeight.w700,
          color: colors.avatarText,
        ),
      ),
    );

    final url = athlete.photoUrl;
    if (url == null || url.isEmpty) return fallback;

    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: SizedBox(
        width: 96,
        height: 96,
        child: Image.network(
          url,
          fit: BoxFit.cover,
          loadingBuilder: (context, child, progress) {
            if (progress == null) return child;
            return fallback;
          },
          errorBuilder: (_, _, _) => fallback,
        ),
      ),
    );
  }
}

/// Coloured, tappable pill for one social channel.
class _SocialPill extends StatelessWidget {
  const _SocialPill({required this.link, required this.onTap});
  final SocialLink link;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.olympiaColors;
    final label = _socialLabel(link.platform);
    // Per spec: red-tinted Instagram, red-primary YouTube, dark-surface
    // for the rest. Text colour picked to keep contrast ~4.5:1 on both
    // themes; the app is locked to dark so the light-theme branch here
    // is future-proofing.
    late final Color bg;
    late final Color fg;
    switch (link.platform) {
      case SocialPlatform.instagram:
        bg = const Color(0xFFE2231A);
        fg = const Color(0xFFFFFFFF);
      case SocialPlatform.youtube:
        bg = const Color(0xFFFF0000);
        fg = const Color(0xFFFFFFFF);
      case SocialPlatform.tiktok:
        bg = colors.pillActiveBg;
        fg = colors.pillActiveText;
      case SocialPlatform.twitter:
        bg = colors.surface;
        fg = colors.text;
      case SocialPlatform.website:
        bg = colors.surface;
        fg = colors.text;
    }
    return OlympiaPressable(
      onTap: onTap,
      semanticsLabel: 'Open $label',
      minSize: const Size(0, 36),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(999),
          border: Border.all(color: colors.surfaceBorder, width: 0.5),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: fg,
          ),
        ),
      ),
    );
  }
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
