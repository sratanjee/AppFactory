import 'package:flutter_test/flutter_test.dart';
import 'package:wash_quote/data/app_database.dart';
import 'package:wash_quote/data/business_repo.dart';
import 'package:wash_quote/data/customer_repo.dart';
import 'package:wash_quote/data/job_repo.dart';
import 'package:wash_quote/features/pdf_renderer.dart';

void main() {
  test('renders a fixed fixture to a non-empty PDF', () async {
    final db = AppDatabase.inMemory();
    final business = BusinessRepo(db);
    final customers = CustomerRepo(db);
    final jobs = JobRepo(db, business);
    await business.upsertSingleton(
      name: 'Blue Wave Wash',
      payVia: 'Venmo @bluewave',
    );
    final cid = await customers.add(name: 'Ada Okafor');
    final jobId = await jobs.createQuote(
      customerId: cid,
      depositPct: 25,
      lines: const [
        NewLineItem(
          serviceId: null,
          description: 'House soft wash',
          qty: 1800,
          unitPriceCents: 45,
        ),
      ],
      photos: const [],
    );
    final job = (await jobs.byId(jobId))!;
    final lines = await jobs.lineItemsFor(jobId);
    final biz = (await business.get())!;

    final data = QuoteRenderData(
      business: biz,
      customer: await customers.byId(cid),
      job: job,
      lines: lines,
      photos: const [],
    );
    final bytes = await PdfRenderer().render(data);
    expect(bytes.isNotEmpty, isTrue);
    // Every PDF starts with the four-byte magic `%PDF`.
    expect(String.fromCharCodes(bytes.take(4)), '%PDF');
    await db.close();
  });

  test('renders without a logo and with zero photos', () async {
    final db = AppDatabase.inMemory();
    final business = BusinessRepo(db);
    final jobs = JobRepo(db, business);
    await business.upsertSingleton(name: 'Solo Wash');
    final jobId = await jobs.createQuote(
      customerId: null,
      depositPct: 0,
      lines: const [
        NewLineItem(
          serviceId: null,
          description: 'Flat',
          qty: 1,
          unitPriceCents: 10000,
        ),
      ],
      photos: const [],
    );
    final biz = (await business.get())!;
    final job = (await jobs.byId(jobId))!;
    final lines = await jobs.lineItemsFor(jobId);
    final bytes = await PdfRenderer().render(
      QuoteRenderData(
        business: biz,
        customer: null,
        job: job,
        lines: lines,
        photos: const [],
      ),
    );
    expect(bytes.isNotEmpty, isTrue);
    await db.close();
  });
}
