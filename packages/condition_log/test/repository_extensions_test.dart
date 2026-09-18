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

  group('daysSinceLastEvent', () {
    test('returns null when no events', () async {
      final petId = await repo.upsertPet(name: 'Rex', species: 'dog');
      final n =
          await repo.daysSinceLastEvent(petId: petId, kind: 'seizure');
      expect(n, isNull);
    });

    test('counts whole local days between last event and now', () async {
      final petId = await repo.upsertPet(name: 'Rex', species: 'dog');
      await repo.addEvent(
        petId: petId,
        kind: 'seizure',
        startedAt: DateTime(2026, 9, 10, 23, 30),
      );
      final n = await repo.daysSinceLastEvent(
        petId: petId,
        kind: 'seizure',
        now: DateTime(2026, 9, 17, 8),
      );
      expect(n, 7);
    });

    test('scopes by kind, not just pet', () async {
      final petId = await repo.upsertPet(name: 'Rex', species: 'dog');
      await repo.addEvent(
        petId: petId,
        kind: 'seizure',
        startedAt: DateTime(2026, 9, 10),
      );
      await repo.addEvent(
        petId: petId,
        kind: 'hypo',
        startedAt: DateTime(2026, 9, 16),
      );
      final s = await repo.daysSinceLastEvent(
        petId: petId,
        kind: 'seizure',
        now: DateTime(2026, 9, 17),
      );
      expect(s, 7);
    });
  });

  group('eventDaysBetween', () {
    test('returns empty set when no events in range', () async {
      final petId = await repo.upsertPet(name: 'Rex', species: 'dog');
      final days = await repo.eventDaysBetween(
        petId: petId,
        kind: 'seizure',
        from: DateTime(2026, 9, 1),
        to: DateTime(2026, 9, 30),
      );
      expect(days, isEmpty);
    });

    test('collapses multiple same-day events to one calendar day',
        () async {
      final petId = await repo.upsertPet(name: 'Rex', species: 'dog');
      await repo.addEvent(
        petId: petId,
        kind: 'seizure',
        startedAt: DateTime(2026, 9, 10, 8),
      );
      await repo.addEvent(
        petId: petId,
        kind: 'seizure',
        startedAt: DateTime(2026, 9, 10, 20),
      );
      await repo.addEvent(
        petId: petId,
        kind: 'seizure',
        startedAt: DateTime(2026, 9, 15),
      );
      final days = await repo.eventDaysBetween(
        petId: petId,
        kind: 'seizure',
        from: DateTime(2026, 9, 1),
        to: DateTime(2026, 9, 30),
      );
      expect(days, hasLength(2));
      expect(days.contains(DateTime(2026, 9, 10)), isTrue);
      expect(days.contains(DateTime(2026, 9, 15)), isTrue);
    });
  });

  group('rollingStats', () {
    test('empty window returns zero count + null gaps + null adherence',
        () async {
      final petId = await repo.upsertPet(name: 'Rex', species: 'dog');
      final s = await repo.rollingStats(
        petId: petId,
        kind: 'seizure',
        now: DateTime(2026, 9, 17),
      );
      expect(s.eventCount, 0);
      expect(s.avgGapDays, isNull);
      expect(s.longestGapDays, isNull);
      expect(s.doseOnTimePct, isNull);
    });

    test('computes avg/longest gap + on-time %', () async {
      final petId = await repo.upsertPet(name: 'Rex', species: 'dog');
      await repo.addEvent(
        petId: petId,
        kind: 'seizure',
        startedAt: DateTime(2026, 8, 1),
      );
      await repo.addEvent(
        petId: petId,
        kind: 'seizure',
        startedAt: DateTime(2026, 8, 20),
      );
      await repo.addEvent(
        petId: petId,
        kind: 'seizure',
        startedAt: DateTime(2026, 9, 5),
      );

      final medId = await repo.addMedication(
        petId: petId,
        name: 'pheno',
      );
      await repo.logDose(
        medicationId: medId,
        scheduledAt: DateTime(2026, 9, 10, 8),
        takenAt: DateTime(2026, 9, 10, 8, 5),
      );
      await repo.logDose(
        medicationId: medId,
        scheduledAt: DateTime(2026, 9, 10, 20),
        takenAt: DateTime(2026, 9, 10, 22),
      );

      final s = await repo.rollingStats(
        petId: petId,
        kind: 'seizure',
        now: DateTime(2026, 9, 17),
      );
      expect(s.eventCount, 3);
      expect(s.avgGapDays, isNonZero);
      expect(s.longestGapDays, greaterThan(0));
      expect(s.doseOnTimePct, 50);
    });
  });

  group('todaysDoses + markDoseTaken', () {
    test('empty when no meds', () async {
      final petId = await repo.upsertPet(name: 'Rex', species: 'dog');
      final doses = await repo.todaysDoses(
        petId: petId,
        now: DateTime(2026, 9, 17),
      );
      expect(doses, isEmpty);
    });

    test("materializes today's doses from timesJson idempotently",
        () async {
      final petId = await repo.upsertPet(name: 'Rex', species: 'dog');
      await repo.addMedication(
        petId: petId,
        name: 'pheno',
        timesPerDay: 2,
        timesJson: ConditionLogRepo.encodeTimesJson([(8, 0), (20, 0)]),
      );

      final first = await repo.todaysDoses(
        petId: petId,
        now: DateTime(2026, 9, 17, 10),
      );
      expect(first, hasLength(2));

      final second = await repo.todaysDoses(
        petId: petId,
        now: DateTime(2026, 9, 17, 12),
      );
      expect(second, hasLength(2));
    });

    test('markDoseTaken writes takenAt and clears skipped', () async {
      final petId = await repo.upsertPet(name: 'Rex', species: 'dog');
      await repo.addMedication(
        petId: petId,
        name: 'pheno',
        timesPerDay: 1,
        timesJson: ConditionLogRepo.encodeTimesJson([(8, 0)]),
      );
      final doses = await repo.todaysDoses(
        petId: petId,
        now: DateTime(2026, 9, 17, 10),
      );
      await repo.markDoseTaken(
        doseId: doses.first.id,
        takenAt: DateTime(2026, 9, 17, 8, 5),
      );
      final after = await repo.todaysDoses(
        petId: petId,
        now: DateTime(2026, 9, 17, 11),
      );
      expect(after.first.takenAt, isNotNull);
      expect(after.first.skipped, isFalse);
    });
  });

  group('encodeTimesJson', () {
    test('pads HH:mm', () {
      expect(
        ConditionLogRepo.encodeTimesJson([(8, 0), (14, 5)]),
        '["08:00","14:05"]',
      );
    });
  });
}
