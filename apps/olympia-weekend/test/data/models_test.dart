import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:olympia_weekend/data/schedule_repo.dart';
import 'package:timezone/data/latest_all.dart' as tz_data;

void main() {
  setUpAll(tz_data.initializeTimeZones);

  test('parses bundled schedule', () {
    final raw = File('assets/data/schedule.json').readAsStringSync();
    final events = parseSchedule(raw);
    expect(events, isNotEmpty);
    expect(events.first.id, isNotEmpty);
    expect(events.first.date, matches(RegExp(r'^\d{4}-\d{2}-\d{2}$')));
  });

  test('parses bundled venues', () {
    final raw = File('assets/data/venues.json').readAsStringSync();
    final venues = parseVenues(raw);
    expect(venues.length, 5);
    expect(venues.map((v) => v.id).toSet(),
        {'palms', 'orleans', 'lvcc', 'cosmopolitan', 'omnia'});
  });

  test('parses bundled athletes and divisions', () {
    final raw = File('assets/data/athletes.json').readAsStringSync();
    final payload = parseAthletes(raw);
    expect(payload.divisions, isNotEmpty);
    expect(payload.athletes, isNotEmpty);
    expect(payload.divisions.first.name, isNotEmpty);
  });
}
