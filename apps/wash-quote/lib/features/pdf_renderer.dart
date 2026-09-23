// Prefer_const on pw.* widgets forces incompatible const factories on
// styled cells; suppress that one lint at the file scope.
// ignore_for_file: prefer_const_constructors

import 'dart:io' show File, Platform;
import 'dart:typed_data';

import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:wash_quote/data/app_database.dart';
import 'package:wash_quote/data/job_repo.dart';
import 'package:wash_quote/features/money_format.dart';
import 'package:wash_quote/l10n/app_strings.dart';

/// One rendered quote/invoice bundle: everything the layout needs, no
/// database access on the render path.
class QuoteRenderData {
  const QuoteRenderData({
    required this.business,
    required this.customer,
    required this.job,
    required this.lines,
    required this.photos,
    this.logoBytes,
  });

  final Business business;
  final Customer? customer;
  final Job job;
  final List<LineItem> lines;
  final List<Photo> photos;
  final Uint8List? logoBytes;

  int get subtotalCents => lines.fold<int>(0, (a, l) => a + l.totalCents);

  int get depositCents =>
      (subtotalCents * job.depositPct / 100).round();
}

/// Deterministic PDF renderer. Fed a `QuoteRenderData`, returns the PDF
/// bytes. Same input → same bytes, so the golden test's assertion holds.
class PdfRenderer {
  PdfRenderer({PdfPageFormat? pageFormat})
      : _pageFormat = pageFormat ?? _pageFormatForLocale();

  final PdfPageFormat _pageFormat;

  /// Uses `en_US` → US Letter, everything else → A4. Spec §4 does not
  /// dictate a size; PLAN §8 acceptance criterion locks in one locale
  /// switch.
  static PdfPageFormat _pageFormatForLocale() {
    try {
      final locale = Platform.localeName;
      if (locale.toLowerCase().contains('us')) return PdfPageFormat.letter;
      return PdfPageFormat.a4;
    } on Object {
      return PdfPageFormat.a4;
    }
  }

  Future<Uint8List> render(QuoteRenderData data) async {
    final doc = pw.Document(
      creator: 'Wash Quote & Invoice',
      author: data.business.name,
      title: 'Quote ${data.job.number}',
    )..addPage(
      pw.MultiPage(
        pageFormat: _pageFormat,
        margin: const pw.EdgeInsets.all(36),
        build: (context) => [
          _header(data),
          pw.SizedBox(height: 18),
          _customerBlock(data),
          pw.SizedBox(height: 18),
          _linesTable(data),
          pw.SizedBox(height: 12),
          _totalsBlock(data),
          pw.SizedBox(height: 18),
          _payViaBlock(data),
        ],
      ),
    );
    for (final photo in data.photos) {
      final imageBytes = await _readPhotoBytes(photo.path);
      if (imageBytes == null) continue;
      doc.addPage(
        pw.Page(
          pageFormat: _pageFormat,
          margin: const pw.EdgeInsets.all(36),
          build: (context) => pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text(
                photo.kind == PhotoKind.before.code ? 'Before' : 'After',
                style: pw.TextStyle(
                  fontSize: 12,
                  color: PdfColor.fromInt(0xFF666666),
                ),
              ),
              pw.SizedBox(height: 8),
              pw.Expanded(
                child: pw.Image(
                  pw.MemoryImage(imageBytes),
                ),
              ),
            ],
          ),
        ),
      );
    }
    return await doc.save();
  }

  Future<Uint8List?> _readPhotoBytes(String path) async {
    try {
      final f = File(path);
      if (!f.existsSync()) return null;
      return await f.readAsBytes();
    } on Object {
      return null;
    }
  }

  pw.Widget _header(QuoteRenderData data) {
    return pw.Row(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Expanded(
          child: pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text(
                data.business.name,
                style: pw.TextStyle(fontSize: 22, fontWeight: pw.FontWeight.bold),
              ),
              if ((data.business.phone ?? '').isNotEmpty)
                pw.Text(data.business.phone!, style: const pw.TextStyle(fontSize: 10)),
              if ((data.business.email ?? '').isNotEmpty)
                pw.Text(data.business.email!, style: const pw.TextStyle(fontSize: 10)),
              if ((data.business.address ?? '').isNotEmpty)
                pw.Text(data.business.address!, style: const pw.TextStyle(fontSize: 10)),
            ],
          ),
        ),
        pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.end,
          children: [
            if (data.logoBytes != null)
              pw.SizedBox(
                width: 72,
                height: 72,
                child: pw.Image(
                  pw.MemoryImage(data.logoBytes!),
                ),
              ),
            pw.SizedBox(height: 4),
            pw.Text(
              _titleForStatus(data.job.status),
              style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold),
            ),
            pw.Text(
              '#${data.job.number}',
              style: pw.TextStyle(
                fontSize: 12,
                color: PdfColor.fromInt(0xFF666666),
              ),
            ),
          ],
        ),
      ],
    );
  }

  pw.Widget _customerBlock(QuoteRenderData data) {
    final name = data.customer?.name ?? AppStrings.builderNoCustomer;
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text('For', style: pw.TextStyle(
          fontSize: 10,
          color: PdfColor.fromInt(0xFF666666),
        )),
        pw.Text(name, style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold)),
        if ((data.customer?.address ?? '').isNotEmpty)
          pw.Text(data.customer!.address!, style: const pw.TextStyle(fontSize: 10)),
      ],
    );
  }

  pw.Widget _linesTable(QuoteRenderData data) {
    return pw.Table(
      columnWidths: {
        0: const pw.FlexColumnWidth(4),
        1: const pw.FlexColumnWidth(),
        2: const pw.FlexColumnWidth(1.2),
        3: const pw.FlexColumnWidth(1.2),
      },
      children: [
        pw.TableRow(
          decoration: pw.BoxDecoration(
            border: pw.Border(
              bottom: pw.BorderSide(color: PdfColor.fromInt(0xFF000000)),
            ),
          ),
          children: [
            _th('Description'),
            _th('Qty'),
            _th('Unit'),
            _th('Total'),
          ],
        ),
        for (final line in data.lines)
          pw.TableRow(
            children: [
              _td(line.description),
              _td(_qtyString(line.qty)),
              _td(Money.formatCents(line.unitPriceCents)),
              _td(Money.formatCents(line.totalCents)),
            ],
          ),
      ],
    );
  }

  pw.Widget _totalsBlock(QuoteRenderData data) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.end,
      children: [
        _totalLine('Subtotal', Money.formatCents(data.subtotalCents)),
        _totalLine(
          'Deposit (${data.job.depositPct}%)',
          Money.formatCents(data.depositCents),
        ),
        pw.SizedBox(height: 4),
        _totalLine(
          'Total',
          Money.formatCents(data.subtotalCents),
          bold: true,
        ),
      ],
    );
  }

  pw.Widget _payViaBlock(QuoteRenderData data) {
    if (data.business.payVia.trim().isEmpty) return pw.SizedBox();
    return pw.Container(
      padding: const pw.EdgeInsets.all(10),
      decoration: pw.BoxDecoration(
        color: PdfColor.fromInt(0xFFF2F2F7),
        borderRadius: const pw.BorderRadius.all(pw.Radius.circular(6)),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text('Pay via', style: pw.TextStyle(
            fontSize: 10,
            color: PdfColor.fromInt(0xFF666666),
          )),
          pw.Text(data.business.payVia, style: const pw.TextStyle(fontSize: 12)),
        ],
      ),
    );
  }

  pw.Widget _th(String s) => pw.Padding(
        padding: const pw.EdgeInsets.symmetric(vertical: 6),
        child: pw.Text(
          s,
          style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold),
        ),
      );

  pw.Widget _td(String s) => pw.Padding(
        padding: const pw.EdgeInsets.symmetric(vertical: 4),
        child: pw.Text(s, style: const pw.TextStyle(fontSize: 11)),
      );

  pw.Widget _totalLine(String label, String value, {bool bold = false}) {
    return pw.Row(
      mainAxisAlignment: pw.MainAxisAlignment.end,
      children: [
        pw.Text(
          '$label:',
          style: pw.TextStyle(
            fontSize: 11,
            fontWeight: bold ? pw.FontWeight.bold : pw.FontWeight.normal,
          ),
        ),
        pw.SizedBox(width: 12),
        pw.SizedBox(
          width: 80,
          child: pw.Text(
            value,
            textAlign: pw.TextAlign.right,
            style: pw.TextStyle(
              fontSize: 11,
              fontWeight: bold ? pw.FontWeight.bold : pw.FontWeight.normal,
            ),
          ),
        ),
      ],
    );
  }

  String _titleForStatus(String status) {
    if (status == JobStatus.invoiced.code || status == JobStatus.paid.code) {
      return 'Invoice';
    }
    return 'Quote';
  }
}

String _qtyString(double qty) {
  if (qty == qty.roundToDouble()) return qty.toInt().toString();
  return qty.toStringAsFixed(1);
}
