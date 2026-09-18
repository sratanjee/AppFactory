import 'package:flutter_test/flutter_test.dart';
import 'package:wash_quote/data/app_database.dart';
import 'package:wash_quote/data/business_repo.dart';
import 'package:wash_quote/data/customer_repo.dart';
import 'package:wash_quote/data/job_repo.dart';
import 'package:wash_quote/data/service_repo.dart';

/// Acceptance criterion in PLAN §8 task 7: "adding two lines and one
/// photo yields the correct total; save writes a Job with status = quote
/// and matching LineItem + Photo rows."
void main() {
  test('two service lines + one photo save into Drift as one quote',
      () async {
    final db = AppDatabase.inMemory();
    final business = BusinessRepo(db);
    final services = ServiceRepo(db);
    final customers = CustomerRepo(db);
    final jobs = JobRepo(db, business);
    await business.upsertSingleton(
      name: 'Blue Wave Wash',
      payVia: 'Venmo @bluewave',
      defaultDepositPct: 25,
    );

    final houseId = await services.add(
      name: 'House soft wash',
      unit: ServiceUnit.sqft,
      unitPriceCents: 45,
    );
    final driveId = await services.add(
      name: 'Driveway',
      unit: ServiceUnit.sqft,
      unitPriceCents: 55,
    );
    final customerId = await customers.add(name: 'Ada Okafor');

    final jobId = await jobs.createQuote(
      customerId: customerId,
      depositPct: 25,
      lines: [
        NewLineItem(
          serviceId: houseId,
          description: 'House soft wash',
          qty: 1800,
          unitPriceCents: 45,
        ),
        NewLineItem(
          serviceId: driveId,
          description: 'Driveway',
          qty: 450,
          unitPriceCents: 55,
        ),
      ],
      photos: [
        (path: '/tmp/before.jpg', kind: PhotoKind.before, takenAt: 1),
      ],
    );

    final job = await jobs.byId(jobId);
    expect(job?.status, JobStatus.quote.code);
    expect(job?.customerId, customerId);
    final rows = await jobs.lineItemsFor(jobId);
    expect(rows, hasLength(2));
    final total = await jobs.totalFor(jobId);
    expect(total, 105750);
    final photos = await jobs.photosFor(jobId);
    expect(photos, hasLength(1));
    expect(photos.first.kind, PhotoKind.before.code);
    await db.close();
  });
}
