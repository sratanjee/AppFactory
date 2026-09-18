import 'package:drift/drift.dart';

/// Species is fixed across all condition-log SKUs. Not extensible — seizure,
/// diabetes and kidney all track dogs and cats.
class Pets extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text()();
  TextColumn get species => text()();
  TextColumn get breed => text().nullable()();
  RealColumn get weightKg => real().nullable()();
  IntColumn get birthDate => integer().nullable()();
  TextColumn get photoPath => text().nullable()();
  TextColumn get conditionLabel => text().nullable()();

  /// Free-form JSON so SKUs can add fields (Pet Diabetes: insulin/meter/unit;
  /// Kidney: irisStage, dailyPlan) without new columns.
  TextColumn get configJson => text().nullable()();
}

/// A dated occurrence tied to a Pet. `kind` is defined by the SKU's
/// ConditionLogConfig (seizure, hypo, fluids, vetVisit, etc.).
class Events extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get petId => integer()();
  TextColumn get kind => text()();
  IntColumn get startedAt => integer()();
  IntColumn get durationSec => integer().nullable()();
  TextColumn get subtype => text().nullable()();
  BoolColumn get clusterFlag => boolean().withDefault(const Constant(false))();
  TextColumn get triggers => text().nullable()();
  TextColumn get note => text().nullable()();
  TextColumn get metadataJson => text().nullable()();
}

class Medications extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get petId => integer()();
  TextColumn get name => text()();
  RealColumn get strengthMg => real().nullable()();
  TextColumn get doseText => text().nullable()();
  IntColumn get timesPerDay => integer().nullable()();
  TextColumn get timesJson => text().nullable()();
  BoolColumn get active => boolean().withDefault(const Constant(true))();
}

class Doses extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get medicationId => integer()();
  IntColumn get scheduledAt => integer()();
  IntColumn get takenAt => integer().nullable()();
  BoolColumn get skipped => boolean().withDefault(const Constant(false))();
}

/// Generic numeric reading tied to a Pet. `kind` is SKU-defined:
/// weight, bloodLevel, glucose, creatinine, sdma, water, etc.
class Measurements extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get petId => integer()();
  TextColumn get kind => text()();
  RealColumn get value => real()();
  TextColumn get unit => text()();
  IntColumn get takenAt => integer()();
  TextColumn get label => text().nullable()();
  IntColumn get panelId => integer().nullable()();
}

class Notes extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get petId => integer()();
  IntColumn get at => integer()();
  TextColumn get body => text()();
}

/// Record of a generated report so a vet-facing artifact survives across
/// export/share flows.
class ReportRuns extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get petId => integer()();
  IntColumn get fromAt => integer()();
  IntColumn get toAt => integer()();
  IntColumn get generatedAt => integer()();
  TextColumn get path => text()();
  TextColumn get format => text()();
}
