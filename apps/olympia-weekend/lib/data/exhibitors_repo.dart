import 'dart:convert';

import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:olympia_weekend/data/models.dart';

/// Parses `assets/data/exhibitors.json` → list of [Exhibitor].
///
/// Sourced from mrolympia.com's floor plan; 154 rows, LVCC South Hall,
/// same list for Fri 9/25 and Sat 9/26.
Future<List<Exhibitor>> loadBundledExhibitors() async {
  final raw = await rootBundle.loadString('assets/data/exhibitors.json');
  return parseExhibitors(raw);
}

List<Exhibitor> parseExhibitors(String jsonString) {
  final decoded = json.decode(jsonString) as Map<String, dynamic>;
  final rows = (decoded['exhibitors'] as List<dynamic>)
      .cast<Map<String, dynamic>>();
  return rows.map(Exhibitor.fromJson).toList(growable: false);
}

/// Parses `assets/data/expo_events.json` → list of [ExpoEvent].
Future<List<ExpoEvent>> loadBundledExpoEvents() async {
  final raw = await rootBundle.loadString('assets/data/expo_events.json');
  return parseExpoEvents(raw);
}

List<ExpoEvent> parseExpoEvents(String jsonString) {
  final decoded = json.decode(jsonString) as Map<String, dynamic>;
  final rows =
      (decoded['events'] as List<dynamic>).cast<Map<String, dynamic>>();
  return rows.map(ExpoEvent.fromJson).toList(growable: false);
}

final exhibitorsProvider =
    FutureProvider<List<Exhibitor>>((ref) => loadBundledExhibitors());

final expoEventsProvider =
    FutureProvider<List<ExpoEvent>>((ref) => loadBundledExpoEvents());
