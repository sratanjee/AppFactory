import 'package:condition_log/condition_log.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late ConditionLogDatabase db;
  late ConditionLogRepo repo;

  setUp(() {
    db = ConditionLogDatabase.inMemory();
    repo = ConditionLogRepo(db);
  });

  tearDown(() async {
    await db.close();
  });

  group('pets', () {
    test('upsert + read round-trip', () async {
      final id = await repo.upsertPet(
        name: 'Mochi',
        species: 'cat',
        breed: 'DSH',
        weightKg: 4.2,
      );
      final pet = await repo.getPet(id);
      expect(pet, isNotNull);
      expect(pet!.name, 'Mochi');
      expect(pet.species, 'cat');
      expect(pet.weightKg, 4.2);
    });
  });

  group('events', () {
    test('addEvent + watchEvents streams new rows', () async {
      final petId = await repo.upsertPet(name: 'Rex', species: 'dog');
      await repo.addEvent(
        petId: petId,
        kind: 'seizure',
        startedAt: DateTime(2026, 9, 17, 14),
        durationSec: 90,
        subtype: 'generalized',
      );
      final events = await repo.watchEvents(petId).first;
      expect(events, hasLength(1));
      expect(events[0].kind, 'seizure');
      expect(events[0].durationSec, 90);
      expect(events[0].subtype, 'generalized');
    });

    test('eventsBetween filters by date range', () async {
      final petId = await repo.upsertPet(name: 'Rex', species: 'dog');
      await repo.addEvent(
        petId: petId,
        kind: 'seizure',
        startedAt: DateTime(2026, 9, 1),
      );
      await repo.addEvent(
        petId: petId,
        kind: 'seizure',
        startedAt: DateTime(2026, 9, 17),
      );
      final inRange = await repo.eventsBetween(
        petId,
        from: DateTime(2026, 9, 10),
        to: DateTime(2026, 9, 30),
      );
      expect(inRange, hasLength(1));
      expect(inRange[0].startedAt,
          DateTime(2026, 9, 17).millisecondsSinceEpoch);
    });
  });

  group('measurements', () {
    test('multiple kinds coexist and filter cleanly', () async {
      final petId = await repo.upsertPet(name: 'Mochi', species: 'cat');
      await repo.addMeasurement(
        petId: petId,
        kind: 'glucose',
        value: 128,
        unit: 'mg/dL',
        takenAt: DateTime(2026, 9, 17, 9),
      );
      await repo.addMeasurement(
        petId: petId,
        kind: 'weight',
        value: 4.2,
        unit: 'kg',
        takenAt: DateTime(2026, 9, 17, 10),
      );
      final glucose = await repo.watchMeasurements(petId, kind: 'glucose').first;
      final weight = await repo.watchMeasurements(petId, kind: 'weight').first;
      expect(glucose, hasLength(1));
      expect(weight, hasLength(1));
      expect(glucose[0].value, 128);
    });
  });

  group('medications + doses', () {
    test('addMedication + logDose stores relations', () async {
      final petId = await repo.upsertPet(name: 'Rex', species: 'dog');
      final medId = await repo.addMedication(
        petId: petId,
        name: 'phenobarbital',
        strengthMg: 32.4,
        doseText: '1 tablet',
        timesPerDay: 2,
      );
      await repo.logDose(
        medicationId: medId,
        scheduledAt: DateTime(2026, 9, 17, 8),
        takenAt: DateTime(2026, 9, 17, 8, 5),
      );
      final doses = await repo.dosesBetween(
        petId: petId,
        from: DateTime(2026, 9, 17),
        to: DateTime(2026, 9, 18),
      );
      expect(doses, hasLength(1));
      expect(doses[0].takenAt, isNotNull);
    });
  });
}
