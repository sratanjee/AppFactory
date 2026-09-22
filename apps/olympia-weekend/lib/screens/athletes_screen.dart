import 'package:factory_core/adaptive/adaptive.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:olympia_weekend/data/models.dart';
import 'package:olympia_weekend/data/schedule_repo.dart';
import 'package:olympia_weekend/design_tokens.dart';
import 'package:olympia_weekend/features/mixpanel_service.dart';
import 'package:olympia_weekend/l10n/app_strings.dart';
import 'package:olympia_weekend/router.dart';
import 'package:olympia_weekend/widgets/async_body.dart';
import 'package:olympia_weekend/widgets/card.dart';
import 'package:olympia_weekend/widgets/chip_strip.dart';
import 'package:olympia_weekend/widgets/filter_chip.dart';
import 'package:olympia_weekend/widgets/pressable.dart';

class AthletesScreen extends ConsumerStatefulWidget {
  const AthletesScreen({super.key});

  @override
  ConsumerState<AthletesScreen> createState() => _AthletesScreenState();
}

class _AthletesScreenState extends ConsumerState<AthletesScreen> {
  final _searchController = TextEditingController();
  String? _divisionId;
  String _query = '';
  bool _tracked = false;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.olympiaColors;
    final athletesAsync = ref.watch(athletesProvider);
    final eventsById = ref.watch(eventsByIdProvider);
    return ColoredBox(
      color: colors.background,
      child: AdaptiveScaffold(
        backgroundColor: colors.background,
        titleDisplay: TitleDisplay.none,
        body: SafeArea(
          bottom: false,
          child: OlympiaAsyncBody(
            child: athletesAsync.when(
              loading: () => const Center(
                key: ValueKey('loading'),
                child: AdaptiveLoading(),
              ),
              error: (_, __) => Padding(
                key: const ValueKey('error'),
                padding: const EdgeInsets.all(24),
                child: Text(
                  AppStrings.errorLiveRefresh,
                  style: context.olympiaText.row.copyWith(
                    fontWeight: FontWeight.w400,
                    color: colors.textMuted,
                  ),
                ),
              ),
              data: (payload) {
                final divisionId = _divisionId ?? payload.divisions.first.id;
                if (!_tracked) {
                  _tracked = true;
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    ref.read(mixpanelProvider).viewAthletes(divisionId);
                  });
                }
                return KeyedSubtree(
                  key: const ValueKey('data'),
                  child: _buildBody(payload, divisionId, eventsById),
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBody(
    AthletesPayload payload,
    String divisionId,
    Map<String, Event> eventsById,
  ) {
    final colors = context.olympiaColors;
    final athletes = payload.athletes
        .where((a) => a.divisionId == divisionId)
        .where((a) => _query.isEmpty ||
            a.name.toLowerCase().contains(_query.toLowerCase()))
        .toList();
    final division = payload.divisions
        .firstWhere((d) => d.id == divisionId, orElse: () => payload.divisions.first);
    final prejudging = eventsById[division.prejudgingEventId];
    final finals = eventsById[division.finalsEventId];

    return ListView(
      padding: EdgeInsets.zero,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
          child: Text(
            AppStrings.athletesTitle,
            style: context.olympiaText.title,
          ),
        ),
        const SizedBox(height: 12),
        HorizontalChipStrip(
          children: [
            for (final d in payload.divisions)
              Padding(
                padding: const EdgeInsets.only(right: 8),
                child: OlympiaFilterChip(
                  label: d.name,
                  active: d.id == divisionId,
                  onTap: () {
                    setState(() => _divisionId = d.id);
                    ref.read(mixpanelProvider).viewAthletes(d.id);
                  },
                ),
              ),
          ],
        ),
        const SizedBox(height: 12),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: AdaptiveInput(
            controller: _searchController,
            placeholder: AppStrings.athletesSearchHint,
            onChanged: (v) {
              setState(() => _query = v);
              ref.read(mixpanelProvider).searchAthletes(v.length, 0);
            },
          ),
        ),
        const SizedBox(height: 20),
        _DivisionHeader(
          division: division,
          prejudging: prejudging,
          finals: finals,
        ),
        const SizedBox(height: 10),
        if (athletes.isEmpty)
          Padding(
            padding: const EdgeInsets.all(24),
            child: Text(
              _query.isEmpty
                  ? AppStrings.athletesDivisionEmpty
                  : AppStrings.athletesSearchEmpty
                      .replaceAll('{query}', _query),
              style: context.olympiaText.row.copyWith(
                fontWeight: FontWeight.w400,
                color: colors.textMuted,
              ),
            ),
          )
        else
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: OlympiaCard(
              padding: EdgeInsets.zero,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  for (var i = 0; i < athletes.length; i++) ...[
                    _AthleteRow(
                      athlete: athletes[i],
                      onTap: () {
                        context.goNamed(Routes.athlete,
                            pathParameters: {'id': athletes[i].id});
                      },
                    ),
                    if (i != athletes.length - 1)
                      const OlympiaDivider(indent: 76),
                  ],
                ],
              ),
            ),
          ),
        Padding(
          padding: const EdgeInsets.fromLTRB(24, 14, 24, 0),
          child: Text(
            AppStrings.athleteFooter,
            style: context.olympiaText.caption.copyWith(height: 1.45),
          ),
        ),
        const SizedBox(height: 40),
      ],
    );
  }
}

class _DivisionHeader extends StatelessWidget {
  const _DivisionHeader({
    required this.division,
    required this.prejudging,
    required this.finals,
  });

  final Division division;
  final Event? prejudging;
  final Event? finals;

  @override
  Widget build(BuildContext context) {
    final schedule = _scheduleLabel(prejudging, finals);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.baseline,
        textBaseline: TextBaseline.alphabetic,
        children: [
          Expanded(
            child: Text(
              division.name,
              style: context.olympiaText.section,
            ),
          ),
          if (schedule != null) ...[
            const SizedBox(width: 8),
            Flexible(
              child: Text(
                schedule,
                textAlign: TextAlign.right,
                style: context.olympiaText.caption,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _AthleteRow extends StatelessWidget {
  const _AthleteRow({required this.athlete, required this.onTap});
  final Athlete athlete;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.olympiaColors;
    final tagline = _taglineWithCountry(athlete);
    return OlympiaPressable(
      onTap: onTap,
      semanticsLabel: '${athlete.name}, ${tagline.isEmpty ? athlete.divisionId : tagline}',
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: colors.avatarBg,
                borderRadius: BorderRadius.circular(22),
              ),
              child: Text(
                athlete.initials,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: colors.avatarText,
                ),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    athlete.name,
                    style: context.olympiaText.row,
                  ),
                  if (tagline.isNotEmpty) ...[
                    const SizedBox(height: 2),
                    Text(
                      tagline,
                      style: context.olympiaText.caption,
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(width: 8),
            _AthleteRowTrailing(athlete: athlete),
          ],
        ),
      ),
    );
  }
}

/// Right-hand column on each athlete row:
///
/// - Next upcoming meet-and-greet → red "Meet & greet" label + short
///   "Sat 1 PM · Booth X" line.
/// - Otherwise the athlete's static booth if any.
/// - Otherwise a muted "No booth listed".
class _AthleteRowTrailing extends StatelessWidget {
  const _AthleteRowTrailing({required this.athlete});

  final Athlete athlete;

  @override
  Widget build(BuildContext context) {
    final colors = context.olympiaColors;
    final next = _nextAppearance(athlete);
    if (next != null) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            AppStrings.athletesMeetGreet,
            style: context.olympiaText.caption.copyWith(
              fontWeight: FontWeight.w500,
              color: const Color(0xFFe2231a),
            ),
          ),
          const SizedBox(height: 2),
          Text(
            '${_shortDayTime(next.date, next.start)} · Booth ${next.booth}',
            style: context.olympiaText.faint.copyWith(color: colors.textMuted),
          ),
        ],
      );
    }
    if (athlete.booth != null && athlete.booth!.isNotEmpty) {
      return Text(
        'Booth ${athlete.booth}',
        style: context.olympiaText.faint.copyWith(color: colors.textMuted),
      );
    }
    return Text(
      AppStrings.athletesNoBooth,
      style: context.olympiaText.faint,
    );
  }
}

// ————— helpers —————

String _taglineWithCountry(Athlete a) {
  final country = a.country.trim();
  if (a.tagline.isEmpty) return country;
  if (country.isEmpty) return a.tagline;
  return '${a.tagline} · $country';
}

/// First appearance in the athlete's list (they're already ordered by
/// the seed / live feed). Null when the roster carries no appearances.
Appearance? _nextAppearance(Athlete a) =>
    a.appearances.isEmpty ? null : a.appearances.first;

/// Formats the pre-judging + finals row for a division header. Returns
/// null when neither event is scheduled (loading, live-refresh miss).
String? _scheduleLabel(Event? prejudging, Event? finals) {
  final buf = <String>[];
  if (prejudging != null) {
    buf.add('Pre-judging ${_shortDayTime(prejudging.date, prejudging.start)}');
  }
  if (finals != null) {
    buf.add('Finals ${_shortDayTime(finals.date, finals.start)}');
  }
  return buf.isEmpty ? null : buf.join(' · ');
}

/// yyyy-MM-dd + HH:mm → "Sat 1 PM" / "Fri 6:30 PM". Uses the fixed 2026
/// weekend so the label reads friendlier than a raw date.
String _shortDayTime(String date, String? hhmm) {
  final day = _weekdayShort(date);
  if (hhmm == null) return day;
  final t = _shortTime(hhmm);
  return t.isEmpty ? day : '$day $t';
}

String _weekdayShort(String yyyyMmDd) {
  const map = {
    '2026-09-21': 'Mon',
    '2026-09-22': 'Tue',
    '2026-09-23': 'Wed',
    '2026-09-24': 'Thu',
    '2026-09-25': 'Fri',
    '2026-09-26': 'Sat',
    '2026-09-27': 'Sun',
    '2026-09-28': 'Mon',
  };
  return map[yyyyMmDd] ?? yyyyMmDd;
}

String _shortTime(String hhmm) {
  final parts = hhmm.split(':');
  if (parts.length < 2) return hhmm;
  final h = int.tryParse(parts[0]) ?? 0;
  final m = parts[1];
  final suffix = h >= 12 ? 'PM' : 'AM';
  final h12 = h == 0 ? 12 : (h > 12 ? h - 12 : h);
  return m == '00' ? '$h12 $suffix' : '$h12:$m $suffix';
}
