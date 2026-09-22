import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:olympia_weekend/data/schedule_repo.dart';
import 'package:olympia_weekend/features/now_state.dart';
import 'package:timezone/data/latest_all.dart' as tz_data;
import 'package:timezone/timezone.dart' as tz;

void main() {
  setUpAll(tz_data.initializeTimeZones);

  final loc = () => tz.getLocation('America/Los_Angeles');

  test('mid-Friday morning → happening surfaces an all-day pop-up', () {
    final events = parseSchedule(
      File('assets/data/schedule.json').readAsStringSync(),
    );
    final now = tz.TZDateTime(loc(), 2026, 9, 25, 10, 0);
    final state = computeNowState(events, now);
    // Friday 10:00 has three concurrent open windows: Dragon's Lair gym
    // (06–18) and the Expo (09–17); Friday pre-judging has no explicit
    // end so it doesn't qualify as "happening now" without inference.
    expect(state.happening, isNotNull);
    expect(
      {'fri-gym', 'fri-expo'},
      contains(state.happening!.event.id),
    );
  });

  test('Friday 22:00 → next is Saturday first', () {
    final events = parseSchedule(
      File('assets/data/schedule.json').readAsStringSync(),
    );
    final now = tz.TZDateTime(loc(), 2026, 9, 25, 22, 0);
    final state = computeNowState(events, now);
    expect(state.next, isNotEmpty);
    expect(state.next.first.event.date, '2026-09-26');
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
