import 'dart:io' show Directory, File;
import 'dart:typed_data';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:wash_quote/data/app_database.dart';
import 'package:wash_quote/data/business_repo.dart';
import 'package:wash_quote/data/customer_repo.dart';
import 'package:wash_quote/data/job_repo.dart';
import 'package:wash_quote/features/pdf_renderer.dart';

/// CSV export + PDF bundle for every job. Written to the app documents
/// directory so the user (and the platform's document backup) can find
/// them; PLAN §4 also asks for iCloud Drive / Google Drive backup —
/// that's a native step tracked in REVIEW.md pending platform plugin
/// choice.
class DataExport {
  DataExport(this._db, this._business, this._customers, this._jobs);

  final AppDatabase _db;
  final BusinessRepo _business;
  final CustomerRepo _customers;
  final JobRepo _jobs;

  Future<Directory> _exportDir() async {
    final root = await getApplicationDocumentsDirectory();
    final dir = Directory(p.join(root.path, 'exports'));
    if (!dir.existsSync()) dir.createSync(recursive: true);
    return dir;
  }

  /// Writes a `jobs.csv` file with one row per job, columns:
  /// `number, status, customer, total_cents, deposit_pct, sent_at, paid_at`.
  Future<File> exportJobsCsv() async {
    final dir = await _exportDir();
    final rows = <String>[
      'number,status,customer,total_cents,deposit_pct,sent_at,paid_at',
    ];
    final all = await _db.select(_db.jobs).get();
    for (final job in all) {
      final customer =
          job.customerId == null ? null : await _customers.byId(job.customerId!);
      final total = await _jobs.totalFor(job.id);
      rows.add([
        job.number,
        job.status,
        _csvEscape(customer?.name ?? ''),
        total,
        job.depositPct,
        job.sentAt ?? '',
        job.paidAt ?? '',
      ].join(','));
    }
    final file = File(p.join(dir.path, 'jobs.csv'));
    await file.writeAsString(rows.join('\n'));
    return file;
  }

  /// Writes every job as a PDF under `exports/pdfs/`. Returns the count
  /// of files written.
  Future<int> exportEveryPdf() async {
    final dir = await _exportDir();
    final pdfDir = Directory(p.join(dir.path, 'pdfs'));
    if (!pdfDir.existsSync()) pdfDir.createSync(recursive: true);
    final biz = await _business.get();
    if (biz == null) return 0;
    final all = await _db.select(_db.jobs).get();
    final renderer = PdfRenderer();
    var count = 0;
    for (final job in all) {
      final customer = job.customerId == null
          ? null
          : await _customers.byId(job.customerId!);
      final lines = await _jobs.lineItemsFor(job.id);
      final photos = await _jobs.photosFor(job.id);
      final bytes = await renderer.render(
        QuoteRenderData(
          business: biz,
          customer: customer,
          job: job,
          lines: lines,
          photos: photos,
        ),
      );
      final file = File(p.join(pdfDir.path, 'quote-${job.number}.pdf'));
      await file.writeAsBytes(bytes, flush: true);
      count++;
    }
    return count;
  }

  /// Copies the Drift DB file (if present) into `exports/`. Returns
  /// `null` when the DB isn't a file-backed database (in-memory tests).
  Future<File?> exportDatabaseBackup() async {
    final root = await getApplicationDocumentsDirectory();
    // FactoryDatabase names its file `<slug>_app.sqlite` under the
    // platform docs dir; we don't know the slug here, so we scan for a
    // single `*_app.sqlite` file, which is the invariant for this app.
    final candidates = root
        .listSync()
        .whereType<File>()
        .where((f) => f.path.endsWith('_app.sqlite'))
        .toList();
    if (candidates.isEmpty) return null;
    final dir = await _exportDir();
    final dest = File(p.join(dir.path, 'wash-quote.sqlite'));
    await candidates.first.copy(dest.path);
    return dest;
  }

  /// Ships the full `exports/` directory contents through the platform
  /// share sheet so the operator can save the bundle anywhere. Falls
  /// back to a share-nothing no-op when nothing has been exported yet.
  Future<void> shareExports() async {
    final dir = await _exportDir();
    final files = dir.listSync().whereType<File>().toList();
    if (files.isEmpty) return;
    final params = ShareParams(
      files: [for (final f in files) XFile(f.path)],
    );
    await SharePlus.instance.share(params);
  }

  String _csvEscape(String value) {
    if (value.contains(',') || value.contains('"') || value.contains('\n')) {
      final escaped = value.replaceAll('"', '""');
      return '"$escaped"';
    }
    return value;
  }
}

final dataExportProvider = Provider<DataExport>((ref) {
  return DataExport(
    ref.watch(appDatabaseProvider),
    ref.watch(businessRepoProvider),
    ref.watch(customerRepoProvider),
    ref.watch(jobRepoProvider),
  );
});

/// Silence the unused-import warning for `Uint8List`; we may bring back a
/// bytes-in-memory export path later.
// ignore: unused_element
Uint8List _keepList() => Uint8List(0);
