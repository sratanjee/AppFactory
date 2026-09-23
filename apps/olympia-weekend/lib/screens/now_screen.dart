import 'package:factory_core/adaptive/adaptive.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:olympia_weekend/data/models.dart';
import 'package:olympia_weekend/data/schedule_repo.dart';
import 'package:olympia_weekend/design_tokens.dart';
import 'package:olympia_weekend/features/mixpanel_service.dart';
import 'package:olympia_weekend/features/now_state.dart';
import 'package:olympia_weekend/features/saved_events.dart';
import 'package:olympia_weekend/features/vegas_time.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:olympia_weekend/l10n/app_strings.dart';
import 'package:olympia_weekend/router.dart';
import 'package:olympia_weekend/screens/schedule_screen.dart'
    show scheduleSelectedDayProvider;
import 'package:olympia_weekend/widgets/access_tag.dart';
import 'package:olympia_weekend/widgets/async_body.dart';
import 'package:olympia_weekend/widgets/card.dart';
import 'package:olympia_weekend/widgets/day_pills.dart';
import 'package:olympia_weekend/widgets/event_row.dart';
import 'package:olympia_weekend/widgets/pressable.dart';

class NowScreen extends ConsumerStatefulWidget {
  const NowScreen({super.key});

  @override
  ConsumerState<NowScreen> createState() => _NowScreenState();
}

class _NowScreenState extends ConsumerState<NowScreen> {
  bool _tracked = false;
  String? _selectedDate;

  @override
  Widget build(BuildContext context) {
    final colors = context.olympiaColors;
    final scheduleAsync = ref.watch(scheduleProvider);
    final venuesById = ref.watch(venuesByIdProvider);
    final nowAsync = ref.watch(nowVegasProvider);

    return ColoredBox(
      color: colors.background,
      child: AdaptiveScaffold(
        backgroundColor: colors.background,
        titleDisplay: TitleDisplay.none,
        body: SafeArea(
          bottom: false,
          child: OlympiaAsyncBody(
            child: scheduleAsync.when(
            loading: () => _padded(
              key: const ValueKey('loading'),
              child: const AdaptiveLoading(),
            ),
            error: (_, __) => _padded(
              key: const ValueKey('error'),
              child: AdaptiveError(
                message: AppStrings.errorLiveRefresh,
                onRetry: () => ref.refresh(scheduleProvider),
              ),
            ),
            data: (events) {
              final now = nowAsync.value ?? _vegasNow(ref);
              final days = weekendDays(events)
                  .where((d) => _isWeekend(d))
                  .toList();
              final selectedDate = _selectedDate ??
                  (_isWeekend(vegasDateOf(now))
                      ? vegasDateOf(now)
                      : days.first);
              final state = computeNowState(events, now);

              if (!_tracked) {
                _tracked = true;
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  ref.read(mixpanelProvider).viewNow(
                        nowEventId: state.happening?.event.id,
                        nextEventId: state.next.isEmpty
                            ? null
                            : state.next.first.event.id,
                      );
                });
              }

              return KeyedSubtree(
                key: const ValueKey('data'),
                child: _buildBody(
                  context: context,
                  colors: colors,
                  now: now,
                  selectedDate: selectedDate,
                  days: days,
                  events: events,
                  state: state,
                  venuesById: venuesById,
                ),
              );
            },
          ),
          ),
        ),
      ),
    );
  }

  Widget _buildBody({
    required BuildContext context,
    required OlympiaColors colors,
    required tz.TZDateTime now,
    required String selectedDate,
    required List<String> days,
    required List<Event> events,
    required NowState state,
    required Map<String, Venue> venuesById,
  }) {
    return ListView(
      padding: EdgeInsets.zero,
      children: [
        _Header(now: now),
        Padding(
          padding: const EdgeInsets.fromLTRB(24, 20, 24, 0),
          child: DayPills(
            dates: days,
            selected: selectedDate,
            activeColor: const Color(0xFFe2231a),
            activeTextColor: const Color(0xFFFFFFFF),
            onSelected: (d) {
              if (d == selectedDate) return;
              ref.read(mixpanelProvider).dayChange(selectedDate, d);
              // Prime Schedule with the tapped day before jumping —
              // without this, Schedule reads `primed = null` and falls
              // back to today (or Friday when today is pre-weekend), so
              // tapping Thu on Now would land the user on the wrong
              // day. Regression from commit 2a798cf whose message
              // claimed to do this write but only implemented the
              // Schedule-side read.
              ref.read(scheduleSelectedDayProvider.notifier).set(d);
              context.goNamed(Routes.schedule);
            },
          ),
        ),
        const SizedBox(height: 20),
        _installHint(context),
        if (state.happening != null) ...[
          _HappeningNowCard(
            resolved: state.happening!,
            venue: venuesById[state.happening!.event.venueId],
          ),
          const SizedBox(height: 28),
        ] else ...[
          const SizedBox(height: 8),
          _padded(
            child: Text(
              state.next.isEmpty
                  ? _emptyCopy(state.phase)
                  : AppStrings.nowEmpty,
              style: context.olympiaText.row.copyWith(
                color: colors.textMuted,
                fontWeight: FontWeight.w400,
              ),
            ),
          ),
          const SizedBox(height: 20),
        ],
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Expanded(
                child: Text(
                  AppStrings.nowUpNext,
                  style: context.olympiaText.section,
                ),
              ),
              OlympiaPressable(
                onTap: () => context.goNamed(Routes.schedule),
                semanticsLabel: AppStrings.nowFullDay,
                minSize: const Size(0, 44),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Text(
                    AppStrings.nowFullDay,
                    style: context.olympiaText
                        .link(accent: const Color(0xFFe2231a)),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 10),
        if (state.next.isEmpty)
          _padded(
            child: OlympiaCard(
              child: Text(
                _emptyCopy(state.phase),
                style: context.olympiaText.row.copyWith(
                  color: colors.textMuted,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ),
          )
        else
          _padded(
            child: OlympiaCard(
              padding: EdgeInsets.zero,
              // Thin accent border on Up next + All day so the day's
              // schedule pops off the black canvas without shouting.
              border: Border.all(
                color: const Color(0xFFe2231a),
                width: 1,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  for (var i = 0; i < state.next.length; i++) ...[
                    EventRow(
                      event: state.next[i].event,
                      venueLabel: _venueLabel(
                          venuesById[state.next[i].event.venueId],
                          state.next[i].event),
                      timeLabel: _shortTime(state.next[i].event.start),
                      onTap: () => _openEvent(state.next[i].event, 'now'),
                    ),
                    if (i != state.next.length - 1)
                      const OlympiaDivider(indent: 86),
                  ],
                ],
              ),
            ),
          ),
        if (state.allDay.isNotEmpty) ...[
          const SizedBox(height: 28),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Text(
              AppStrings.nowAllDay,
              style: context.olympiaText.section,
            ),
          ),
          const SizedBox(height: 10),
          _padded(
            child: OlympiaCard(
              padding: EdgeInsets.zero,
              border: Border.all(
                color: const Color(0xFFe2231a),
                width: 1,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  for (var i = 0; i < state.allDay.length; i++) ...[
                    EventRow(
                      event: state.allDay[i].event,
                      venueLabel: _venueLabel(
                          venuesById[state.allDay[i].event.venueId],
                          state.allDay[i].event),
                      timeLabel: '',
                      onTap: () => _openEvent(state.allDay[i].event, 'now'),
                    ),
                    if (i != state.allDay.length - 1)
                      const OlympiaDivider(),
                  ],
                ],
              ),
            ),
          ),
        ],
        const SizedBox(height: 32),
      ],
    );
  }

  Widget _installHint(BuildContext context) {
    final colors = context.olympiaColors;
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 0, 24, 20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: colors.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: colors.surfaceBorder),
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                AppStrings.nowInstallHint,
                style: context.olympiaText.caption,
              ),
            ),
            const SizedBox(width: 8),
            OlympiaPressable(
              onTap: () => _showInstallSheet(context),
              semanticsLabel: AppStrings.nowInstallHintCta,
              minSize: const Size(0, 44),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 4),
                child: Text(
                  AppStrings.nowInstallHintCta,
                  style: context.olympiaText.caption.copyWith(
                    color: const Color(0xFFe2231a),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _showInstallSheet(BuildContext context) async {
    ref.read(mixpanelProvider).installPromptShown();
    await AdaptiveSheet.show<void>(
      context,
      child: Builder(
        builder: (ctx) => Padding(
          padding: const EdgeInsets.fromLTRB(24, 24, 24, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                AppStrings.nowInstallSheetIosTitle,
                style: ctx.olympiaText.section,
              ),
              const SizedBox(height: 8),
              Text(
                AppStrings.nowInstallSheetIosBody,
                style: ctx.olympiaText.row.copyWith(
                  fontWeight: FontWeight.w400,
                ),
              ),
              const SizedBox(height: 16),
              AdaptivePrimaryButton(
                label: AppStrings.nowInstallSheetDismiss,
                onPressed: () => Navigator.of(ctx).pop(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _openEvent(Event event, String fromScreen) {
    ref.read(mixpanelProvider).viewEvent(
          eventId: event.id,
          access: event.access.name,
          venue: event.venueId,
          fromScreen: fromScreen,
        );
    context.goNamed(Routes.event, pathParameters: {'id': event.id});
  }

  String _venueLabel(Venue? v, Event e) {
    if (v == null) return e.venueId;
    return e.room == null ? v.short : '${v.short} · ${e.room}';
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.now});
  final tz.TZDateTime now;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(_longDate(now), style: context.olympiaText.caption),
                const SizedBox(height: 6),
                Text(AppStrings.appTitle, style: context.olympiaText.title),
              ],
            ),
          ),
          const SizedBox(width: 12),
          // The heart badge subscribes to `savedEventsProvider` on its
          // own Element via `Consumer` + `.select` on the length. Two
          // reasons: (a) rebuilds only on count changes, not on set
          // identity, (b) no prop-drilling from the parent means the
          // pop-back-from-Saved path can never leave a stale count.
          Consumer(
            builder: (context, ref, _) {
              final count = ref.watch(
                savedEventsProvider.select((s) => s.length),
              );
              return _SavedHeartAction(count: count);
            },
          ),
        ],
      ),
    );
  }
}

/// Heart button that jumps to `/saved`. When the user has one or more
/// saved events we render a small numeric badge on the top-right so
/// there's a visible reminder — Saved isn't a tab anymore, so this is
/// the only affordance surfacing the state.
class _SavedHeartAction extends StatelessWidget {
  const _SavedHeartAction({required this.count});
  final int count;

  @override
  Widget build(BuildContext context) {
    final colors = context.olympiaColors;
    final hasSaved = count > 0;
    return OlympiaPressable(
      onTap: () => context.goNamed(Routes.saved),
      semanticsLabel: hasSaved
          ? '${AppStrings.savedTitle}, $count saved'
          : AppStrings.savedTitle,
      minSize: const Size(44, 44),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            AdaptiveIcon(
              hasSaved ? AdaptiveIconName.heartFill : AdaptiveIconName.heart,
              size: 24,
              color: hasSaved ? const Color(0xFFe2231a) : colors.text,
            ),
            if (hasSaved)
              Positioned(
                top: -6,
                right: -8,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 5,
                    vertical: 1,
                  ),
                  constraints: const BoxConstraints(minWidth: 16),
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: const Color(0xFFe2231a),
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text(
                    '$count',
                    style: const TextStyle(
                      color: Color(0xFFFFFFFF),
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      height: 1.2,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _HappeningNowCard extends StatelessWidget {
  const _HappeningNowCard({required this.resolved, required this.venue});

  final ResolvedEvent resolved;
  final Venue? venue;

  @override
  Widget build(BuildContext context) {
    final colors = context.olympiaColors;
    final event = resolved.event;
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 0, 24, 0),
      child: OlympiaPressable(
        onTap: () {
          context.goNamed(Routes.event, pathParameters: {'id': event.id});
        },
        semanticsLabel: 'Happening now: ${event.title}',
        pressedOpacity: 0.7,
        child: OlympiaCard(
          border: Border.all(color: const Color(0xFFe2231a)),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 7,
                    height: 7,
                    decoration: const BoxDecoration(
                      color: Color(0xFFe2231a),
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    AppStrings.nowHappening,
                    style: context.olympiaText.caption.copyWith(
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFFe2231a),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                event.title,
                style: context.olympiaText.cardTitle,
              ),
              if (event.divisions.isNotEmpty) ...[
                const SizedBox(height: 4),
                Text(
                  event.divisions.join(', '),
                  style: context.olympiaText.row.copyWith(
                    fontWeight: FontWeight.w400,
                    color: colors.textMuted,
                    height: 1.4,
                  ),
                ),
              ],
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      _venueSubtitle(venue, event, resolved),
                      style: context.olympiaText.caption.copyWith(fontSize: 14),
                    ),
                  ),
                  const SizedBox(width: 8),
                  AccessTag(access: event.access),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ————— helpers —————

String _emptyCopy(WeekendPhase phase) {
  switch (phase) {
    case WeekendPhase.before:
      return AppStrings.nowEmptyBeforeWeekend;
    case WeekendPhase.after:
      return AppStrings.nowEmptyAfterWeekend;
    case WeekendPhase.during:
      return AppStrings.nowEmptyEndOfDay;
  }
}

Widget _padded({required Widget child, Key? key}) => Padding(
      key: key,
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: child,
    );

tz.TZDateTime _vegasNow(WidgetRef ref) {
  final f = ref.read(vegasClockProvider);
  return f();
}

/// Vegas dates for the weekend (Wed–Sun).
bool _isWeekend(String yyyyMmDd) =>
    olympiaWeekendDates.contains(yyyyMmDd);

String _longDate(tz.TZDateTime t) {
  const weekdays = [
    'Monday',
    'Tuesday',
    'Wednesday',
    'Thursday',
    'Friday',
    'Saturday',
    'Sunday',
  ];
  const months = [
    'January',
    'February',
    'March',
    'April',
    'May',
    'June',
    'July',
    'August',
    'September',
    'October',
    'November',
    'December',
  ];
  return '${weekdays[t.weekday - 1]}, ${months[t.month - 1]} ${t.day}';
}

String _shortTime(String? hhmm) {
  if (hhmm == null) return '';
  final parts = hhmm.split(':');
  if (parts.length < 2) return hhmm;
  final h = int.tryParse(parts[0]) ?? 0;
  final m = parts[1];
  final suffix = h >= 12 ? 'PM' : 'AM';
  final h12 = h == 0 ? 12 : (h > 12 ? h - 12 : h);
  return m == '00' ? '$h12 $suffix' : '$h12:$m $suffix';
}

String _venueSubtitle(Venue? venue, Event event, ResolvedEvent resolved) {
  final buf = StringBuffer(venue?.short ?? event.venueId);
  if (event.room != null) buf.write(' · ${event.room}');
  final endAt = resolved.endAt;
  if (endAt != null) {
    buf.write(' · until ${_shortTime(event.end)}');
  }
  return buf.toString();
}
