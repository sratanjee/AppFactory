import 'package:condition_log/src/database.dart';
import 'package:flutter/foundation.dart';

/// Per-SKU report configuration. Owns event/measurement kind labels, the
/// disclaimer line, section ordering, and column projections for the
/// CSV/PDF exports.
///
/// No SKU may compute clinical staging or dosing advice inside a formatter
/// — the report is a chronological summary only (Apple 1.4.2).
@immutable
class ReportConfig {
  const ReportConfig({
    required this.appName,
    required this.disclaimer,
    required this.sections,
    this.eventKindLabels = const {},
    this.measurementKindLabels = const {},
  });

  final String appName;

  /// Persistent line shown at the top of every report and on any
  /// interior page that discusses medication (per DESIGN_GUIDE / Apple
  /// 1.4.2). Typical: "Talk to your vet before changing any medication."
  final String disclaimer;

  /// Ordered list of report sections. Empty sections render as
  /// "No entries in this period" rather than being dropped.
  final List<ReportSection> sections;

  /// Maps raw `Event.kind` to display labels ("seizure" → "Seizure",
  /// "hypo" → "Hypoglycemia").
  final Map<String, String> eventKindLabels;

  /// Maps raw `Measurement.kind` to display labels ("glucose" → "Glucose (mg/dL)",
  /// "creatinine" → "Creatinine").
  final Map<String, String> measurementKindLabels;

  String labelForEventKind(String kind) => eventKindLabels[kind] ?? kind;
  String labelForMeasurementKind(String kind) =>
      measurementKindLabels[kind] ?? kind;
}

/// A single section of a rendered report.
enum ReportSection {
  petSummary,
  eventsTable,
  measurementsTable,
  doseAdherence,
  medicationsList,
  notes,
}

/// Container for the data the report generator will render. Populated by
/// the generator from the repo.
@immutable
class ReportData {
  const ReportData({
    required this.pet,
    required this.from,
    required this.to,
    required this.events,
    required this.measurements,
    required this.medications,
    required this.doses,
  });

  final Pet pet;
  final DateTime from;
  final DateTime to;
  final List<Event> events;
  final List<Measurement> measurements;
  final List<Medication> medications;
  final List<Dose> doses;
}
