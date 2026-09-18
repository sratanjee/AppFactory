import 'package:condition_log/src/database.dart';
import 'package:drift/drift.dart';

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
}
