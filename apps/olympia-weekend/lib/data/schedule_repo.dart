import 'dart:convert';

import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:olympia_weekend/data/models.dart';

/// Parses `assets/data/schedule.json`.
Future<List<Event>> loadBundledSchedule() async {
  final raw = await rootBundle.loadString('assets/data/schedule.json');
  return parseSchedule(raw);
}

List<Event> parseSchedule(String jsonString) {
  final decoded = json.decode(jsonString) as Map<String, dynamic>;
  final events = (decoded['events'] as List<dynamic>).cast<Map<String, dynamic>>();
  return events.map(Event.fromJson).toList(growable: false);
}

/// Parses `assets/data/venues.json`.
Future<List<Venue>> loadBundledVenues() async {
  final raw = await rootBundle.loadString('assets/data/venues.json');
  return parseVenues(raw);
}

List<Venue> parseVenues(String jsonString) {
  final decoded = json.decode(jsonString) as Map<String, dynamic>;
  final venues = (decoded['venues'] as List<dynamic>).cast<Map<String, dynamic>>();
  return venues.map(Venue.fromJson).toList(growable: false);
}

class AthletesPayload {
  const AthletesPayload({required this.divisions, required this.athletes});
  final List<Division> divisions;
  final List<Athlete> athletes;
}

Future<AthletesPayload> loadBundledAthletes() async {
  final raw = await rootBundle.loadString('assets/data/athletes.json');
  return parseAthletes(raw);
}

AthletesPayload parseAthletes(String jsonString) {
  final decoded = json.decode(jsonString) as Map<String, dynamic>;
  final divisions = (decoded['divisions'] as List<dynamic>)
      .cast<Map<String, dynamic>>()
      .map(Division.fromJson)
      .toList(growable: false);
  final athletes = (decoded['athletes'] as List<dynamic>)
      .cast<Map<String, dynamic>>()
      .map(Athlete.fromJson)
      .toList(growable: false);
  return AthletesPayload(divisions: divisions, athletes: athletes);
}

final scheduleProvider =
    FutureProvider<List<Event>>((ref) => loadBundledSchedule());

final venuesProvider =
    FutureProvider<List<Venue>>((ref) => loadBundledVenues());

/// Athletes payload — starts as bundled, then the live-refresh task
/// (see `lib/features/live_refresh.dart`) overrides with merged data.
final athletesProvider =
    FutureProvider<AthletesPayload>((ref) => loadBundledAthletes());

/// Lookup helpers.
final eventsByIdProvider = Provider<Map<String, Event>>((ref) {
  final events = ref.watch(scheduleProvider).value ?? const <Event>[];
  return {for (final e in events) e.id: e};
});

final venuesByIdProvider = Provider<Map<String, Venue>>((ref) {
  final venues = ref.watch(venuesProvider).value ?? const <Venue>[];
  return {for (final v in venues) v.id: v};
});

final divisionsByIdProvider = Provider<Map<String, Division>>((ref) {
  final data = ref.watch(athletesProvider).value;
  if (data == null) return const {};
  return {for (final d in data.divisions) d.id: d};
});
