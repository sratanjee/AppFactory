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

/// Compute Now / Up-next / All-day state for a given Vegas moment.
///
/// - `happening`: the first event with startAt <= now <= endAt, if any.
///   For all-day events (start + end both set) the whole window counts.
/// - `next`: upcoming events *on the same Vegas day as `now`*, capped
///   at 6, sorted ascending by start. Reviewer round 1 blocker 3:
///   cross-day rows in the pre-weekend view read as broken duplicates
///   — filtering to today makes the "Wed / Thu / Fri" jumble go away.
/// - `allDay`: events on the same Vegas day as `now` that have both
///   start and end (Expo / Pop-Up Gym).
/// - `phase`: whether we're before, during, or after the weekend, so
///   the caller can pick an empty-state message.
NowState computeNowState(List<Event> events, tz.TZDateTime now) {
  final resolved = events.map(resolveEvent).toList(growable: false);
  final today = vegasDateOf(now);

  final happening = resolved.firstWhere(
    (r) =>
        r.startAt != null &&
        r.endAt != null &&
        !now.isBefore(r.startAt!) &&
        !now.isAfter(r.endAt!) &&
        !r.event.isAllDay,
    orElse: () => resolved.firstWhere(
      (r) =>
          r.event.isAllDay &&
          r.event.date == today &&
          r.startAt != null &&
          r.endAt != null &&
          !now.isBefore(r.startAt!) &&
          !now.isAfter(r.endAt!),
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
          r.event.date == today)
      .toList()
    ..sort((a, b) => a.startAt!.compareTo(b.startAt!));

  final allDayToday = resolved
      .where((r) => r.event.isAllDay && r.event.date == today)
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
