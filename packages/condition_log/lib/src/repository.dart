import 'dart:convert';

import 'package:condition_log/src/database.dart';
import 'package:drift/drift.dart';
import 'package:flutter/foundation.dart';

/// Thin, purpose-built API over ConditionLogDatabase. Every method is
/// side-effect-only or returns a stream / list — SKU code never touches
/// Drift builders directly.
class ConditionLogRepo {
  ConditionLogRepo(this._db);

  final ConditionLogDatabase _db;

  // ---- Pets ------------------------------------------------------------

  Future<int> upsertPet({
    int? id,
    required String name,
    required String species,
    String? breed,
    double? weightKg,
    DateTime? birthDate,
    String? photoPath,
    String? conditionLabel,
    String? configJson,
  }) async {
    final row = PetsCompanion(
      id: id == null ? const Value.absent() : Value(id),
      name: Value(name),
      species: Value(species),
      breed: Value(breed),
      weightKg: Value(weightKg),
      birthDate: Value(birthDate?.millisecondsSinceEpoch),
      photoPath: Value(photoPath),
      conditionLabel: Value(conditionLabel),
      configJson: Value(configJson),
    );
    if (id == null) return _db.into(_db.pets).insert(row);
    await _db.update(_db.pets).replace(row);
    return id;
  }

  Future<Pet?> getPet(int id) => (_db.select(_db.pets)
        ..where((t) => t.id.equals(id))
        ..limit(1))
      .getSingleOrNull();

  Stream<Pet?> watchPet(int id) => (_db.select(_db.pets)
        ..where((t) => t.id.equals(id))
        ..limit(1))
      .watchSingleOrNull();

  // ---- Events ----------------------------------------------------------

  Future<int> addEvent({
    required int petId,
    required String kind,
    required DateTime startedAt,
    int? durationSec,
    String? subtype,
    bool clusterFlag = false,
    String? triggers,
    String? note,
    String? metadataJson,
  }) {
    return _db.into(_db.events).insert(
          EventsCompanion.insert(
            petId: petId,
            kind: kind,
            startedAt: startedAt.millisecondsSinceEpoch,
            durationSec: Value(durationSec),
            subtype: Value(subtype),
            clusterFlag: Value(clusterFlag),
            triggers: Value(triggers),
            note: Value(note),
            metadataJson: Value(metadataJson),
          ),
        );
  }

  Stream<List<Event>> watchEvents(int petId, {String? kind}) {
    var query = _db.select(_db.events)..where((t) => t.petId.equals(petId));
    if (kind != null) query = query..where((t) => t.kind.equals(kind));
    query.orderBy([(t) => OrderingTerm.desc(t.startedAt)]);
    return query.watch();
  }

  Future<List<Event>> eventsBetween(
    int petId, {
    required DateTime from,
    required DateTime to,
  }) {
    return (_db.select(_db.events)
          ..where((t) => t.petId.equals(petId))
          ..where((t) => t.startedAt.isBiggerOrEqualValue(from.millisecondsSinceEpoch))
          ..where((t) => t.startedAt.isSmallerOrEqualValue(to.millisecondsSinceEpoch))
          ..orderBy([(t) => OrderingTerm.asc(t.startedAt)]))
        .get();
  }

  Future<void> updateEvent(Event event) =>
      _db.update(_db.events).replace(event);

  Future<void> deleteEvent(int id) =>
      (_db.delete(_db.events)..where((t) => t.id.equals(id))).go();

  /// Returns the number of whole days between the pet's most recent event
  /// of [kind] and `now` (default `DateTime.now()`). Returns `null` when
  /// no event of that kind exists — SKUs render this as `—`, not `0`.
  ///
  /// Day boundaries use local midnight, not 24-hour spans, so an event at
  /// 11pm reads as "1 day since" from 1am the next morning.
  Future<int?> daysSinceLastEvent({
    required int petId,
    required String kind,
    DateTime? now,
  }) async {
    final row = await (_db.select(_db.events)
          ..where((t) => t.petId.equals(petId) & t.kind.equals(kind))
          ..orderBy([(t) => OrderingTerm.desc(t.startedAt)])
          ..limit(1))
        .getSingleOrNull();
    if (row == null) return null;
    final n = now ?? DateTime.now();
    final today = DateTime(n.year, n.month, n.day);
    final last = DateTime.fromMillisecondsSinceEpoch(row.startedAt);
    final lastDay = DateTime(last.year, last.month, last.day);
    return today.difference(lastDay).inDays;
  }

  /// Distinct set of local calendar days (`DateTime(y, m, d)`) on which
  /// events of [kind] happened for [petId] between [from] and [to],
  /// inclusive. Used to paint the home-screen calendar cells.
  Future<Set<DateTime>> eventDaysBetween({
    required int petId,
    required String kind,
    required DateTime from,
    required DateTime to,
  }) async {
    final rows = await (_db.select(_db.events)
          ..where((t) =>
              t.petId.equals(petId) &
              t.kind.equals(kind) &
              t.startedAt.isBiggerOrEqualValue(from.millisecondsSinceEpoch) &
              t.startedAt.isSmallerOrEqualValue(to.millisecondsSinceEpoch)))
        .get();
    final days = <DateTime>{};
    for (final r in rows) {
      final d = DateTime.fromMillisecondsSinceEpoch(r.startedAt);
      days.add(DateTime(d.year, d.month, d.day));
    }
    return days;
  }

  // ---- Medications + Doses --------------------------------------------

  Future<int> addMedication({
    required int petId,
    required String name,
    double? strengthMg,
    String? doseText,
    int? timesPerDay,
    String? timesJson,
    bool active = true,
  }) {
    return _db.into(_db.medications).insert(
          MedicationsCompanion.insert(
            petId: petId,
            name: name,
            strengthMg: Value(strengthMg),
            doseText: Value(doseText),
            timesPerDay: Value(timesPerDay),
            timesJson: Value(timesJson),
            active: Value(active),
          ),
        );
  }

  Stream<List<Medication>> watchMedications(int petId) =>
      (_db.select(_db.medications)
            ..where((t) => t.petId.equals(petId) & t.active.equals(true))
            ..orderBy([(t) => OrderingTerm.asc(t.name)]))
          .watch();

  Future<int> logDose({
    required int medicationId,
    required DateTime scheduledAt,
    DateTime? takenAt,
    bool skipped = false,
  }) {
    return _db.into(_db.doses).insert(
          DosesCompanion.insert(
            medicationId: medicationId,
            scheduledAt: scheduledAt.millisecondsSinceEpoch,
            takenAt: Value(takenAt?.millisecondsSinceEpoch),
            skipped: Value(skipped),
          ),
        );
  }

  /// Updates the `takenAt` timestamp on a dose, marking it as taken.
  Future<void> markDoseTaken({
    required int doseId,
    required DateTime takenAt,
  }) async {
    await (_db.update(_db.doses)..where((t) => t.id.equals(doseId))).write(
      DosesCompanion(
        takenAt: Value(takenAt.millisecondsSinceEpoch),
        skipped: const Value(false),
      ),
    );
  }

  /// Marks a dose as skipped. Sets `takenAt` to null so re-appearing
  /// chip UIs render as untaken again.
  Future<void> markDoseSkipped({required int doseId}) async {
    await (_db.update(_db.doses)..where((t) => t.id.equals(doseId))).write(
      const DosesCompanion(
        takenAt: Value(null),
        skipped: Value(true),
      ),
    );
  }

  Future<void> updateMedication(Medication med) =>
      _db.update(_db.medications).replace(med);

  /// Soft-delete: flips `active` false so historical `Doses` rows survive
  /// but the med drops off Home and Meds. Chart-of-account style —
  /// history matters for the vet report.
  Future<void> deactivateMedication(int id) async {
    await (_db.update(_db.medications)..where((t) => t.id.equals(id))).write(
      const MedicationsCompanion(active: Value(false)),
    );
  }

  /// Idempotently returns the list of doses scheduled for [now]'s local
  /// day for every active medication attached to [petId], creating the
  /// missing rows on the fly. Read `Medications.timesJson` as a JSON
  /// array of `"HH:mm"` strings; medications without `timesJson` or with
  /// an empty list contribute zero rows.
  ///
  /// Chip strip on Home relies on this: same call reads a fresh row on
  /// day rollover and reads back existing state (taken/skipped) after
  /// the user tapped a chip earlier.
  Future<List<Dose>> todaysDoses({
    required int petId,
    DateTime? now,
  }) async {
    final n = now ?? DateTime.now();
    final startOfDay = DateTime(n.year, n.month, n.day);
    final endOfDay = startOfDay.add(const Duration(days: 1));
    final meds = await (_db.select(_db.medications)
          ..where((t) => t.petId.equals(petId) & t.active.equals(true)))
        .get();
    if (meds.isEmpty) return const [];

    for (final med in meds) {
      final timesJson = med.timesJson;
      if (timesJson == null || timesJson.isEmpty) continue;
      final times = _parseTimesJson(timesJson);
      for (final hhmm in times) {
        final scheduled = DateTime(
          startOfDay.year,
          startOfDay.month,
          startOfDay.day,
          hhmm.$1,
          hhmm.$2,
        );
        final existing = await (_db.select(_db.doses)
              ..where((t) =>
                  t.medicationId.equals(med.id) &
                  t.scheduledAt.equals(scheduled.millisecondsSinceEpoch))
              ..limit(1))
            .getSingleOrNull();
        if (existing == null) {
          await _db.into(_db.doses).insert(
                DosesCompanion.insert(
                  medicationId: med.id,
                  scheduledAt: scheduled.millisecondsSinceEpoch,
                ),
              );
        }
      }
    }

    final medIds = meds.map((m) => m.id).toList();
    return (_db.select(_db.doses)
          ..where((t) =>
              t.medicationId.isIn(medIds) &
              t.scheduledAt
                  .isBiggerOrEqualValue(startOfDay.millisecondsSinceEpoch) &
              t.scheduledAt.isSmallerThanValue(endOfDay.millisecondsSinceEpoch))
          ..orderBy([(t) => OrderingTerm.asc(t.scheduledAt)]))
        .get();
  }

  /// Aggregate stats for the "Last N days" home card. `window` defaults
  /// to 90 days per Seizure Log; other SKUs can shorten it.
  ///
  /// `onTimeWindow` is the +/- window either side of a dose's
  /// `scheduledAt` inside which `takenAt` counts as "on time". Passed
  /// down by SKU config, default 30 minutes.
  Future<RollingStats> rollingStats({
    required int petId,
    required String kind,
    Duration window = const Duration(days: 90),
    Duration onTimeWindow = const Duration(minutes: 30),
    DateTime? now,
  }) async {
    final n = now ?? DateTime.now();
    final from = n.subtract(window);
    final events = await eventsBetween(petId, from: from, to: n);
    final gaps = <int>[];
    for (var i = 1; i < events.length; i++) {
      final ms = events[i].startedAt - events[i - 1].startedAt;
      gaps.add((ms / (1000 * 60 * 60 * 24)).round());
    }
    final avgGap = gaps.isEmpty
        ? null
        : (gaps.reduce((a, b) => a + b) / gaps.length).round();
    final longestGap =
        gaps.isEmpty ? null : gaps.reduce((a, b) => a > b ? a : b);

    final doses = await dosesBetween(petId: petId, from: from, to: n);
    final scheduled = doses.length;
    final onTime = doses.where((d) {
      final takenAt = d.takenAt;
      if (takenAt == null || d.skipped) return false;
      final delta = (takenAt - d.scheduledAt).abs();
      return delta <= onTimeWindow.inMilliseconds;
    }).length;
    final onTimePct = scheduled == 0 ? null : (onTime * 100 / scheduled);

    return RollingStats(
      eventCount: events.length,
      avgGapDays: avgGap,
      longestGapDays: longestGap,
      doseOnTimePct: onTimePct,
    );
  }

  Future<List<Dose>> dosesBetween({
    required int petId,
    required DateTime from,
    required DateTime to,
  }) async {
    final medIds = await (_db.select(_db.medications)
          ..where((t) => t.petId.equals(petId)))
        .get()
        .then((rows) => rows.map((m) => m.id).toList());
    if (medIds.isEmpty) return const [];
    return (_db.select(_db.doses)
          ..where((t) => t.medicationId.isIn(medIds))
          ..where((t) => t.scheduledAt.isBiggerOrEqualValue(from.millisecondsSinceEpoch))
          ..where((t) => t.scheduledAt.isSmallerOrEqualValue(to.millisecondsSinceEpoch))
          ..orderBy([(t) => OrderingTerm.asc(t.scheduledAt)]))
        .get();
  }

  // ---- Measurements ---------------------------------------------------

  Future<int> addMeasurement({
    required int petId,
    required String kind,
    required double value,
    required String unit,
    required DateTime takenAt,
    String? label,
    int? panelId,
  }) {
    return _db.into(_db.measurements).insert(
          MeasurementsCompanion.insert(
            petId: petId,
            kind: kind,
            value: value,
            unit: unit,
            takenAt: takenAt.millisecondsSinceEpoch,
            label: Value(label),
            panelId: Value(panelId),
          ),
        );
  }

  Stream<List<Measurement>> watchMeasurements(int petId, {String? kind}) {
    var query = _db.select(_db.measurements)
      ..where((t) => t.petId.equals(petId));
    if (kind != null) query = query..where((t) => t.kind.equals(kind));
    query.orderBy([(t) => OrderingTerm.desc(t.takenAt)]);
    return query.watch();
  }

  Future<List<Measurement>> measurementsBetween(
    int petId, {
    required DateTime from,
    required DateTime to,
    String? kind,
  }) {
    var q = _db.select(_db.measurements)
      ..where((t) => t.petId.equals(petId))
      ..where((t) => t.takenAt.isBiggerOrEqualValue(from.millisecondsSinceEpoch))
      ..where((t) => t.takenAt.isSmallerOrEqualValue(to.millisecondsSinceEpoch));
    if (kind != null) q = q..where((t) => t.kind.equals(kind));
    q.orderBy([(t) => OrderingTerm.asc(t.takenAt)]);
    return q.get();
  }

  // ---- Notes ----------------------------------------------------------

  Future<int> addNote({
    required int petId,
    required DateTime at,
    required String body,
  }) {
    return _db.into(_db.notes).insert(
          NotesCompanion.insert(
            petId: petId,
            at: at.millisecondsSinceEpoch,
            body: body,
          ),
        );
  }

  // ---- Report runs ----------------------------------------------------

  Future<int> recordReportRun({
    required int petId,
    required DateTime from,
    required DateTime to,
    required String path,
    required String format,
  }) {
    return _db.into(_db.reportRuns).insert(
          ReportRunsCompanion.insert(
            petId: petId,
            fromAt: from.millisecondsSinceEpoch,
            toAt: to.millisecondsSinceEpoch,
            generatedAt: DateTime.now().millisecondsSinceEpoch,
            path: path,
            format: format,
          ),
        );
  }

  // ---- Helpers --------------------------------------------------------

  /// Parses a `Medications.timesJson` list-of-`"HH:mm"`-strings into
  /// `(hour, minute)` tuples. Silently drops malformed entries so a bad
  /// row never crashes the chip strip.
  static List<(int, int)> _parseTimesJson(String json) {
    try {
      final decoded = jsonDecode(json);
      if (decoded is! List) return const [];
      final out = <(int, int)>[];
      for (final entry in decoded) {
        if (entry is! String) continue;
        final parts = entry.split(':');
        if (parts.length != 2) continue;
        final h = int.tryParse(parts[0]);
        final m = int.tryParse(parts[1]);
        if (h == null || m == null) continue;
        if (h < 0 || h > 23 || m < 0 || m > 59) continue;
        out.add((h, m));
      }
      return out;
    } on FormatException {
      return const [];
    }
  }

  /// Encodes a list of `(hour, minute)` tuples as `Medications.timesJson`.
  /// Sibling SKUs use the same encoder so chip strips render identically.
  static String encodeTimesJson(List<(int, int)> times) {
    return jsonEncode([
      for (final t in times)
        '${t.$1.toString().padLeft(2, '0')}:${t.$2.toString().padLeft(2, '0')}',
    ]);
  }
}

/// Result of `ConditionLogRepo.rollingStats`. All four fields nullable
/// so an empty window (no events or no doses) renders "—" without the
/// UI having to special-case zero.
@immutable
class RollingStats {
  const RollingStats({
    required this.eventCount,
    required this.avgGapDays,
    required this.longestGapDays,
    required this.doseOnTimePct,
  });

  final int eventCount;
  final int? avgGapDays;
  final int? longestGapDays;

  /// Percent 0–100, or null when no doses were scheduled in the window.
  final double? doseOnTimePct;
}
