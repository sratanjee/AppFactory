import 'package:flutter_test/flutter_test.dart';
import 'package:wash_quote/data/app_database.dart';
import 'package:wash_quote/data/business_repo.dart';
import 'package:wash_quote/data/customer_repo.dart';
import 'package:wash_quote/data/job_repo.dart';

void main() {
  late AppDatabase db;
  late JobRepo jobs;
  late CustomerRepo customers;
  late BusinessRepo business;

  setUp(() async {
    db = AppDatabase.inMemory();
    business = BusinessRepo(db);
    customers = CustomerRepo(db);
    jobs = JobRepo(db, business);
    await business.upsertSingleton(name: 'Test Wash Co');
  });

  tearDown(() async {
    await db.close();
  });

  test('createQuote inserts a job with line items and photos', () async {
    final customerId = await customers.add(name: 'Ada');
    final jobId = await jobs.createQuote(
      customerId: customerId,
      depositPct: 25,
      lines: const [
        NewLineItem(
          serviceId: null,
          description: 'House soft wash',
          qty: 1800,
          unitPriceCents: 45,
        ),
        NewLineItem(
          serviceId: null,
          description: 'Driveway',
          qty: 450,
          unitPriceCents: 55,
        ),
      ],
      photos: [
        (path: '/tmp/a.jpg', kind: PhotoKind.before, takenAt: 1),
      ],
    );

    final job = await jobs.byId(jobId);
    expect(job, isNotNull);
    expect(job!.status, JobStatus.quote.code);
    expect(job.number, 1001);

    final lines = await jobs.lineItemsFor(jobId);
    expect(lines, hasLength(2));
    final total = await jobs.totalFor(jobId);
    // 1800 * 45 + 450 * 55 = 81000 + 24750 = 105750
    expect(total, 105750);

    final photos = await jobs.photosFor(jobId);
    expect(photos, hasLength(1));
    expect(photos.first.kind, PhotoKind.before.code);
  });

  test('setStatus stamps sentAt / paidAt correctly', () async {
    final jobId = await jobs.createQuote(
      customerId: null,
      depositPct: 25,
      lines: const [
        NewLineItem(
          serviceId: null,
          description: 'Flat job',
          qty: 1,
          unitPriceCents: 25000,
        ),
      ],
      photos: const [],
    );

    await jobs.setStatus(jobId, JobStatus.sent);
    var job = await jobs.byId(jobId);
    expect(job?.status, JobStatus.sent.code);
    expect(job?.sentAt, isNotNull);
    expect(job?.paidAt, isNull);

    await jobs.setStatus(jobId, JobStatus.paid);
    job = await jobs.byId(jobId);
    expect(job?.paidAt, isNotNull);
  });

  test('setStripeLink persists the URL', () async {
    final jobId = await jobs.createQuote(
      customerId: null,
      depositPct: 25,
      lines: const [
        NewLineItem(
          serviceId: null,
          description: 'One',
          qty: 1,
          unitPriceCents: 10000,
        ),
      ],
      photos: const [],
    );
    await jobs.setStripeLink(jobId, 'https://pay.example/abc');
    final job = await jobs.byId(jobId);
    expect(job?.stripeLinkUrl, 'https://pay.example/abc');
  });

  test('deleteJob cascades to lines and photos', () async {
    final jobId = await jobs.createQuote(
      customerId: null,
      depositPct: 25,
      lines: const [
        NewLineItem(
          serviceId: null,
          description: 'x',
          qty: 1,
          unitPriceCents: 100,
        ),
      ],
      photos: [(path: '/tmp/x.jpg', kind: PhotoKind.after, takenAt: 2)],
    );

    await jobs.deleteJob(jobId);
    expect(await jobs.byId(jobId), isNull);
    expect(await jobs.lineItemsFor(jobId), isEmpty);
    expect(await jobs.photosFor(jobId), isEmpty);
  });

  test('watchSummaries returns totals + linked customer', () async {
    final cid = await customers.add(name: 'Bea');
    await jobs.createQuote(
      customerId: cid,
      depositPct: 25,
      lines: const [
        NewLineItem(
          serviceId: null,
          description: 'a',
          qty: 2,
          unitPriceCents: 5000,
        ),
      ],
      photos: const [],
    );

    final summaries = await jobs.watchSummaries().first;
    expect(summaries, hasLength(1));
    expect(summaries.first.totalCents, 10000);
    expect(summaries.first.customer?.name, 'Bea');
  });
}
