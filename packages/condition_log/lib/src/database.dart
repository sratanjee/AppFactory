import 'package:condition_log/src/schema.dart';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:factory_core/factory_core.dart';

part 'database.g.dart';

@DriftDatabase(
  tables: [Pets, Events, Medications, Doses, Measurements, Notes, ReportRuns],
)
class ConditionLogDatabase extends _$ConditionLogDatabase {
  ConditionLogDatabase({required String appSlug})
      : super(FactoryDatabase.open(appSlug: appSlug, dbName: 'condition_log'));

  ConditionLogDatabase.inMemory() : super(NativeDatabase.memory());

  @override
  int get schemaVersion => 1;
}
