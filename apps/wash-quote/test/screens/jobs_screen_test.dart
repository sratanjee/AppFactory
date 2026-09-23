import 'package:flutter_test/flutter_test.dart';
import 'package:wash_quote/data/app_database.dart';
import 'package:wash_quote/data/business_repo.dart';
import 'package:wash_quote/data/customer_repo.dart';
import 'package:wash_quote/data/job_repo.dart';

/// Guards the totalling that the Jobs screen's Waiting header uses. The
/// screen sums `totalCents` across every job in the `sent` state and
/// renders "Waiting on the customer · N · $X". This test seeds three sent
/// jobs and confirms the aggregate matches.
void main() {
  test('three sent jobs yield the correct waiting total', () async {
    final db = AppDatabase.inMemory();
    final business = BusinessRepo(db);
    final customers = CustomerRepo(db);
    final jobs = JobRepo(db, business);
    await business.upsertSingleton(name: 'Test Wash');
    final cid = await customers.add(name: 'Ada Okafor');

    for (var i = 0; i < 3; i++) {
      final id = await jobs.createQuote(
        customerId: cid,
        depositPct: 25,
        lines: const [
          NewLineItem(
            serviceId: null,
            description: 'Job',
            qty: 1,
            unitPriceCents: 25000,
          ),
        ],
        photos: const [],
      );
      await jobs.setStatus(id, JobStatus.sent);
    }

    final summaries = await jobs.watchSummaries().first;
    final waiting =
        summaries.where((s) => s.job.status == JobStatus.sent.code).toList();
    final total = waiting.fold<int>(0, (a, s) => a + s.totalCents);

    expect(waiting, hasLength(3));
    expect(total, 75000);
    await db.close();
  });
}
