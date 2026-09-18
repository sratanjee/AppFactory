import 'dart:async';
import 'dart:io' show File;
import 'dart:typed_data';

import 'package:factory_core/factory_core.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wash_quote/data/app_database.dart';
import 'package:wash_quote/data/business_repo.dart';
import 'package:wash_quote/data/customer_repo.dart';
import 'package:wash_quote/data/job_repo.dart';
import 'package:wash_quote/features/followup_notifications.dart';
import 'package:wash_quote/features/money_format.dart';
import 'package:wash_quote/features/pdf_renderer.dart';
import 'package:wash_quote/features/pdf_share.dart';
import 'package:wash_quote/features/photo_capture.dart';
import 'package:wash_quote/features/stripe_backend.dart';
import 'package:wash_quote/l10n/app_strings.dart';

class JobDetailScreen extends ConsumerStatefulWidget {
  const JobDetailScreen({required this.jobId, super.key});

  final int jobId;

  @override
  ConsumerState<JobDetailScreen> createState() => _JobDetailScreenState();
}

class _JobDetailScreenState extends ConsumerState<JobDetailScreen> {
  Uint8List? _pdfBytes;
  bool _rendering = false;
  bool _creatingLink = false;
  String? _depositError;

  @override
  Widget build(BuildContext context) {
    final jobAsync = ref.watch(_jobProvider(widget.jobId));
    return AdaptiveScaffold(
      title: const Text(AppStrings.jobDetailTitle),
      body: jobAsync.when(
        loading: () => const AdaptiveLoading(),
        error: (_, _) => const AdaptiveError(
          message: AppStrings.moneyError,
        ),
        data: (bundle) {
          if (bundle == null) return const SizedBox.shrink();
          unawaited(_maybeRender(bundle));
          return _JobDetailBody(
            bundle: bundle,
            pdfBytes: _pdfBytes,
            rendering: _rendering,
            depositError: _depositError,
            creatingLink: _creatingLink,
            onSendPdf: () => _sendPdf(bundle),
            onConvert: () => _convertToInvoice(bundle),
            onAddAfter: () => _addAfterPhoto(bundle),
            onDepositLink: () => _createDepositLink(bundle),
            onMarkAccepted: () => _setStatus(bundle, JobStatus.accepted),
            onMarkPaid: () => _setStatus(bundle, JobStatus.paid),
          );
        },
      ),
    );
  }

  Future<void> _maybeRender(_JobBundle bundle) async {
    if (_rendering || _pdfBytes != null) return;
    setState(() => _rendering = true);
    try {
      final bytes = await _renderPdf(bundle);
      if (mounted) setState(() => _pdfBytes = bytes);
    } finally {
      if (mounted) setState(() => _rendering = false);
    }
  }

  Future<Uint8List> _renderPdf(_JobBundle bundle) async {
    Uint8List? logoBytes;
    final logoPath = bundle.business.logoPath;
    if (logoPath != null && logoPath.isNotEmpty) {
      final f = File(logoPath);
      if (f.existsSync()) {
        logoBytes = await f.readAsBytes();
      }
    }
    return await PdfRenderer().render(
      QuoteRenderData(
        business: bundle.business,
        customer: bundle.customer,
        job: bundle.job,
        lines: bundle.lines,
        photos: bundle.photos,
        logoBytes: logoBytes,
      ),
    );
  }

  Future<void> _sendPdf(_JobBundle bundle) async {
    final bytes = _pdfBytes ?? await _renderPdf(bundle);
    await sharePdf(bytes, filenameBase: 'quote-${bundle.job.number}');
    ref
        .read(analyticsProvider)
        .trackCustom(name: 'pdf_sent', properties: {
      'job_number': bundle.job.number,
    });
    if (bundle.job.status == JobStatus.quote.code) {
      await ref.read(jobRepoProvider).setStatus(bundle.job.id, JobStatus.sent);
      // Fire a 3-day follow-up reminder. Permission was requested once
      // globally after the first successful send; if the user declined,
      // the schedule call is a no-op.
      final notifier = ref.read(followUpNotificationsProvider);
      await notifier.scheduleFollowUp(
        jobNumber: bundle.job.number,
        customerName: bundle.customer?.name ?? 'the customer',
        fireAt: DateTime.now().add(const Duration(days: 3)),
      );
    }
  }

  Future<void> _convertToInvoice(_JobBundle bundle) async {
    await ref
        .read(jobRepoProvider)
        .setStatus(bundle.job.id, JobStatus.invoiced);
    await ref
        .read(followUpNotificationsProvider)
        .cancelFollowUp(bundle.job.number);
    setState(() => _pdfBytes = null);
  }

  Future<void> _addAfterPhoto(_JobBundle bundle) async {
    final path = await capturePhotoFromCamera(context);
    if (path == null) return;
    await ref.read(jobRepoProvider).addPhoto(
          jobId: bundle.job.id,
          path: path,
          kind: PhotoKind.after,
        );
    setState(() => _pdfBytes = null);
  }

  Future<void> _createDepositLink(_JobBundle bundle) async {
    if (_creatingLink) return;
    setState(() {
      _creatingLink = true;
      _depositError = null;
    });
    try {
      final subtotal =
          bundle.lines.fold<int>(0, (a, l) => a + l.totalCents);
      final deposit = (subtotal * bundle.job.depositPct / 100).round();
      final result = await ref.read(stripeBackendProvider).createPaymentLink(
            amountCents: deposit,
            currency: Money.currencyCode(),
            jobNumber: bundle.job.number,
            businessName: bundle.business.name,
          );
      await ref
          .read(jobRepoProvider)
          .setStripeLink(bundle.job.id, result.url);
      ref.read(analyticsProvider).trackCustom(
        name: 'deposit_link_created',
        properties: {'ok': true},
      );
    } on Object {
      ref.read(analyticsProvider).trackCustom(
        name: 'deposit_link_created',
        properties: {'ok': false},
      );
      if (mounted) {
        setState(() => _depositError = AppStrings.jobDetailDepositLinkError);
      }
    } finally {
      if (mounted) setState(() => _creatingLink = false);
    }
  }

  Future<void> _setStatus(_JobBundle bundle, JobStatus status) async {
    await ref.read(jobRepoProvider).setStatus(bundle.job.id, status);
    // Terminal statuses (anything past `sent`) invalidate the pending
    // follow-up reminder; cancel it so the reminder doesn't fire on a
    // closed job.
    if (status != JobStatus.quote && status != JobStatus.sent) {
      await ref
          .read(followUpNotificationsProvider)
          .cancelFollowUp(bundle.job.number);
    }
    setState(() => _pdfBytes = null);
  }
}

class _JobBundle {
  const _JobBundle({
    required this.business,
    required this.job,
    required this.customer,
    required this.lines,
    required this.photos,
  });

  final Business business;
  final Job job;
  final Customer? customer;
  final List<LineItem> lines;
  final List<Photo> photos;
}

// Family provider's explicit generic can't be written on the LHS type
// without the exact `StreamProviderFamily` symbol (private in riverpod).
// ignore: specify_nonobvious_property_types
final _jobProvider =
    StreamProvider.family<_JobBundle?, int>((ref, jobId) async* {
  final business = await ref.watch(businessRepoProvider).get();
  if (business == null) {
    yield null;
    return;
  }
  final jobs = ref.watch(jobRepoProvider);
  await for (final job in jobs.watchById(jobId)) {
    if (job == null) {
      yield null;
      continue;
    }
    final lines = await jobs.lineItemsFor(jobId);
    final photos = await jobs.photosFor(jobId);
    final customer = job.customerId == null
        ? null
        : await ref.watch(customerRepoProvider).byId(job.customerId!);
    yield _JobBundle(
      business: business,
      job: job,
      customer: customer,
      lines: lines,
      photos: photos,
    );
  }
});

class _JobDetailBody extends StatelessWidget {
  const _JobDetailBody({
    required this.bundle,
    required this.pdfBytes,
    required this.rendering,
    required this.depositError,
    required this.creatingLink,
    required this.onSendPdf,
    required this.onConvert,
    required this.onAddAfter,
    required this.onDepositLink,
    required this.onMarkAccepted,
    required this.onMarkPaid,
  });

  final _JobBundle bundle;
  final Uint8List? pdfBytes;
  final bool rendering;
  final String? depositError;
  final bool creatingLink;
  final VoidCallback onSendPdf;
  final VoidCallback onConvert;
  final VoidCallback onAddAfter;
  final VoidCallback onDepositLink;
  final VoidCallback onMarkAccepted;
  final VoidCallback onMarkPaid;

  @override
  Widget build(BuildContext context) {
    final theme = context.adaptiveTheme;
    final status = JobStatusCode.fromCode(bundle.job.status);

    return SafeArea(
      bottom: false,
      child: ListView(
        padding: EdgeInsets.symmetric(
          horizontal: theme.spacing.lg,
          vertical: theme.spacing.md,
        ),
        children: [
          _StatusChip(status: status),
          SizedBox(height: theme.spacing.md),
          _PdfPreview(bundle: bundle, rendering: rendering, bytes: pdfBytes),
          SizedBox(height: theme.spacing.lg),
          Wrap(
            spacing: theme.spacing.sm,
            runSpacing: theme.spacing.sm,
            children: [
              _ActionButton(
                label: AppStrings.jobDetailSendPdf,
                accent: true,
                onPressed: onSendPdf,
              ),
              _ActionButton(
                label: AppStrings.jobDetailConvertInvoice,
                onPressed: status == JobStatus.invoiced ||
                        status == JobStatus.paid
                    ? null
                    : onConvert,
              ),
              _ActionButton(
                label: AppStrings.jobDetailAddAfterPhotos,
                onPressed: onAddAfter,
              ),
              _ActionButton(
                label: AppStrings.jobDetailDepositLink,
                onPressed: creatingLink ? null : onDepositLink,
              ),
              if (status == JobStatus.sent)
                _ActionButton(
                  label: AppStrings.jobDetailMarkAccepted,
                  onPressed: onMarkAccepted,
                ),
              if (status == JobStatus.invoiced)
                _ActionButton(
                  label: AppStrings.jobDetailMarkPaid,
                  onPressed: onMarkPaid,
                ),
            ],
          ),
          if (depositError != null) ...[
            SizedBox(height: theme.spacing.md),
            Text(
              depositError!,
              style: const TextStyle(color: Color(0xFFB3261E)),
            ),
          ],
          if (bundle.job.stripeLinkUrl != null &&
              bundle.job.stripeLinkUrl!.isNotEmpty) ...[
            SizedBox(height: theme.spacing.md),
            Container(
              padding: EdgeInsets.all(theme.spacing.md),
              decoration: BoxDecoration(
                color: theme.accent.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(theme.cornerRadius.md),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    AppStrings.jobDetailDepositLinkReady,
                    style: TextStyle(color: theme.accent, fontSize: 13),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    bundle.job.stripeLinkUrl!,
                    style: const TextStyle(fontSize: 12),
                  ),
                ],
              ),
            ),
          ],
          SizedBox(height: theme.spacing.xxl),
        ],
      ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  const _StatusChip({required this.status});
  final JobStatus status;

  @override
  Widget build(BuildContext context) {
    final theme = context.adaptiveTheme;
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          color: theme.accent.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(999),
        ),
        child: Text(
          _label(status),
          style: TextStyle(color: theme.accent),
        ),
      ),
    );
  }

  String _label(JobStatus status) {
    switch (status) {
      case JobStatus.quote:
        return AppStrings.jobsStatusQuote;
      case JobStatus.sent:
        return AppStrings.jobsStatusSent;
      case JobStatus.accepted:
        return AppStrings.jobsStatusAccepted;
      case JobStatus.invoiced:
        return AppStrings.jobsStatusInvoiced;
      case JobStatus.paid:
        return AppStrings.jobsStatusPaid;
    }
  }
}

class _PdfPreview extends StatelessWidget {
  const _PdfPreview({
    required this.bundle,
    required this.rendering,
    required this.bytes,
  });

  final _JobBundle bundle;
  final bool rendering;
  final Uint8List? bytes;

  @override
  Widget build(BuildContext context) {
    // We render on the caller's screen with the same layout the PDF uses,
    // rather than embedding a PDF viewer. This keeps the app self-contained
    // (no `pdfx`/`printing` widget cost) and matches the printed layout
    // one-for-one because both sides read `QuoteRenderData` from Drift.
    final theme = context.adaptiveTheme;
    final subtotal = bundle.lines.fold<int>(0, (a, l) => a + l.totalCents);
    final deposit = (subtotal * bundle.job.depositPct / 100).round();

    return Container(
      padding: EdgeInsets.all(theme.spacing.lg),
      decoration: BoxDecoration(
        color: const Color(0xFFFFFFFF),
        border: Border.all(color: const Color(0xFFE0E0E0)),
        borderRadius: BorderRadius.circular(theme.cornerRadius.md),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              if ((bundle.business.logoPath ?? '').isNotEmpty)
                SizedBox(
                  width: 48,
                  height: 48,
                  child: Image.file(
                    File(bundle.business.logoPath!),
                    fit: BoxFit.contain,
                  ),
                ),
              if ((bundle.business.logoPath ?? '').isNotEmpty)
                SizedBox(width: theme.spacing.md),
              Expanded(
                child: Text(
                  bundle.business.name,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              Text(
                '#${bundle.job.number}',
                style: const TextStyle(fontSize: 13, color: Color(0xFF666666)),
              ),
            ],
          ),
          SizedBox(height: theme.spacing.md),
          Text(
            bundle.customer?.name ?? AppStrings.builderNoCustomer,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          ),
          SizedBox(height: theme.spacing.md),
          for (final line in bundle.lines)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 2),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      line.description,
                      style: const TextStyle(fontSize: 14),
                    ),
                  ),
                  Text(
                    Money.formatCents(line.totalCents),
                    style: const TextStyle(
                      fontSize: 14,
                      fontFeatures: [FontFeature.tabularFigures()],
                    ),
                  ),
                ],
              ),
            ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Deposit (${bundle.job.depositPct}%)'),
              Text(
                Money.formatCents(deposit),
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Total',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
              ),
              Text(
                Money.formatCents(subtotal),
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  fontFeatures: [FontFeature.tabularFigures()],
                ),
              ),
            ],
          ),
          if (bundle.business.payVia.isNotEmpty) ...[
            SizedBox(height: theme.spacing.sm),
            Text(
              'Pay via ${bundle.business.payVia}',
              style: const TextStyle(fontSize: 13, color: Color(0xFF666666)),
            ),
          ],
          if (rendering) ...[
            SizedBox(height: theme.spacing.sm),
            const Text(
              'Rendering PDF…',
              style: TextStyle(fontSize: 11, color: Color(0xFF888888)),
            ),
          ],
          if (bytes != null) ...[
            SizedBox(height: theme.spacing.sm),
            Text(
              '${(bytes!.lengthInBytes / 1024).toStringAsFixed(0)} KB PDF ready',
              style: const TextStyle(fontSize: 11, color: Color(0xFF888888)),
            ),
          ],
        ],
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  const _ActionButton({
    required this.label,
    required this.onPressed,
    this.accent = false,
  });

  final String label;
  final VoidCallback? onPressed;
  final bool accent;

  @override
  Widget build(BuildContext context) {
    final theme = context.adaptiveTheme;
    final disabled = onPressed == null;
    final bg = disabled
        ? const Color(0xFFEFEFF2)
        : (accent ? theme.accent : const Color(0xFFFFFFFF));
    final fg =
        disabled ? const Color(0xFF888888) : (accent ? const Color(0xFFFFFFFF) : theme.accent);
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onPressed,
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: theme.spacing.md,
          vertical: theme.spacing.sm,
        ),
        decoration: BoxDecoration(
          color: bg,
          border: Border.all(color: accent ? theme.accent : theme.accent),
          borderRadius: BorderRadius.circular(theme.cornerRadius.md),
        ),
        child: Text(label, style: TextStyle(color: fg)),
      ),
    );
  }
}
