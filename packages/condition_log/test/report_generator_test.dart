import 'package:condition_log/condition_log.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late ConditionLogDatabase db;
  late ConditionLogRepo repo;
  late ReportGenerator gen;

  setUp(() {
    db = ConditionLogDatabase.inMemory();
    repo = ConditionLogRepo(db);
    gen = ReportGenerator(
      repo: repo,
      config: const ReportConfig(
        appName: 'Test',
        disclaimer: 'Talk to your vet before changing any medication.',
        sections: [
          ReportSection.petSummary,
          ReportSection.eventsTable,
          ReportSection.measurementsTable,
          ReportSection.doseAdherence,
          ReportSection.medicationsList,
        ],
        eventKindLabels: {'seizure': 'Seizure'},
        measurementKindLabels: {'glucose': 'Glucose (mg/dL)'},
      ),
    );
  });

  tearDown(() async {
    await db.close();
  });

  test('CSV includes every section header + disclaimer', () async {
    final petId = await repo.upsertPet(name: 'Mochi', species: 'cat');
    final pet = (await repo.getPet(petId))!;
    await repo.addEvent(
      petId: petId,
      kind: 'seizure',
      startedAt: DateTime(2026, 9, 17, 14),
      durationSec: 90,
    );
    await repo.addMeasurement(
      petId: petId,
      kind: 'glucose',
      value: 128,
      unit: 'mg/dL',
      takenAt: DateTime(2026, 9, 17, 9),
    );

    final data = await gen.loadData(
      pet: pet,
      from: DateTime(2026, 9, 1),
      to: DateTime(2026, 9, 30),
    );
    final csv = gen.buildCsv(data);

    expect(csv, contains('Pet summary'));
    expect(csv, contains('Talk to your vet'));
    expect(csv, contains('Events'));
    expect(csv, contains('Seizure'));
    expect(csv, contains('Measurements'));
    expect(csv, contains('Glucose (mg/dL)'));
    expect(csv, contains('Dose adherence'));
    expect(csv, contains('Medications'));
  });

  test('kind labels come from config, not raw enum strings', () async {
    final petId = await repo.upsertPet(name: 'Mochi', species: 'cat');
    final pet = (await repo.getPet(petId))!;
    await repo.addEvent(
      petId: petId,
      kind: 'seizure',
      startedAt: DateTime(2026, 9, 17, 14),
    );
    final data = await gen.loadData(
      pet: pet,
      from: DateTime(2026, 9, 1),
      to: DateTime(2026, 9, 30),
    );
    final csv = gen.buildCsv(data);
    expect(csv, contains('Seizure'));
    expect(csv, isNot(contains(',seizure,')));
  });

  test('empty period produces "no entries" placeholders, not blanks',
      () async {
    final petId = await repo.upsertPet(name: 'Mochi', species: 'cat');
    final pet = (await repo.getPet(petId))!;
    final data = await gen.loadData(
      pet: pet,
      from: DateTime(2026, 9, 1),
      to: DateTime(2026, 9, 30),
    );
    final csv = gen.buildCsv(data);
    expect(csv, contains('No events in period'));
    expect(csv, contains('No measurements in period'));
  });

  test('adherence % is computed correctly', () async {
    final petId = await repo.upsertPet(name: 'Rex', species: 'dog');
    final pet = (await repo.getPet(petId))!;
    final medId = await repo.addMedication(petId: petId, name: 'pheno');
    await repo.logDose(
      medicationId: medId,
      scheduledAt: DateTime(2026, 9, 17, 8),
      takenAt: DateTime(2026, 9, 17, 8, 5),
    );
    await repo.logDose(
      medicationId: medId,
      scheduledAt: DateTime(2026, 9, 17, 20),
      skipped: true,
    );

    final data = await gen.loadData(
      pet: pet,
      from: DateTime(2026, 9, 17),
      to: DateTime(2026, 9, 18),
    );
    final csv = gen.buildCsv(data);
    expect(csv, contains('50%'));
  });
}
