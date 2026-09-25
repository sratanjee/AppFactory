import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:olympia_weekend/data/schedule_repo.dart';
import 'package:olympia_weekend/features/now_state.dart';
import 'package:timezone/data/latest_all.dart' as tz_data;
import 'package:timezone/timezone.dart' as tz;

void main() {
  setUpAll(tz_data.initializeTimeZones);

  final loc = () => tz.getLocation('America/Los_Angeles');

  test('mid-Friday morning → happening surfaces the timed session, not the gym', () {
    // Prior behaviour: pop-up gym (06–18) always won because it was
    // the only event with an explicit end, so the primary card sat on
    // the ambient gym card for the whole day. Fix: timed events with a
    // known start inherit a 4-hour default duration so pre-judging /
    // finals / VIP Q&A win the primary slot when they're active.
    final events = parseSchedule(
      File('assets/data/schedule.json').readAsStringSync(),
    );
    final now = tz.TZDateTime(loc(), 2026, 9, 25, 10, 0);
    final state = computeNowState(events, now);
    expect(state.happening, isNotNull);
    expect(state.happening!.event.id, 'fri-prejudging');
    // The ambient gym + expo cards drop to the "All day" section.
    final allDayIds = state.allDay.map((e) => e.event.id).toSet();
    expect(allDayIds, containsAll(<String>['fri-gym', 'fri-expo']));
  });

  test('after the timed event\'s inferred window → falls back to all-day', () {
    // Between prejudging's inferred close (~13:30) and Sandow's start
    // (15:00) there is no active timed event, so the primary card
    // legitimately falls back to the pop-up gym.
    final events = parseSchedule(
      File('assets/data/schedule.json').readAsStringSync(),
    );
    final now = tz.TZDateTime(loc(), 2026, 9, 25, 14, 0);
    final state = computeNowState(events, now);
    expect(state.happening, isNotNull);
    expect(
      {'fri-gym', 'fri-expo'},
      contains(state.happening!.event.id),
    );
  });

  test('Friday 16:00 → Sandow Q&A wins the primary slot', () {
    final events = parseSchedule(
      File('assets/data/schedule.json').readAsStringSync(),
    );
    final now = tz.TZDateTime(loc(), 2026, 9, 25, 16, 0);
    final state = computeNowState(events, now);
    expect(state.happening, isNotNull);
    expect(state.happening!.event.id, 'fri-sandow');
  });

  test('all-day section drops the expo after it closes', () {
    // Expo runs 09:00–17:00. At 18:00 the primary card is finals; the
    // "All day" section should only carry the pop-up gym (06–18), not
    // the already-closed expo.
    final events = parseSchedule(
      File('assets/data/schedule.json').readAsStringSync(),
    );
    final now = tz.TZDateTime(loc(), 2026, 9, 25, 18, 0);
    final state = computeNowState(events, now);
    final allDayIds = state.allDay.map((e) => e.event.id).toSet();
    expect(allDayIds, isNot(contains('fri-expo')));
  });

  test('Friday 22:00 → next filters to today, empty if nothing remains', () {
    // Reviewer round 1 blocker 3: "Up next" must not spill into the
    // next day, otherwise the pre-weekend view stacks Wed/Thu/Fri rows
    // without any weekday label and reads as broken duplicates.
    final events = parseSchedule(
      File('assets/data/schedule.json').readAsStringSync(),
    );
    final now = tz.TZDateTime(loc(), 2026, 9, 25, 22, 0);
    final state = computeNowState(events, now);
    for (final e in state.next) {
      expect(e.event.date, '2026-09-25');
    }
    expect(state.phase, WeekendPhase.during);
  });

  test('Tuesday before the weekend → next previews Wednesday, phase is before', () {
    // Regression from Sarang's Tuesday-evening review — the pre-
    // weekend Up-next was showing an empty state instead of rolling
    // forward to Wednesday's events. We still want phase = before so
    // the empty-state copy elsewhere doesn't lie.
    final events = parseSchedule(
      File('assets/data/schedule.json').readAsStringSync(),
    );
    final now = tz.TZDateTime(loc(), 2026, 9, 22, 10, 0);
    final state = computeNowState(events, now);
    expect(state.next, isNotEmpty);
    for (final e in state.next) {
      expect(e.event.date, '2026-09-23'); // Wed
    }
    expect(state.phase, WeekendPhase.before);
  });

  test('Monday after the weekend → next is empty, phase is after', () {
    final events = parseSchedule(
      File('assets/data/schedule.json').readAsStringSync(),
    );
    final now = tz.TZDateTime(loc(), 2026, 9, 28, 10, 0);
    final state = computeNowState(events, now);
    expect(state.next, isEmpty);
    expect(state.phase, WeekendPhase.after);
  });

  test('all-day items only surface on their day', () {
    final events = parseSchedule(
      File('assets/data/schedule.json').readAsStringSync(),
    );
    final now = tz.TZDateTime(loc(), 2026, 9, 25, 7, 0);
    final state = computeNowState(events, now);
    for (final e in state.allDay) {
      expect(e.event.date, '2026-09-25');
    }
  });

  test('Vegas time is 19:00 when device Eastern is 22:00', () {
    final vegas = tz.TZDateTime.from(
      DateTime.utc(2026, 9, 26, 2, 0), // 22:00 Eastern = 02:00 UTC next day
      loc(),
    );
    expect(vegas.hour, 19);
    expect(vegas.day, 25);
  });
}
