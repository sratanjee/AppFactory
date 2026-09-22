import 'package:factory_core/adaptive/adaptive.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:olympia_weekend/data/models.dart';
import 'package:olympia_weekend/data/schedule_repo.dart';
import 'package:olympia_weekend/design_tokens.dart';
import 'package:olympia_weekend/features/mixpanel_service.dart';
import 'package:olympia_weekend/features/now_state.dart';
import 'package:olympia_weekend/features/vegas_time.dart';
import 'package:olympia_weekend/l10n/app_strings.dart';
import 'package:olympia_weekend/router.dart';
import 'package:olympia_weekend/widgets/card.dart';
import 'package:olympia_weekend/widgets/day_pills.dart';
import 'package:olympia_weekend/widgets/event_row.dart';
import 'package:olympia_weekend/widgets/filter_chip.dart';

enum ScheduleFilter { all, free, ticketed, palms }

class ScheduleScreen extends ConsumerStatefulWidget {
  const ScheduleScreen({super.key});

  @override
  ConsumerState<ScheduleScreen> createState() => _ScheduleScreenState();
}

class _ScheduleScreenState extends ConsumerState<ScheduleScreen> {
  ScheduleFilter _filter = ScheduleFilter.all;
  String? _selectedDate;
  bool _tracked = false;

  @override
  Widget build(BuildContext context) {
    final colors = context.olympiaColors;
    final scheduleAsync = ref.watch(scheduleProvider);
    final venuesById = ref.watch(venuesByIdProvider);

    return ColoredBox(
      color: colors.background,
      child: AdaptiveScaffold(
        backgroundColor: colors.background,
        titleDisplay: TitleDisplay.none,
        body: SafeArea(
          bottom: false,
          child: scheduleAsync.when(
            loading: () => const Center(child: AdaptiveLoading()),
            error: (_, __) => Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Text(
                  AppStrings.errorLiveRefresh,
                  style: context.olympiaText.row.copyWith(
                    fontWeight: FontWeight.w400,
                    color: colors.textMuted,
                  ),
                ),
              ),
            ),
            data: (events) {
              const days = [
                '2026-09-23',
                '2026-09-24',
                '2026-09-25',
                '2026-09-26',
                '2026-09-27',
              ];
              final now = ref.read(vegasClockProvider)();
              final today = vegasDateOf(now);
              final selected = _selectedDate ??
                  (days.contains(today) ? today : '2026-09-25');

              if (!_tracked) {
                _tracked = true;
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  ref.read(mixpanelProvider).viewSchedule(
                        daySelected: selected,
                        filter: _filter.name,
                      );
                });
              }

              final dayEvents = events
                  .where((e) => e.date == selected)
                  .toList()
                ..sort(
                    (a, b) => (a.start ?? '99:99').compareTo(b.start ?? '99:99'));
              final filtered = dayEvents.where(_matches).toList();
              final morning = filtered.where(_isMorning).toList();
              final afternoon = filtered.where((e) => !_isMorning(e)).toList();

              return ListView(
                padding: EdgeInsets.zero,
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
                    child: Text(
                      AppStrings.scheduleTitle,
                      style: context.olympiaText.title,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: DayPills(
                      dates: days,
                      selected: selected,
                      activeColor: const Color(0xFFe2231a),
                      activeTextColor: const Color(0xFFFFFFFF),
                      onSelected: (d) {
                        ref.read(mixpanelProvider).dayChange(selected, d);
                        setState(() => _selectedDate = d);
                      },
                    ),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    height: 48,
                    child: ListView(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      children: [
                        _filterChip(ScheduleFilter.all,
                            AppStrings.scheduleFilterAll),
                        const SizedBox(width: 8),
                        _filterChip(ScheduleFilter.free,
                            AppStrings.scheduleFilterFree),
                        const SizedBox(width: 8),
                        _filterChip(ScheduleFilter.ticketed,
                            AppStrings.scheduleFilterTicket),
                        const SizedBox(width: 8),
                        _filterChip(ScheduleFilter.palms,
                            AppStrings.scheduleFilterPalms),
                      ],
                    ),
                  ),
                  const SizedBox(height: 8),
                  if (filtered.isEmpty)
                    Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            AppStrings.scheduleEmpty,
                            style: context.olympiaText.row.copyWith(
                              fontWeight: FontWeight.w400,
                              color: colors.textMuted,
                            ),
                          ),
                          const SizedBox(height: 12),
                          AdaptiveSecondaryButton(
                            label: AppStrings.scheduleClearFilters,
                            onPressed: () =>
                                setState(() => _filter = ScheduleFilter.all),
                          ),
                        ],
                      ),
                    )
                  else ...[
                    if (morning.isNotEmpty)
                      _section(context, AppStrings.scheduleMorning, morning,
                          venuesById),
                    if (afternoon.isNotEmpty)
                      _section(context, AppStrings.scheduleAfternoon,
                          afternoon, venuesById),
                  ],
                  const SizedBox(height: 32),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _filterChip(ScheduleFilter which, String label) {
    return OlympiaFilterChip(
      label: label,
      active: _filter == which,
      onTap: () {
        setState(() => _filter = which);
        ref.read(mixpanelProvider).filterChange(which.name);
      },
    );
  }

  bool _matches(Event e) {
    switch (_filter) {
      case ScheduleFilter.all:
        return true;
      case ScheduleFilter.free:
        return e.access == EventAccess.free;
      case ScheduleFilter.ticketed:
        return e.access == EventAccess.ticket;
      case ScheduleFilter.palms:
        return e.venueId == 'palms';
    }
  }

  bool _isMorning(Event e) {
    final s = e.start;
    if (s == null) return false;
    final hour = int.tryParse(s.split(':').first) ?? 0;
    return hour < 12;
  }

  Widget _section(BuildContext context, String title, List<Event> events,
      Map<String, Venue> venuesById) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 20, 24, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: context.olympiaText.caption.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          OlympiaCard(
            padding: EdgeInsets.zero,
            child: Column(
              children: [
                for (var i = 0; i < events.length; i++) ...[
                  EventRow(
                    event: events[i],
                    venueLabel: _venueLabel(
                        venuesById[events[i].venueId], events[i]),
                    timeLabel: _shortTime(events[i].start),
                    onTap: () {
                      ref.read(mixpanelProvider).viewEvent(
                            eventId: events[i].id,
                            access: events[i].access.name,
                            venue: events[i].venueId,
                            fromScreen: 'schedule',
                          );
                      context.goNamed(Routes.event,
                          pathParameters: {'id': events[i].id});
                    },
                  ),
                  if (i != events.length - 1)
                    const OlympiaDivider(indent: 86),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _venueLabel(Venue? v, Event e) {
    if (v == null) return e.venueId;
    return e.room == null ? v.short : '${v.short} · ${e.room}';
  }
}

String _shortTime(String? hhmm) {
  if (hhmm == null) return '';
  final parts = hhmm.split(':');
  if (parts.length < 2) return hhmm;
  final h = int.tryParse(parts[0]) ?? 0;
  final m = parts[1];
  final h12 = h == 0 ? 12 : (h > 12 ? h - 12 : h);
  return '$h12:$m';
}
