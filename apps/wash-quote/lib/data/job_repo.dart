import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wash_quote/data/app_database.dart';
import 'package:wash_quote/data/business_repo.dart';

enum JobStatus { quote, sent, accepted, invoiced, paid }

extension JobStatusCode on JobStatus {
  String get code => name;

  static JobStatus fromCode(String code) {
    return JobStatus.values.firstWhere(
      (s) => s.name == code,
      orElse: () => JobStatus.quote,
    );
  }
}

enum PhotoKind { before, after }

extension PhotoKindCode on PhotoKind {
  String get code => name;

  static PhotoKind fromCode(String code) {
    return PhotoKind.values.firstWhere(
      (p) => p.name == code,
      orElse: () => PhotoKind.before,
    );
  }
}

/// A view combining a job with its cached line-item total, used by the
/// Jobs screen so the list doesn't re-query line items per row.
class JobSummary {
  const JobSummary({
    required this.job,
    required this.customer,
    required this.totalCents,
    required this.beforePhotoPath,
    required this.primaryServiceName,
  });

  final Job job;
  final Customer? customer;
  final int totalCents;
  final String? beforePhotoPath;
  final String? primaryServiceName;
}

class NewLineItem {
  const NewLineItem({
    required this.serviceId,
    required this.description,
    required this.qty,
    required this.unitPriceCents,
  });

  final int? serviceId;
  final String description;
  final double qty;
  final int unitPriceCents;

  int get totalCents => (qty * unitPriceCents).round();
}

class JobRepo {
  JobRepo(this._db, this._business);

  final AppDatabase _db;
  final BusinessRepo _business;

  Future<int> createQuote({
    required int? customerId,
    required int depositPct,
    required List<NewLineItem> lines,
    required List<({String path, PhotoKind kind, int takenAt})> photos,
    String? notes,
  }) async {
    return await _db.transaction<int>(() async {
      final number = await _business.allocateJobNumber();
      final jobId = await _db.into(_db.jobs).insert(
            JobsCompanion.insert(
              customerId: Value(customerId),
              status: JobStatus.quote.code,
              number: number,
              createdAt: DateTime.now().millisecondsSinceEpoch,
              depositPct: Value(depositPct),
              notes: Value(notes),
            ),
          );
      for (final l in lines) {
        await _db.into(_db.lineItems).insert(
              LineItemsCompanion.insert(
                jobId: jobId,
                serviceId: Value(l.serviceId),
                description: l.description,
                qty: l.qty,
                unitPriceCents: l.unitPriceCents,
                totalCents: l.totalCents,
              ),
            );
      }
      for (final p in photos) {
        await _db.into(_db.photos).insert(
              PhotosCompanion.insert(
                jobId: jobId,
                path: p.path,
                kind: p.kind.code,
                takenAt: p.takenAt,
              ),
            );
      }
      return jobId;
    });
  }

  Future<void> setStatus(int jobId, JobStatus status) async {
    final now = DateTime.now().millisecondsSinceEpoch;
    final patch = JobsCompanion(
      status: Value(status.code),
      sentAt: status == JobStatus.sent ? Value(now) : const Value.absent(),
      acceptedAt:
          status == JobStatus.accepted ? Value(now) : const Value.absent(),
      paidAt: status == JobStatus.paid ? Value(now) : const Value.absent(),
    );
    await (_db.update(_db.jobs)..where((t) => t.id.equals(jobId))).write(patch);
  }

  Future<void> setStripeLink(int jobId, String url) async {
    await (_db.update(_db.jobs)..where((t) => t.id.equals(jobId)))
        .write(JobsCompanion(stripeLinkUrl: Value(url)));
  }

  Future<void> addPhoto({
    required int jobId,
    required String path,
    required PhotoKind kind,
  }) async {
    await _db.into(_db.photos).insert(
          PhotosCompanion.insert(
            jobId: jobId,
            path: path,
            kind: kind.code,
            takenAt: DateTime.now().millisecondsSinceEpoch,
          ),
        );
  }

  Future<Job?> byId(int id) =>
      (_db.select(_db.jobs)..where((t) => t.id.equals(id)))
          .getSingleOrNull();

  Stream<Job?> watchById(int id) =>
      (_db.select(_db.jobs)..where((t) => t.id.equals(id)))
          .watchSingleOrNull();

  Future<List<LineItem>> lineItemsFor(int jobId) {
    return (_db.select(_db.lineItems)..where((t) => t.jobId.equals(jobId)))
        .get();
  }

  Stream<List<LineItem>> watchLineItemsFor(int jobId) {
    return (_db.select(_db.lineItems)..where((t) => t.jobId.equals(jobId)))
        .watch();
  }

  Future<List<Photo>> photosFor(int jobId) {
    return (_db.select(_db.photos)
          ..where((t) => t.jobId.equals(jobId))
          ..orderBy([(t) => OrderingTerm.asc(t.takenAt)]))
        .get();
  }

  Stream<List<Photo>> watchPhotosFor(int jobId) {
    return (_db.select(_db.photos)
          ..where((t) => t.jobId.equals(jobId))
          ..orderBy([(t) => OrderingTerm.asc(t.takenAt)]))
        .watch();
  }

  Future<void> deleteJob(int id) async {
    await _db.transaction(() async {
      await (_db.delete(_db.lineItems)..where((t) => t.jobId.equals(id))).go();
      await (_db.delete(_db.photos)..where((t) => t.jobId.equals(id))).go();
      await (_db.delete(_db.jobs)..where((t) => t.id.equals(id))).go();
    });
  }

  /// All jobs, most recent first, joined with their customer and totalled
  /// line items. The Jobs screen filters this stream client-side by
  /// status.
  Stream<List<JobSummary>> watchSummaries() {
    return (_db.select(_db.jobs)
          ..orderBy([(t) => OrderingTerm.desc(t.createdAt)]))
        .watch()
        .asyncMap((jobs) async {
      final results = <JobSummary>[];
      for (final job in jobs) {
        final customer = job.customerId == null
            ? null
            : await (_db.select(_db.customers)
                  ..where((t) => t.id.equals(job.customerId!)))
                .getSingleOrNull();
        final total = await _totalFor(job.id);
        final firstPhoto = await (_db.select(_db.photos)
              ..where((t) =>
                  t.jobId.equals(job.id) &
                  t.kind.equals(PhotoKind.before.code))
              ..orderBy([(t) => OrderingTerm.asc(t.takenAt)])
              ..limit(1))
            .getSingleOrNull();
        final firstLine = await (_db.select(_db.lineItems)
              ..where((t) => t.jobId.equals(job.id))
              ..orderBy([(t) => OrderingTerm.asc(t.id)])
              ..limit(1))
            .getSingleOrNull();
        results.add(JobSummary(
          job: job,
          customer: customer,
          totalCents: total,
          beforePhotoPath: firstPhoto?.path,
          primaryServiceName: firstLine?.description,
        ));
      }
      return results;
    });
  }

  Future<int> _totalFor(int jobId) async {
    final rows = await (_db.select(_db.lineItems)
          ..where((t) => t.jobId.equals(jobId)))
        .get();
    return rows.fold<int>(0, (a, r) => a + r.totalCents);
  }

  Future<int> totalFor(int jobId) => _totalFor(jobId);
}

final jobRepoProvider = Provider<JobRepo>((ref) {
  return JobRepo(
    ref.watch(appDatabaseProvider),
    ref.watch(businessRepoProvider),
  );
});

final jobSummariesProvider = StreamProvider<List<JobSummary>>((ref) {
  return ref.watch(jobRepoProvider).watchSummaries();
});
