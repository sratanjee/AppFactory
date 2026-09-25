import 'package:olympia_weekend/data/models.dart';
import 'package:timezone/timezone.dart' as tz;

/// Parsed [Event] with resolved start/end as Vegas [tz.TZDateTime]s.
class ResolvedEvent {
  ResolvedEvent({
    required this.event,
    required this.startAt,
    required this.endAt,
  });

  final Event event;

  /// null when the event has no explicit start (TBD).
  final tz.TZDateTime? startAt;

  /// null when the event has no explicit end.
  final tz.TZDateTime? endAt;
}

ResolvedEvent resolveEvent(Event event) {
  return ResolvedEvent(
    event: event,
    startAt: _combine(event.date, event.start),
    endAt: _combine(event.date, event.end),
  );
}

tz.TZDateTime? _combine(String date, String? time) {
  if (time == null) return null;
  final parts = date.split('-');
  final t = time.split(':');
  if (parts.length != 3 || t.length < 2) return null;
  return tz.TZDateTime(
    tz.getLocation('America/Los_Angeles'),
    int.parse(parts[0]),
    int.parse(parts[1]),
    int.parse(parts[2]),
    int.parse(t[0]),
    int.parse(t[1]),
  );
}

class NowState {
  const NowState({
    required this.happening,
    required this.next,
    required this.allDay,
    required this.phase,
  });

  final ResolvedEvent? happening;
  final List<ResolvedEvent> next;
  final List<ResolvedEvent> allDay;
  final WeekendPhase phase;
}

/// Full sorted list of distinct event dates across the dataset. Useful
/// for the Schedule day pills.
List<String> weekendDays(List<Event> events) {
  final s = events.map((e) => e.date).toSet().toList()..sort();
  return s;
}

/// Fixed public Wed–Sun window of the 2026 Olympia weekend, in Vegas
/// local dates. Kept in one place so the Now screen empty state and
/// the [computeNowState] `phase` field agree on the same cutoff.
const List<String> olympiaWeekendDates = [
  '2026-09-23',
  '2026-09-24',
  '2026-09-25',
  '2026-09-26',
  '2026-09-27',
];

/// Formats yyyy-MM-dd for a Vegas TZDateTime.
String vegasDateOf(tz.TZDateTime t) {
  final y = t.year.toString().padLeft(4, '0');
  final m = t.month.toString().padLeft(2, '0');
  final d = t.day.toString().padLeft(2, '0');
  return '$y-$m-$d';
}

/// Where `now` sits relative to the Wed–Sun weekend window.
///
/// Used to swap the "Up next" empty-state copy on the Now screen.
enum WeekendPhase { before, during, after }

/// Default duration used when an event has a known start but no
/// declared end (finals, judging, VIP Q&A — the schedule leaves end
/// null when it isn't officially published). Kept generous so that
/// judging blocks that run five hours don't fall out of "Happening
/// now" halfway through the session.
const Duration _defaultEventDuration = Duration(hours: 4);

/// Compute Now / Up-next / All-day state for a given Vegas moment.
///
/// - `happening`: the first timed event whose active window includes
///   `now`. Timed = not marked all-day; the active window runs from
///   `startAt` through `endAt` (if set) or `startAt + 4h` otherwise.
///   Falls back to an active all-day event (pop-up gym, expo) only
///   when nothing timed is running — so the primary card surfaces the
///   real thing (Sandow Q&A, finals) instead of the ambient gym card.
/// - `next`: upcoming events *on the same Vegas day as `now`*, capped
///   at 6, sorted ascending by start.
/// - `allDay`: all-day events on the same Vegas day whose window still
///   includes `now` — expo/gym drop off once they close.
/// - `phase`: whether we're before, during, or after the weekend, so
///   the caller can pick an empty-state message.
NowState computeNowState(
  List<Event> events,
  tz.TZDateTime now, {
  bool includeInternal = false,
}) {
  final visible = includeInternal
      ? events
      : events.where((e) => !e.internal).toList(growable: false);
  final resolved = visible.map(resolveEvent).toList(growable: false);
  final today = vegasDateOf(now);
  // "Up next" pivot date. During and after the weekend it's the same
  // as today; before the weekend starts we roll forward to the first
  // Olympia day (Wednesday) so users on Tuesday still see a real
  // preview instead of an empty "Weekend starts Wednesday" card.
  final pivotDate = today.compareTo(olympiaWeekendDates.first) < 0
      ? olympiaWeekendDates.first
      : today;

  bool activeTimed(ResolvedEvent r) {
    if (r.event.isAllDay) return false;
    if (r.event.date != today) return false;
    final start = r.startAt;
    if (start == null) return false;
    if (now.isBefore(start)) return false;
    final end = r.endAt ?? start.add(_defaultEventDuration);
    return !now.isAfter(end);
  }

  bool activeAllDay(ResolvedEvent r) {
    if (!r.event.isAllDay) return false;
    if (r.event.date != today) return false;
    final start = r.startAt;
    final end = r.endAt;
    if (start == null || end == null) return false;
    return !now.isBefore(start) && !now.isAfter(end);
  }

  final happening = resolved.firstWhere(
    activeTimed,
    orElse: () => resolved.firstWhere(
      activeAllDay,
      orElse: () => ResolvedEvent(
        event: _sentinel,
        startAt: null,
        endAt: null,
      ),
    ),
  );

  final happeningNonNull = happening.event.id == _sentinel.id ? null : happening;

  final upcoming = resolved
      .where((r) =>
          r.startAt != null &&
          r.startAt!.isAfter(now) &&
          r.event.date == pivotDate)
      .toList()
    ..sort((a, b) => a.startAt!.compareTo(b.startAt!));

  // Show only all-day events still in their window — expo listed as
  // "All day" three hours after it closed looked broken.
  final allDayToday = resolved
      .where((r) => r.event.isAllDay && r.event.date == pivotDate && (
        // Pre-weekend view still lists everything ambient for context.
        pivotDate != today || activeAllDay(r)
      ))
      .toList();

  final WeekendPhase phase;
  if (today.compareTo(olympiaWeekendDates.first) < 0) {
    phase = WeekendPhase.before;
  } else if (today.compareTo(olympiaWeekendDates.last) > 0) {
    phase = WeekendPhase.after;
  } else {
    phase = WeekendPhase.during;
  }

  return NowState(
    happening: happeningNonNull,
    next: upcoming.take(6).toList(growable: false),
    allDay: allDayToday,
    phase: phase,
  );
}

const Event _sentinel = Event(
  id: '__sentinel__',
  date: '',
  title: '',
  venueId: '',
  access: EventAccess.free,
  divisions: [],
  runningOrder: [],
  shuttle: false,
  amateur: false,
  endEstimate: false,
);
