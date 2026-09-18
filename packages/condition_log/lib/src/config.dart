import 'package:condition_log/src/report/report_config.dart';
import 'package:flutter/foundation.dart';

/// Per-SKU configuration for the condition-log engine.
///
/// Each SKU (seizure, diabetes, kidney) constructs one of these at boot
/// and passes it to providers or the report generator. The engine never
/// stores SKU-specific labels; it always reads them through this object.
@immutable
class ConditionLogConfig {
  const ConditionLogConfig({
    required this.eventKinds,
    required this.reportConfig,
    this.eventSubtypeLabels = const {},
    this.measurementKinds = const {},
    this.onTimeDoseWindow = const Duration(minutes: 30),
  });

  /// Maps a raw `Event.kind` value (e.g. `seizure`) to the SKU-facing
  /// display label (e.g. `Seizure`). One entry per kind the SKU logs.
  final Map<String, String> eventKinds;

  /// Maps a raw `Event.subtype` value (e.g. `focal`) to a display label.
  /// Applies to every `kind` in this SKU — narrow scoping isn't needed
  /// because sibling SKUs use disjoint subtype vocabularies.
  final Map<String, String> eventSubtypeLabels;

  /// Maps a raw `Measurement.kind` value (e.g. `weight`) to a display
  /// label (e.g. `Weight (kg)`).
  final Map<String, String> measurementKinds;

  /// Report generator configuration. Sections, disclaimer, app name.
  final ReportConfig reportConfig;

  /// Window either side of `Dose.scheduledAt` inside which a dose is
  /// considered "on time" by `ConditionLogRepo.rollingStats`. Default
  /// 30 minutes; SKUs override if their clinical routine demands it.
  final Duration onTimeDoseWindow;

  String labelForEventKind(String kind) => eventKinds[kind] ?? kind;
  String labelForSubtype(String subtype) =>
      eventSubtypeLabels[subtype] ?? subtype;
  String labelForMeasurementKind(String kind) =>
      measurementKinds[kind] ?? kind;
}
